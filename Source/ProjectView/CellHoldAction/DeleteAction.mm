
#import "DeleteAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/FileOperationThread.h"
#import "../../Util/UIImageManager.h"


void DeleteAction_AlertViewDismissHandler(void*data, int buttonIndex);
void DeleteAction_FileOperationFinishCallback(void*data, int result);
void DeleteAction_FileOperationFinishHandler(void*data);


@implementation DeleteAction

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	self = [super initWithProjectTreeViewController:projectTreeViewController];
	if(self==nil)
	{
		return nil;
	}
	
	if(viewCtrl.selectedCell.type==PROJECTTREECELL_FILE)
	{
		const char* buttons[2] = {"Cancel", "Confirm"};
		showSimpleMessageBox("Delete File", "Are you sure you want to delete this file? This action cannot be undone.",
							 buttons, 2, self, &DeleteAction_AlertViewDismissHandler, NULL);
	}
	else if(viewCtrl.selectedCell.type==PROJECTTREECELL_FOLDER)
	{
		const char* buttons[2] = {"Cancel", "Confirm"};
		showSimpleMessageBox("Delete Folder", "Are you sure you want to delete this folder? This action cannot be undone.",
							 buttons, 2, self, &DeleteAction_AlertViewDismissHandler, NULL);
	}
	
	return self;
}

@end

void DeleteAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	DeleteAction* action = (DeleteAction*)data;
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
			showSimpleMessageBox("Error", "Unknown category name for cell");
			return;
		}
		
		NSString* relPathString = [action.viewCtrl.selectedCell getPath];
		NSMutableFilePath* relPath = [[NSMutableFilePath alloc] initWithString:relPathString];
		NSString* itemName = [[relPath lastMember] retain];
		[relPath removeLastMember];
		
		StringTree_struct folderTree = StringTree_getBranch(&sourceTree, [[relPath pathAsString] UTF8String]);
		[relPath release];
		
		NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[fullPath appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[fullPath appendString:saveFolder];
		[saveFolder release];
		[fullPath appendString:@"/"];
		[fullPath appendString:categoryName];
		[fullPath appendString:@"/"];
		[fullPath appendString:relPathString];
		
		if(action.viewCtrl.selectedCell.supercell==nil)
		{
			showSimpleMessageBox("Error", "Cannot delete root cell");
			[fullPath release];
			[itemName release];
			return;
		}
		
		[action showObstructionInView:action.viewCtrl.navigationController.view];
		action.operationHUD = [LGViewHUD defaultHUD];
		[action.operationHUD setTopText:@"Deleting..."];
		[action.operationHUD setBottomText:@""];
		[action.operationHUD setActivityIndicatorOn:YES];
		[action.operationHUD showInView:action.viewCtrl.navigationController.view];
		
		performFileOperationThread([fullPath UTF8String], NULL, FILEOPERATION_DELETE, action, &DeleteAction_FileOperationFinishCallback);
		
		[fullPath release];
		[itemName release];
	}
	else
	{
		[action release];
	}
}

typedef struct
{
	void*data;
	int result;
} DeleteAction_FileOperationPacket;

void DeleteAction_FileOperationFinishCallback(void*data, int result)
{
	DeleteAction_FileOperationPacket*packet = (DeleteAction_FileOperationPacket*)malloc(sizeof(DeleteAction_FileOperationPacket));
	packet->data = data;
	packet->result = result;
	runCallbackInMainThread(&DeleteAction_FileOperationFinishHandler, packet, false);
}

void DeleteAction_FileOperationFinishHandler(void*data)
{
	DeleteAction_FileOperationPacket*packet = (DeleteAction_FileOperationPacket*)data;
	DeleteAction* action = (DeleteAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSFilePath* relPath = [[NSFilePath alloc] initWithString:[action.viewCtrl.selectedCell getPath]];
		NSString* itemName = [relPath lastMember];
		
		StringTree_struct sourceTree;
		NSString* categoryName = [action.viewCtrl.selectedCell getCategory];
		if([categoryName isEqual:@"src"])
		{
			sourceTree = ProjectData_getSourceFiles(appDelegate.projData);
			
			//ProjectBuildInfo tasks
			NSString* relPath = [action.viewCtrl.selectedCell getPath];
			ProjectBuildInfo_struct projBuildInfo = ProjectData_getProjectBuildInfo(appDelegate.projData);
			ProjectBuildInfo_removeEditedFile(&projBuildInfo, [relPath UTF8String]);
			
			NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
			[fullPath appendString:@"/"];
			NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
			[fullPath appendString:saveFolder];
			[saveFolder release];
			[fullPath appendString:@"/bin/build/"];
			[fullPath appendString:relPath];
			
			FileTools_deleteFromFilesystem([fullPath UTF8String]);
			[fullPath release];
			
			ProjectBuildInfo_saveBuildInfoPlist(&projBuildInfo, appDelegate.projData);
			//end ProjectBuildInfo tasks
		}
		else if([categoryName isEqual:@"res"])
		{
			sourceTree = ProjectData_getResourceFiles(appDelegate.projData);
		}
		
		NSMutableFilePath* folderPath = [[NSMutableFilePath alloc] initWithFilePath:relPath];
		[folderPath removeLastMember];
		StringTree_struct folderTree = StringTree_getBranch(&sourceTree, [[folderPath pathAsString] UTF8String]);
		
		if(action.viewCtrl.selectedCell.type == PROJECTTREECELL_FILE)
		{
			StringTree_removeMember(&folderTree, [itemName UTF8String]);
		}
		else if(action.viewCtrl.selectedCell.type == PROJECTTREECELL_FOLDER)
		{
			StringTree_removeBranch(&folderTree, [itemName UTF8String]);
		}
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		[action.viewCtrl.selectedCell.supercell removeMember:action.viewCtrl.selectedCell];
		
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Deleted"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD hideAfterDelay:0.5 withAnimation:HUDAnimationHideFadeOut];
		
		[relPath release];
		[folderPath release];
	}
	else
	{
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Deletion Failed"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-fail.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
		
		showSimpleMessageBox("Error", "Error occured deleting file");
	}
	
	[action release];
}


