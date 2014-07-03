
#import "ImportFileAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/UIImageManager.h"
#import "../../Util/FileOperationThread.h"
#import <unistd.h>


@interface ImportFileAction()
- (void)onFileBrowserCancelButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@end


void ImportFileAction_AlertViewDismissHandler(void*data, int buttonIndex);
void ImportFileAction_FileOperationFinishCallback(void*data, int result);
void ImportFileAction_FileOperationFinishHandler(void*data);


@implementation ImportFileAction

@synthesize pendingPath;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
#if (TARGET_IPHONE_SIMULATOR)
	self = [super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:@"/Users"];
	if(self==nil)
	{
		return nil;
	}
#else
	NSString* userDir = [[NSString alloc] initWithUTF8String:getenv("HOME")];
	self = [super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:userDir];
	if(self==nil)
	{
		[userDir release];
		return nil;
	}
	[userDir release];
#endif
	
	[self.fileBrowserCtrl setGlobalToolbarHidden:NO];
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onFileBrowserCancelButtonSelected)];
	[toolbarItems addObject:cancelButton];
	[cancelButton release];
	UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbarItems addObject:flexibleSpace];
	[flexibleSpace release];
	[self.fileBrowserCtrl.globalToolbar setItems:toolbarItems animated:NO];
	[toolbarItems release];
	
	return self;
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFile:(NSString*)file
{
	NSMutableFilePath* fullPath = [[NSMutableFilePath alloc] initWithFilePath:fileBrowser.root];
	[fullPath appendPath:fileBrowser.path];
	[fullPath addMember:file];
	self.pendingPath = [NSString stringWithString:[fullPath pathAsString]];
	[fullPath release];
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Would you like to import the file "];
	[message appendString:file];
	[message appendString:@"?"];
	const char* buttons[2] = {"Cancel", "Confirm"};
	showSimpleMessageBox("Import File", [message UTF8String], buttons, 2, self, &ImportFileAction_AlertViewDismissHandler, NULL);
	[message release];
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFileLink:(NSString*)file
{
	NSMutableFilePath* fullFilePath = [[NSMutableFilePath alloc] initWithFilePaths:fileBrowser.root, fileBrowser.path, nil];
	[fullFilePath addMember:file];
	
	char* linkPathPtr = (char*)malloc(PATH_MAX);
	int linkResult = readlink([[fullFilePath pathAsString] UTF8String], linkPathPtr, PATH_MAX);
	if(linkResult==-1)
	{
		[fullFilePath release];
		free(linkPathPtr);
		return;
	}
	
	linkPathPtr[linkResult] = '\0';
	
	[fullFilePath release];
	
	NSString* linkPathString = [[NSString alloc] initWithUTF8String:linkPathPtr];
	NSFilePath* linkPath = [[NSFilePath alloc] initWithString:linkPathString];
	[linkPathString release];
	free(linkPathPtr);
	
	if(![linkPath containsSubfoldersOf:fileBrowser.root])
	{
		[linkPath release];
		return;
	}
	
	self.pendingPath = [NSString stringWithString:[linkPath pathAsString]];
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Would you like to import the file \""];
	[message appendString:[linkPath pathAsString]];
	[message appendString:@"\"?"];
	const char* buttons[2] = {"Cancel", "Confirm"};
	showSimpleMessageBox("Import File", [message UTF8String], buttons, 2, self, &ImportFileAction_AlertViewDismissHandler, NULL);
	[message release];
	
	[linkPath release];
}

- (void)onFileBrowserCancelButtonSelected
{
	[self.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated
{
	[self release];
}

- (void)dealloc
{
	[pendingPath release];
	[super dealloc];
}

@end

void ImportFileAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	ImportFileAction* action = (ImportFileAction*)data;
	
	if(buttonIndex==1)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		StringTree_struct sourceTree;
		NSString*categoryName = [action.viewCtrl.selectedCell getCategory];
		
		if([categoryName isEqual:@"src"])
		{
			sourceTree = ProjectData_getSourceFiles(appDelegate.projData);
		}
		else if([categoryName isEqual:@"res"])
		{
			sourceTree = ProjectData_getResourceFiles(appDelegate.projData);
		}
		else
		{
			showSimpleMessageBox("Error", "Unknown category name for selected UIProjectTreeViewCell");
			return;
		}
		
		NSString* projectsFolderString = [[NSString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		NSMutableFilePath* projectPath = [[NSMutableFilePath alloc] initWithString:projectsFolderString];
		[projectsFolderString release];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[projectPath addMember:saveFolder];
		[saveFolder release];
		[projectPath addMember:categoryName];
		
		NSMutableFilePath* srcPath = [[NSMutableFilePath alloc] initWithString:action.pendingPath];
		NSMutableString* destPathString = [[NSMutableString alloc] initWithString:[projectPath pathAsString]];
		[destPathString appendString:@"/"];
		[destPathString appendString:[action.viewCtrl.selectedCell getPath]];
		NSMutableFilePath* destPath = [[NSMutableFilePath alloc] initWithString:destPathString];
		[destPath addMember:[srcPath lastMember]];
		[destPathString release];
		
		NSString* relPathString = [action.viewCtrl.selectedCell getPath];
		NSMutableFilePath* relPath = [[NSMutableFilePath alloc] initWithString:relPathString];
		NSString*itemName = [srcPath lastMember];
		StringTree_struct folderTree = StringTree_getBranch(&sourceTree, [relPathString UTF8String]);
		
		if([srcPath containsSubfoldersOf:projectPath])
		{
			if(StringTree_hasMember(&folderTree, [itemName UTF8String]) > -1)
			{
				[srcPath release];
				[destPath release];
				[projectPath release];
				[relPath release];
				showSimpleMessageBox("Error", "Cannot import file that is already in project");
				return;
			}
			else
			{
				NSFilePath* relPathSrc = [srcPath pathRelativeTo:projectPath];
				NSFilePath* relPathDest = [destPath pathRelativeTo:projectPath];
				if([relPathSrc isEqual:relPathDest])
				{
					StringTree_addMember(&folderTree, [itemName UTF8String]);
					StringList_struct branchNames = StringTree_getBranchNames(&folderTree);
					int index = StringList_size(&branchNames) + StringTree_hasMember(&folderTree, [itemName UTF8String]);
					ProjectTreeViewCell* cell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:itemName];
					[action.viewCtrl.selectedCell insertMember:cell atIndex:index];
					[cell release];
					
					ProjectData_saveProjectPlist(appDelegate.projData);
					
					[srcPath release];
					[destPath release];
					[projectPath release];
					[relPath release];
					
					action.operationHUD = [LGViewHUD defaultHUD];
					[action.operationHUD setTopText:@"Imported File"];
					[action.operationHUD setBottomText:@""];
					[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
					[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
					
					[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
					[action.operationHUD hideAfterDelay:0.5 withAnimation:HUDAnimationHideZoom];
					
					[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
					return;
				}
			}
		}
		else
		{
			if(FileTools_fileSize([[srcPath pathAsString] UTF8String]) < 25000000)
			{
				const char* destPathString = [[destPath pathAsString] UTF8String];
				if(FileTools_fileExists(destPathString))
				{
					if(StringTree_hasBranch(&folderTree, [itemName UTF8String])==-1)
					{
						FileTools_deleteFromFilesystem(destPathString);
					}
					else
					{
						StringTree_struct branch = StringTree_getBranch(&folderTree, [itemName UTF8String]);
						StringList_struct members = StringTree_getMembers(&branch);
						StringList_struct branchNames = StringTree_getBranchNames(&branch);
						if(StringList_size(&members)>0 || StringList_size(&branchNames)>0)
						{
							showSimpleMessageBox("Error", "Cannot import folder that is already in project");
							
							[srcPath release];
							[destPath release];
							[projectPath release];
							[relPath release];
							
							return;
						}
					}
				}
				
				[action showObstructionInView:action.fileBrowserCtrl.view];
				action.operationHUD = [LGViewHUD defaultHUD];
				[action.operationHUD setTopText:@"Importing File..."];
				[action.operationHUD setBottomText:@""];
				[action.operationHUD setActivityIndicatorOn:YES];
				[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
				
				performFileOperationThread([[srcPath pathAsString] UTF8String], destPathString, FILEOPERATION_COPYFILE, action, &ImportFileAction_FileOperationFinishCallback);
			}
			else
			{
				showSimpleMessageBox("Error", "To add a file larger than 25mb, you must manually copy the folder to the project and import it.");
			}
		}
		
		[srcPath release];
		[destPath release];
		[projectPath release];
		[relPath release];
	}
}

typedef struct
{
	void*data;
	int result;
} ImportFileAction_FileOperationPacket;

void ImportFileAction_FileOperationFinishCallback(void*data, int result)
{
	ImportFileAction_FileOperationPacket*packet = (ImportFileAction_FileOperationPacket*)malloc(sizeof(ImportFileAction_FileOperationPacket));
	packet->data = data;
	packet->result = result;
	runCallbackInMainThread(&ImportFileAction_FileOperationFinishHandler, packet, false);
}

void ImportFileAction_FileOperationFinishHandler(void*data)
{
	ImportFileAction_FileOperationPacket*packet = (ImportFileAction_FileOperationPacket*)data;
	ImportFileAction* action = (ImportFileAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		StringTree_struct sourceTree;
		NSString*categoryName = [action.viewCtrl.selectedCell getCategory];
		if([categoryName isEqual:@"src"])
		{
			sourceTree = ProjectData_getSourceFiles(appDelegate.projData);
		}
		else if([categoryName isEqual:@"res"])
		{
			sourceTree = ProjectData_getResourceFiles(appDelegate.projData);
		}
		else
		{
			showSimpleMessageBox("Error", "Unknown category name for selected UIProjectTreeViewCell");
			return;
		}
		
		NSString* projectsFolderString = [[NSString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		NSMutableFilePath* projectPath = [[NSMutableFilePath alloc] initWithString:projectsFolderString];
		[projectsFolderString release];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[projectPath addMember:saveFolder];
		[saveFolder release];
		[projectPath addMember:categoryName];
		
		NSMutableFilePath* srcPath = [[NSMutableFilePath alloc] initWithString:action.pendingPath];
		NSMutableString* destPathString = [[NSMutableString alloc] initWithString:[projectPath pathAsString]];
		[destPathString appendString:@"/"];
		[destPathString appendString:[action.viewCtrl.selectedCell getPath]];
		NSMutableFilePath* destPath = [[NSMutableFilePath alloc] initWithString:destPathString];
		[destPath addMember:[srcPath lastMember]];
		[destPathString release];
		
		NSString* relPathString = [action.viewCtrl.selectedCell getPath];
		NSMutableFilePath* relPath = [[NSMutableFilePath alloc] initWithString:relPathString];
		NSString*itemName = [srcPath lastMember];
		
		StringTree_struct folderTree = StringTree_getBranch(&sourceTree, [relPathString UTF8String]);
		StringTree_addMember(&folderTree, [itemName UTF8String]);
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		StringList_struct branchNames = StringTree_getBranchNames(&folderTree);
		int index = StringList_size(&branchNames) + StringTree_hasMember(&folderTree, [itemName UTF8String]);
		
		ProjectTreeViewCell* cell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:itemName];
		[action.viewCtrl.selectedCell insertMember:cell atIndex:index];
		[cell release];
		
		[action.obstructView removeFromSuperview];
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD setTopText:@"File Imported"];
		[action.operationHUD setBottomText:@""];
		[action.operationHUD hideWithAnimation:HUDAnimationHideZoom];
		
		[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
		
		[srcPath release];
		[destPath release];
		[projectPath release];
		[relPath release];
	}
	else
	{
		[action.obstructView removeFromSuperview];
		[UIImageManager loadImage:@"Images/rounded-failed.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[action.operationHUD setTopText:@"Import Failed"];
		[action.operationHUD setBottomText:@""];
		[action.operationHUD hideWithAnimation:HUDAnimationHideZoom];
		
		showSimpleMessageBox("Error", "Error copying file");
	}
}

