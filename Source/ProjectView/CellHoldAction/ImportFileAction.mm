
#import "ImportFileAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/UIImageManager.h"
#import "../../Util/FileOperationThread.h"
#import <unistd.h>


@interface ImportFileAction()
- (void)onFileBrowserCancelButtonSelected;
- (void)onFileBrowserImportAllButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@property (nonatomic) BOOL copyingBranches;
@property (nonatomic) StringTree_struct* contents;
@property (nonatomic) StringTree_struct destBranch;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, assign) NSString* srcFolder;
@property (nonatomic, assign) NSString* dstFolder;
@end


void ImportFileAction_AlertViewDismissHandler(void*data, int buttonIndex);
void ImportFileAction_FileOperationFinishCallback(void*data, int result);
void ImportFileAction_FileOperationFinishHandler(void*data);

void ImportAllFilesAction_AlertViewDismissHandler(void*data, int buttonIndex);
void ImportAllFilesAction_FileOperationFinishCallback(void*data, int result);
void ImportAllFilesAction_FileOperationFinishHandler(void*data);


@implementation ImportFileAction

@synthesize pendingPath;
@synthesize copyingBranches;
@synthesize contents;
@synthesize destBranch;
@synthesize currentIndex;
@synthesize srcFolder;
@synthesize dstFolder;

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
	
	contents = NULL;
	copyingBranches = NO;
	currentIndex = 0;
	
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

- (void)setSrcFolder:(NSString*)src
{
	[srcFolder release];
	if([src length]>0 && [src UTF8String][[src length]-1]=='/')
	{
		srcFolder = [[src substringToIndex:([src length]-1)] retain];
	}
	else
	{
		srcFolder = [[NSString alloc] initWithString:src];
	}
}

- (void)setDstFolder:(NSString*)dst
{
	[dstFolder release];
	if([dst length]>0 && [dst UTF8String][[dst length]-1]=='/')
	{
		dstFolder = [[dst substringToIndex:([dst length]-1)] retain];
	}
	else
	{
		dstFolder = [[NSString alloc] initWithString:dst];
	}
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
			UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Import All" style:UIBarButtonItemStyleDone target:self action:@selector(onFileBrowserImportAllButtonSelected)];
			[viewController.navigationItem setRightBarButtonItem:selectButton];
			[selectButton release];
		}
	}
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

- (void)onFileBrowserImportAllButtonSelected
{
	NSFilePath* fullPath = [[NSFilePath alloc] initWithFilePaths:fileBrowserCtrl.root, fileBrowserCtrl.path, nil];
	self.pendingPath = [fullPath pathAsString];
	[fullPath release];
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Would you like to import the contents of this folder?"];
	const char* buttons[2] = {"Cancel", "Confirm"};
	showSimpleMessageBox("Import Files", [message UTF8String], buttons, 2, self, &ImportAllFilesAction_AlertViewDismissHandler, NULL);
	[message release];
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated
{
	[self release];
}

- (void)dealloc
{
	[pendingPath release];
	[srcFolder release];
	[dstFolder release];
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

void ImportAllFilesAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	ImportFileAction* action = (ImportFileAction*)data;
	
	if(buttonIndex==1)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		ProjectData_struct* projData = appDelegate.projData;
		
		NSMutableString* srcFolderPathString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[srcFolderPathString appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(projData)];
		[srcFolderPathString appendString:saveFolder];
		[saveFolder release];
		NSString* categoryName = [action.viewCtrl.selectedCell getCategory];
		if([categoryName isEqual:@"src"])
		{
			[srcFolderPathString appendString:@"/src"];
		}
		else if([categoryName isEqual:@"res"])
		{
			[srcFolderPathString appendString:@"/res"];
		}
		else
		{
			showSimpleMessageBox("Error", "Unrecognized category for cell");
			[srcFolderPathString release];
			return;
		}
		
		char* fullPathPtr = (char*)malloc(PATH_MAX);
		if(realpath([srcFolderPathString UTF8String], fullPathPtr)==NULL)
		{
			free(fullPathPtr);
			[srcFolderPathString release];
			showSimpleMessageBox("Error", "Unable to expand src folder path");
			return;
		}
		
		saveFolder = [[NSString alloc] initWithUTF8String:fullPathPtr];
		[srcFolderPathString setString:saveFolder];
		[saveFolder release];
		free(fullPathPtr);
		
		NSFilePath* srcFolderPath = [[NSFilePath alloc] initWithString:srcFolderPathString];
		
		fullPathPtr = (char*)malloc(PATH_MAX);
		if(realpath([action.pendingPath UTF8String], fullPathPtr)==NULL)
		{
			free(fullPathPtr);
			[srcFolderPathString release];
			[srcFolderPath release];
			showSimpleMessageBox("Error", "Unable to expand source path");
			return;
		}
		
		saveFolder = [[NSString alloc] initWithUTF8String:fullPathPtr];
		NSFilePath* pendingPath = [[NSFilePath alloc] initWithString:saveFolder];
		NSString* pendingPathString = [pendingPath pathAsString];
		[saveFolder release];
		free(fullPathPtr);
		
		NSString* selectedRelPathString = [action.viewCtrl.selectedCell getPath];
		NSFilePath* selectedRelPath = [[NSFilePath alloc] initWithString:selectedRelPathString];
		
		if([pendingPath containsSubfoldersOf:srcFolderPath])
		{
			NSString* pendingPathString = [pendingPath pathAsString];
			
			NSFilePath* relPath = [pendingPath pathRelativeTo:srcFolderPath];
			if([relPath isEqual:selectedRelPath])
			{
				NSString* relPathString = [relPath pathAsString];
				
				StringTree_struct* contents = FileTools_getStringTreeFromDirectory([pendingPathString UTF8String]);
				
				StringTree_struct sourceTree;
				if([categoryName isEqual:@"src"])
				{
					sourceTree = ProjectData_getSourceFiles(projData);
				}
				else if([categoryName isEqual:@"res"])
				{
					sourceTree = ProjectData_getResourceFiles(projData);
				}
				
				StringTree_struct folderTree = StringTree_getBranch(&sourceTree, [relPathString UTF8String]);
				
				ProjectTreeViewCell* cell = action.viewCtrl.selectedCell;
				
				StringTree_clear(&folderTree);
				[cell removeAllMembers];
				
				StringTree_merge(&folderTree, contents);
				[ProjectTreeViewController addStringTreeToCell:cell tree:&folderTree];
				
				ProjectData_saveProjectPlist(projData);
				
				[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
				[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
				[action.operationHUD setTopText:@"Files Imported"];
				[action.operationHUD setBottomText:@""];
				
				[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
				[action.operationHUD hideAfterDelay:0.5 withAnimation:HUDAnimationHideZoom];
				
				[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
				
				StringTree_destroyInstance(contents);
				[srcFolderPathString release];
				[srcFolderPath release];
				[pendingPath release];
				[selectedRelPath release];
				return;
			}
			else if([selectedRelPath containsSubfoldersOf:relPath])
			{
				showSimpleMessageBox("Error", "Destination is inside source");
				
				[srcFolderPathString release];
				[srcFolderPath release];
				[pendingPath release];
				[selectedRelPath release];
				return;
			}
		}
		
		NSString* slashString = [[NSString alloc] initWithUTF8String:"/"];
		
		NSString* relPathString = [action.viewCtrl.selectedCell getPath];
		StringTree_struct* contents = FileTools_getStringTreeFromDirectory([pendingPathString UTF8String]);
		
		StringList_struct branchNames = StringTree_getBranchNames(contents);
		for(int i=0; i<StringList_size(&branchNames); i++)
		{
			NSMutableString* fullPath = [[NSMutableString alloc] initWithString:srcFolderPathString];
			[fullPath appendString:slashString];
			[fullPath appendString:relPathString];
			NSString* branchName = [[NSString alloc] initWithUTF8String:StringList_get(&branchNames, i)];
			[fullPath appendString:branchName];
			[branchName release];
			
			if(FileTools_fileExists([fullPath UTF8String]) || FileTools_folderExists([fullPath UTF8String]))
			{
				showSimpleMessageBox("Error", "Destination folder already exists");
				
				[srcFolderPathString release];
				[srcFolderPath release];
				[pendingPath release];
				[selectedRelPath release];
				[fullPath release];
				[slashString release];
				return;
			}
			[fullPath release];
		}
		
		StringList_struct members = StringTree_getMembers(contents);
		for(int i=0; i<StringList_size(&members); i++)
		{
			NSMutableString* fullPath = [[NSMutableString alloc] initWithString:srcFolderPathString];
			[fullPath appendString:slashString];
			[fullPath appendString:relPathString];
			NSString* memberName = [[NSString alloc] initWithUTF8String:StringList_get(&members, i)];
			[fullPath appendString:memberName];
			[memberName release];
			
			if(FileTools_fileExists([fullPath UTF8String]) || FileTools_folderExists([fullPath UTF8String]))
			{
				showSimpleMessageBox("Error", "Destination file already exists");
				
				[srcFolderPathString release];
				[srcFolderPath release];
				[pendingPath release];
				[selectedRelPath release];
				[fullPath release];
				[slashString release];
				return;
			}
			[fullPath release];
		}
		
		action.contents = contents;
		
		StringTree_struct sourceTree;
		if([categoryName isEqual:@"src"])
		{
			sourceTree = ProjectData_getSourceFiles(projData);
		}
		else if([categoryName isEqual:@"res"])
		{
			sourceTree = ProjectData_getResourceFiles(projData);
		}
		action.destBranch = StringTree_getBranch(&sourceTree, [[action.viewCtrl.selectedCell getPath] UTF8String]);
		
		if(StringList_size(&branchNames)>0)
		{
			action.copyingBranches = YES;
			action.currentIndex = 0;
			
			NSMutableString* srcFolder = [[NSMutableString alloc] initWithString:pendingPathString];
			action.srcFolder = srcFolder;
			NSString* folderName = [[NSString alloc] initWithUTF8String:StringList_get(&branchNames, 0)];
			[srcFolder appendString:slashString];
			[srcFolder appendString:folderName];
			
			NSMutableString* destFolder = [[NSMutableString alloc] initWithString:srcFolderPathString];
			[destFolder appendString:slashString];
			[destFolder appendString:selectedRelPathString];
			action.dstFolder = selectedRelPathString;
			[destFolder appendString:folderName];
			
			[action showObstructionInView:action.fileBrowserCtrl.view];
			action.operationHUD = [LGViewHUD defaultHUD];
			[action.operationHUD setTopText:@"Importing Files..."];
			[action.operationHUD setBottomText:@""];
			[action.operationHUD setActivityIndicatorOn:YES];
			[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
			
			performFileOperationThread([srcFolder UTF8String], [destFolder UTF8String], FILEOPERATION_COPYFOLDER, action, &ImportAllFilesAction_FileOperationFinishCallback);
			
			[srcFolder release];
			[destFolder release];
			[folderName release];
			[srcFolderPathString release];
			[srcFolderPath release];
			[pendingPath release];
			[selectedRelPath release];
			[slashString release];
		}
		else if(StringList_size(&members)>0)
		{
			action.copyingBranches = NO;
			action.currentIndex = 0;
			
			NSMutableString* srcFile = [[NSMutableString alloc] initWithString:pendingPathString];
			action.srcFolder = srcFile;
			NSString* fileName = [[NSString alloc] initWithUTF8String:StringList_get(&members, 0)];
			[srcFile appendString:slashString];
			[srcFile appendString:fileName];
			
			NSMutableString* destFile = [[NSMutableString alloc] initWithString:srcFolderPathString];
			[destFile appendString:slashString];
			[destFile appendString:selectedRelPathString];
			action.dstFolder = destFile;
			[destFile appendString:fileName];
			
			[action showObstructionInView:action.fileBrowserCtrl.view];
			action.operationHUD = [LGViewHUD defaultHUD];
			[action.operationHUD setTopText:@"Importing Files..."];
			[action.operationHUD setBottomText:@""];
			[action.operationHUD setActivityIndicatorOn:YES];
			[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
			
			performFileOperationThread([srcFile UTF8String], [destFile UTF8String], FILEOPERATION_COPYFILE, action, &ImportAllFilesAction_FileOperationFinishCallback);
			
			[srcFile release];
			[destFile release];
			[fileName release];
			[srcFolderPathString release];
			[srcFolderPath release];
			[pendingPath release];
			[selectedRelPath release];
			[slashString release];
		}
		else
		{
			StringTree_destroyInstance(contents);
			action.contents = NULL;
			
			[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
			[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
			[action.operationHUD setTopText:@"Files Imported"];
			[action.operationHUD setBottomText:@""];
			
			[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
			[action.operationHUD hideAfterDelay:0.5 withAnimation:HUDAnimationHideZoom];
			
			[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
			
			[srcFolderPathString release];
			[srcFolderPath release];
			[pendingPath release];
			[selectedRelPath release];
			[slashString release];
		}
	}
}

void ImportAllFilesAction_FileOperationFinishCallback(void*data, int result)
{
	ImportFileAction* action = (ImportFileAction*)data;
	
	if(result==0)
	{
		//iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		BOOL finished = NO;
		
		if(action.copyingBranches)
		{
			StringList_struct branchNames = StringTree_getBranchNames(action.contents);
			NSString* branchName = [[NSString alloc] initWithUTF8String:StringList_get(&branchNames, action.currentIndex)];
			NSMutableString* destPath = [[NSMutableString alloc] initWithString:action.dstFolder];
			[destPath appendString:@"/"];
			[destPath appendString:branchName];
			
			StringTree_struct branchContents = StringTree_getBranch(action.contents, [branchName UTF8String]);
			ProjectTreeViewCell* cell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FOLDER identifier:branchName];
			[ProjectTreeViewController addStringTreeToCell:cell tree:&branchContents];
			
			StringTree_struct destBranch = action.destBranch;
			StringTree_addBranch(&destBranch, [branchName UTF8String], &branchContents);
			int index = StringTree_hasBranch(&destBranch, [branchName UTF8String]);
			[action.viewCtrl.selectedCell insertMember:cell atIndex:index];
			[cell release];
			
			[branchName release];
			[destPath release];
			
			action.currentIndex++;
			branchNames = StringTree_getBranchNames(action.contents);
			if(action.currentIndex>=StringList_size(&branchNames))
			{
				action.currentIndex = 0;
				action.copyingBranches = NO;
			}
			
			StringList_struct memberNames = StringTree_getMembers(&destBranch);
			if(StringList_size(&memberNames)==0)
			{
				finished = YES;
			}
		}
		else
		{
			StringList_struct memberNames = StringTree_getMembers(action.contents);
			NSString* memberName = [[NSString alloc] initWithUTF8String:StringList_get(&memberNames, action.currentIndex)];
			NSMutableString* destPath = [[NSMutableString alloc] initWithString:action.dstFolder];
			[destPath appendString:@"/"];
			[destPath appendString:memberName];
			
			ProjectTreeViewCell* cell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:memberName];
			
			StringTree_struct destBranch = action.destBranch;
			StringList_struct branchNames = StringTree_getBranchNames(&destBranch);
			StringTree_addMember(&destBranch, [memberName UTF8String]);
			int index = StringTree_hasMember(&destBranch, [memberName UTF8String]) + StringList_size(&branchNames);
			[action.viewCtrl.selectedCell insertMember:cell atIndex:index];
			[cell release];
			
			[memberName release];
			[destPath release];
			
			action.currentIndex++;
			memberNames = StringTree_getMembers(action.contents);
			if(action.currentIndex>=StringList_size(&memberNames))
			{
				action.currentIndex = 0;
				action.copyingBranches = NO;
				finished = YES;
			}
		}
		
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		if(action.copyingBranches)
		{
			StringList_struct branchNames = StringTree_getBranchNames(action.contents);
			
			NSString* branchName = [[NSString alloc] initWithUTF8String:StringList_get(&branchNames, action.currentIndex)];
			
			NSMutableString* srcPath = [[NSMutableString alloc] initWithString:action.srcFolder];
			[srcPath appendString:@"/"];
			[srcPath appendString:branchName];
			
			NSMutableString* destPath = [[NSMutableString alloc] initWithString:action.dstFolder];
			[destPath appendString:@"/"];
			[destPath appendString:branchName];
			
			performFileOperationThread([srcPath UTF8String], [destPath UTF8String], FILEOPERATION_COPYFOLDER, action, &ImportAllFilesAction_FileOperationFinishCallback);
			
			[srcPath release];
			[destPath release];
		}
		else if(!finished)
		{
			StringList_struct memberNames = StringTree_getMembers(action.contents);
			
			NSString* memberName = [[NSString alloc] initWithUTF8String:StringList_get(&memberNames, action.currentIndex)];
			
			NSMutableString* srcPath = [[NSMutableString alloc] initWithString:action.srcFolder];
			[srcPath appendString:@"/"];
			[srcPath appendString:memberName];
			
			NSMutableString* destPath = [[NSMutableString alloc] initWithString:action.dstFolder];
			[destPath appendString:@"/"];
			[destPath appendString:memberName];
			
			performFileOperationThread([srcPath UTF8String], [destPath UTF8String], FILEOPERATION_COPYFILE, action, &ImportAllFilesAction_FileOperationFinishCallback);
			
			[srcPath release];
			[destPath release];
		}
		else
		{
			StringTree_destroyInstance(action.contents);
			action.contents = NULL;
			
			ImportFileAction_FileOperationPacket*packet = (ImportFileAction_FileOperationPacket*)malloc(sizeof(ImportFileAction_FileOperationPacket));
			packet->data = data;
			packet->result = result;
			runCallbackInMainThread(&ImportAllFilesAction_FileOperationFinishHandler, packet, false);
		}
	}
	else
	{
		ImportFileAction_FileOperationPacket*packet = (ImportFileAction_FileOperationPacket*)malloc(sizeof(ImportFileAction_FileOperationPacket));
		packet->data = data;
		packet->result = result;
		runCallbackInMainThread(&ImportAllFilesAction_FileOperationFinishHandler, packet, false);
	}
}

void ImportAllFilesAction_FileOperationFinishHandler(void*data)
{
	ImportFileAction_FileOperationPacket*packet = (ImportFileAction_FileOperationPacket*)data;
	ImportFileAction* action = (ImportFileAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0)
	{
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD setTopText:@"Files Imported"];
		[action.operationHUD setBottomText:@""];
		
		[action.operationHUD hideAfterDelay:0.5 withAnimation:HUDAnimationHideZoom];
		
		[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[action.obstructView removeFromSuperview];
		[UIImageManager loadImage:@"Images/rounded-failed.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[action.operationHUD setTopText:@"Import Failed"];
		[action.operationHUD setBottomText:@""];
		[action.operationHUD hideWithAnimation:HUDAnimationHideZoom];
		
		showSimpleMessageBox("Error", "Unable to copy all files");
		
		action.copyingBranches = NO;
		action.currentIndex = 0;
	}
}

