
#import "MoveAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/UIImageManager.h"
#import "../../Util/FileOperationThread.h"

@interface MoveAction()
- (void)onFileBrowserMoveButtonSelected;
@end

void MoveAction_AlertViewDismissHandler(void*data, int buttonIndex);
void MoveAction_FileOperationFinishCallback(void*data, int result);
void MoveAction_FileOperationFinishHandler(void*data);

@implementation MoveAction

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	NSString* slashString = [[NSString alloc] initWithUTF8String:"/"];
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectData_struct* projData = appDelegate.projData;
	
	NSMutableString* projectRoot = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
	[projectRoot appendString:slashString];
	NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(projData)];
	[projectRoot appendString:saveFolder];
	[saveFolder release];
	[projectRoot appendString:slashString];
	NSString* categoryName = [projectTreeViewController.selectedCell getCategory];
	if(![categoryName isEqual:@"src"] && ![categoryName isEqual:@"res"])
	{
		[slashString release];
		[projectRoot release];
		[self release];
		return nil;
	}
	[projectRoot appendString:categoryName];
	
	self = [super initWithProjectTreeViewController:projectTreeViewController path:slashString root:projectRoot];
	if(self==nil)
	{
		[slashString release];
		[projectRoot release];
		return nil;
	}
	
	[slashString release];
	[projectRoot release];
	return self;
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated
{
	[self release];
}

- (void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	if(navigationController==self.fileBrowserCtrl)
	{
		UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Move" style:UIBarButtonItemStyleDone target:self action:@selector(onFileBrowserMoveButtonSelected)];
		[viewController.navigationItem setRightBarButtonItem:selectButton];
		[selectButton release];
	}
}

- (void)onFileBrowserMoveButtonSelected
{
	const char* buttons[2] = {"Cancel", "Confirm"};
	showSimpleMessageBox("Move Here?", NULL, buttons, 2, self, &MoveAction_AlertViewDismissHandler, NULL);
}

@end

void MoveAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	MoveAction* action = (MoveAction*)data;
	if(buttonIndex==1)
	{
		NSMutableFilePath* relDest = [[NSMutableFilePath alloc] initWithFilePath:action.fileBrowserCtrl.path];
		NSFilePath* relSrc = [[NSFilePath alloc] initWithString:[action.viewCtrl.selectedCell getPath]];
		[relDest addMember:[relSrc lastMember]];
		if([relDest isEqual:relSrc])
		{
			showSimpleMessageBox("Error", "Source path and destination path cannot be the same");
			[relSrc release];
			[relDest release];
			return;
		}
		else if(action.viewCtrl.selectedCell.type==PROJECTTREECELL_FOLDER && [relDest containsSubfoldersOf:relSrc])
		{
			showSimpleMessageBox("Error", "Cannot move a folder inside of itself");
			[relSrc release];
			[relDest release];
			return;
		}
		else
		{
			NSFilePath* destFullPath = [[NSFilePath alloc] initWithFilePaths:action.fileBrowserCtrl.root, relDest, nil];
			NSFilePath* srcFullPath = [[NSFilePath alloc] initWithFilePaths:action.fileBrowserCtrl.root, relSrc, nil];
			[relSrc release];
			[relDest release];
			if(action.viewCtrl.selectedCell.type==PROJECTTREECELL_FOLDER)
			{
				const char* destFullPathString = [[destFullPath pathAsString] UTF8String];
				if(FileTools_folderExists(destFullPathString))
				{
					showSimpleMessageBox("Error", "Destination folder already exists");
					[destFullPath release];
					[srcFullPath release];
					return;
				}
				else
				{
					performFileOperationThread([[srcFullPath pathAsString] UTF8String], destFullPathString, FILEOPERATION_MOVE, action, &MoveAction_FileOperationFinishCallback);
				}
			}
			else if(action.viewCtrl.selectedCell.type==PROJECTTREECELL_FILE)
			{
				const char* destFullPathString = [[destFullPath pathAsString] UTF8String];
				if(FileTools_fileExists(destFullPathString))
				{
					showSimpleMessageBox("Error", "Destination file already exists");
					[destFullPath release];
					[srcFullPath release];
					return;
				}
				else
				{
					performFileOperationThread([[srcFullPath pathAsString] UTF8String], destFullPathString, FILEOPERATION_MOVE, action, &MoveAction_FileOperationFinishCallback);
				}
			}
			else
			{
				showSimpleMessageBox("Error", "Unknown cell type");
				[destFullPath release];
				[srcFullPath release];
				return;
			}
			[destFullPath release];
			[srcFullPath release];
			
			[action showObstructionInView:action.fileBrowserCtrl.view];
			action.operationHUD = [LGViewHUD defaultHUD];
			[action.operationHUD setTopText:@"Moving..."];
			[action.operationHUD setBottomText:@""];
			[action.operationHUD setActivityIndicatorOn:YES];
			[action.operationHUD showInView:action.fileBrowserCtrl.view];
		}
	}
}

typedef struct
{
	void*data;
	int result;
} MoveAction_FileOperationPacket;

void MoveAction_FileOperationFinishCallback(void*data, int result)
{
	MoveAction_FileOperationPacket*packet = (MoveAction_FileOperationPacket*)malloc(sizeof(MoveAction_FileOperationPacket));
	packet->data = data;
	packet->result = result;
	runCallbackInMainThread(&MoveAction_FileOperationFinishHandler, packet, false);
}

void MoveAction_FileOperationFinishHandler(void*data)
{
	MoveAction_FileOperationPacket*packet = (MoveAction_FileOperationPacket*)data;
	MoveAction* action = (MoveAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		ProjectData_struct* projData = appDelegate.projData;
		
		NSFilePath* srcPath = [[NSFilePath alloc] initWithString:[action.viewCtrl.selectedCell getPath]];
		NSString* itemName = [[srcPath lastMember] retain];
		NSMutableFilePath* srcFolder = [[NSMutableFilePath alloc] initWithFilePath:srcPath];
		[srcFolder removeLastMember];
		NSMutableFilePath* destPath = [[NSMutableFilePath alloc] initWithFilePath:action.fileBrowserCtrl.path];
		NSFilePath* destFolder = [[NSFilePath alloc] initWithFilePath:destPath];
		[destPath addMember:itemName];
		
		StringTree_struct sourceTree;
		ProjectTreeViewCell* sourceCell;
		NSString* categoryName = [action.viewCtrl.selectedCell getCategory];
		if([categoryName isEqual:@"src"])
		{
			sourceTree = ProjectData_getSourceFiles(projData);
			sourceCell = action.viewCtrl.srcCell;
		}
		else if([categoryName isEqual:@"res"])
		{
			sourceTree = ProjectData_getResourceFiles(projData);
			sourceCell = action.viewCtrl.resCell;
		}
		else
		{
			[srcPath release];
			[itemName release];
			[srcFolder release];
			[destPath release];
			[destFolder release];
			showSimpleMessageBox("Error", "Unknown category name");
			return;
		}
		
		StringTree_struct folderTree = sourceTree;
		ProjectTreeViewCell* folderCell = sourceCell;
		for(int i=0; i<[destFolder count]; i++)
		{
			NSString* member = [destFolder memberAtIndex:i];
			int branchIndex = StringTree_hasBranch(&folderTree, [member UTF8String]);
			if(branchIndex==-1)
			{
				StringTree_addBranch(&folderTree, [member UTF8String]);
				branchIndex = StringTree_hasBranch(&folderTree, [member UTF8String]);
				
				ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FOLDER identifier:member];
				[folderCell insertMember:pcell atIndex:branchIndex];
				[pcell release];
			}
			
			folderTree = StringTree_getBranch(&folderTree, [member UTF8String]);
			[folderCell setBranchOpen:YES];
			folderCell = (ProjectTreeViewCell*)[folderCell memberAtIndex:(NSUInteger)branchIndex];
		}
		
		if(action.viewCtrl.selectedCell.type==PROJECTTREECELL_FOLDER)
		{
			int branchIndex = StringTree_hasBranch(&folderTree, [itemName UTF8String]);
			if(branchIndex==-1)
			{
				StringTree_addBranch(&folderTree, [itemName UTF8String]);
				branchIndex = StringTree_hasBranch(&folderTree, [itemName UTF8String]);
				ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FOLDER identifier:itemName];
				[folderCell insertMember:pcell atIndex:branchIndex];
				[pcell release];
			}
			
			folderTree = StringTree_getBranch(&folderTree, [itemName UTF8String]);
			[folderCell setBranchOpen:YES];
			folderCell = (ProjectTreeViewCell*)[folderCell memberAtIndex:(NSUInteger)branchIndex];
			
			NSFilePath* destPathFull = [[NSFilePath alloc] initWithFilePaths:action.fileBrowserCtrl.root, destPath, nil];
			StringTree_struct*contents = FileTools_getStringTreeFromDirectory([[destPathFull pathAsString] UTF8String]);
			StringTree_merge(&folderTree, contents);
			[folderCell removeAllMembers];
			[ProjectTreeViewController addStringTreeToCell:folderCell tree:contents];
			StringTree_destroyInstance(contents);
			[destPathFull release];
		}
		else if(action.viewCtrl.selectedCell.type==PROJECTTREECELL_FILE)
		{
			int memberIndex = StringTree_hasMember(&folderTree, [itemName UTF8String]);
			if(memberIndex==-1)
			{
				StringTree_addMember(&folderTree, [itemName UTF8String]);
				StringList_struct branchNames = StringTree_getBranchNames(&folderTree);
				int totalBranches = StringList_size(&branchNames);
				memberIndex = StringTree_hasMember(&folderTree, [itemName UTF8String]) + totalBranches;
				ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:itemName];
				[folderCell insertMember:pcell atIndex:memberIndex];
				[pcell release];
			}
		}
		
		StringTree_struct oldTree = StringTree_getBranch(&sourceTree, [[srcFolder pathAsString] UTF8String]);
		if(action.viewCtrl.selectedCell.type==PROJECTTREECELL_FOLDER)
		{
			StringTree_removeBranch(&oldTree, [itemName UTF8String]);
		}
		else if(action.viewCtrl.selectedCell.type==PROJECTTREECELL_FILE)
		{
			StringTree_removeMember(&oldTree, [itemName UTF8String]);
		}
		[action.viewCtrl.selectedCell.supercell removeMember:action.viewCtrl.selectedCell];
		
		ProjectData_saveProjectPlist(projData);
		
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Moved"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideZoom];
		
		[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
		
		[itemName release];
		[srcPath release];
		[srcFolder release];
		[destPath release];
		[destFolder release];
	}
	else
	{
		if(action.viewCtrl.selectedCell.type == PROJECTTREECELL_FOLDER)
		{
			showSimpleMessageBox("Error", "Error moving folder");
		}
		else
		{
			showSimpleMessageBox("Error", "Error moving file");
		}
		
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Move Failed"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-fail.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[action.operationHUD hideAfterDelay:0.5 withAnimation:HUDAnimationHideFadeOut];
	}
	
}





