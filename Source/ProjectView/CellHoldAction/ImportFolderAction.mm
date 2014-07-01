
#import "ImportFolderAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/UIImageManager.h"
#import "../../Util/FileOperationThread.h"
#import <unistd.h>


@interface ImportFolderAction()
- (void)onFileBrowserCancelButtonSelected;
- (void)onFileBrowserSelectButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@end


void ImportFolderAction_AlertViewDismissHandler(void*data, int buttonIndex);
void ImportFolderAction_FileOperationFinishCallback(void*data, int result);
void ImportFolderAction_FileOperationFinishHandler(void*data);


@implementation ImportFolderAction

@synthesize pendingPath;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
#if (TARGET_IPHONE_SIMULATOR)
	if([super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:@"/Users"]==nil)
	{
		return nil;
	}
#else
	NSString* userDir = [[NSString alloc] initWithUTF8String:getenv("HOME")];
	if([super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:userDir]==nil)
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
	[self.fileBrowserCtrl.globalToolbar setItems:toolbarItems];
	[toolbarItems release];
	
	return self;
}

- (void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	if(navigationController==fileBrowserCtrl)
	{
		if([navigationController.viewControllers count]>0 && viewController==[navigationController.viewControllers objectAtIndex:0])
		{
			[viewController.navigationItem setRightBarButtonItem:nil];
		}
		else if(navigationController.topViewController!=nil)
		{
			UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(onFileBrowserSelectButtonSelected)];
			[viewController.navigationItem setRightBarButtonItem:selectButton];
			[selectButton release];
		}
	}
}

- (void)onFileBrowserCancelButtonSelected
{
	[self.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
}

- (void)onFileBrowserSelectButtonSelected
{
	NSMutableFilePath* fullPath = [[NSMutableFilePath alloc] initWithFilePath:fileBrowserCtrl.root];
	[fullPath appendPath:fileBrowserCtrl.path];
	self.pendingPath = [NSString stringWithString:[fullPath pathAsString]];
	NSString* folder = [[fullPath lastMember] retain];
	[fullPath release];
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Would you like to import the folder \""];
	NSString* title = [[NSString alloc] initWithUTF8String:"Import Folder"];
	
	[message appendString:folder];
	[message appendString:@"\"?"];
	
	const char* buttons[2] = {"Cancel", "Confirm"};
	showSimpleMessageBox([title UTF8String], [message UTF8String], buttons, 2, self, &ImportFolderAction_AlertViewDismissHandler, NULL);
	[message release];
	[title release];
	
	[folder release];
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

void ImportFolderAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	ImportFolderAction* action = (ImportFolderAction*)data;
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
			if(StringTree_hasBranch(&folderTree, [itemName UTF8String])!=-1)
			{
				[srcPath release];
				[destPath release];
				[projectPath release];
				[relPath release];
				showSimpleMessageBox("Error", "Cannot import folder that is already in project");
				return;
			}
			else
			{
				NSFilePath* relPathSrc = [srcPath pathRelativeTo:projectPath];
				NSFilePath* relPathDest = [destPath pathRelativeTo:projectPath];
				if([relPathSrc isEqual:relPathDest])
				{
					StringTree_struct* dirTree = FileTools_getStringTreeFromDirectory([[destPath pathAsString] UTF8String]);
					StringTree_addBranch(&folderTree, [itemName UTF8String], dirTree);
					StringList_struct branchNames = StringTree_getBranchNames(&folderTree);
					int index = StringTree_hasMember(&folderTree, [itemName UTF8String]);
					ProjectTreeViewCell* cell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FOLDER identifier:itemName];
					[action.viewCtrl.selectedCell insertMember:cell atIndex:index];
					
					[ProjectTreeViewController addStringTreeToCell:cell tree:dirTree];
					StringTree_destroyInstance(dirTree);
					
					ProjectData_saveProjectPlist(appDelegate.projData);
					
					[cell release];
					
					[srcPath release];
					[destPath release];
					[projectPath release];
					[relPath release];
					
					action.operationHUD = [LGViewHUD defaultHUD];
					[action.operationHUD setTopText:@"Imported Folder"];
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
		
		const char*destPathPtr = [[destPath pathAsString] UTF8String];
		if(StringTree_hasBranch(&folderTree, [itemName UTF8String])!=-1)
		{
			if(FileTools_directoryContainsFiles(destPathPtr))
			{
				showSimpleMessageBox("Error", "Cannot import folder that is already in project");
				
				[srcPath release];
				[destPath release];
				[projectPath release];
				[relPath release];
				return;
			}
		}
		
		if(FileTools_folderSize([[srcPath pathAsString] UTF8String]) < 25000000)
		{
			[action showObstructionInView:action.fileBrowserCtrl.view];
			action.operationHUD = [LGViewHUD defaultHUD];
			[action.operationHUD setTopText:@"Importing Folder..."];
			[action.operationHUD setBottomText:@""];
			[action.operationHUD setActivityIndicatorOn:YES];
			[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
			
			performFileOperationThread([[srcPath pathAsString] UTF8String], destPathPtr, FILEOPERATION_COPYFOLDER, action, &ImportFolderAction_FileOperationFinishCallback);
		}
		else
		{
			showSimpleMessageBox("Error", "To add a folder larger than 25mb, you must manually copy the folder to the project and import it.");
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
} ImportFolderAction_FileOperationPacket;

void ImportFolderAction_FileOperationFinishCallback(void*data, int result)
{
	ImportFolderAction_FileOperationPacket*packet = (ImportFolderAction_FileOperationPacket*)malloc(sizeof(ImportFolderAction_FileOperationPacket));
	packet->data = data;
	packet->result = result;
	runCallbackInMainThread(&ImportFolderAction_FileOperationFinishHandler, packet, false);
}

void ImportFolderAction_FileOperationFinishHandler(void*data)
{
	ImportFolderAction_FileOperationPacket*packet = (ImportFolderAction_FileOperationPacket*)data;
	ImportFolderAction* action = (ImportFolderAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0) //success
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
		
		int hasBranch = StringTree_hasBranch(&folderTree, [itemName UTF8String]);
		if(hasBranch==-1)
		{
			StringTree_addBranch(&folderTree, [itemName UTF8String]);
		}
		int index = StringTree_hasBranch(&folderTree, [itemName UTF8String]);
		ProjectTreeViewCell* cell = nil;
		if(hasBranch==-1)
		{
			cell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FOLDER identifier:itemName];
			[action.viewCtrl.selectedCell insertMember:cell atIndex:index];
		}
		else
		{
			cell = [action.viewCtrl.selectedCell.cells objectAtIndex:index];
		}
		
		StringTree_struct* dirTree = FileTools_getStringTreeFromDirectory([[destPath pathAsString] UTF8String]);
		StringTree_struct branch = StringTree_getBranch(&folderTree, [itemName UTF8String]);
		StringTree_merge(&branch, dirTree);
		[ProjectTreeViewController addStringTreeToCell:cell tree:dirTree];
		StringTree_destroyInstance(dirTree);
		
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		if(hasBranch==-1)
		{
			[cell release];
		}
		
		[action.obstructView removeFromSuperview];
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD setTopText:@"Folder Imported"];
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
		
		showSimpleMessageBox("Error", "Error copying folder");
	}
}
