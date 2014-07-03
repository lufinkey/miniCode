
#import "EditLibFoldersAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/FileOperationThread.h"
#import "../../Util/UIImageManager.h"


@interface EditLibFoldersAction()
@property (nonatomic) BOOL pathListEdited;
@property (nonatomic) int pendingIndex;
@end


void EditLibFoldersAction_FileOperationFinishCallback(void*data, int result);
void EditLibFoldersAction_FileOperationFinishHandler(void*data);


@implementation EditLibFoldersAction

@synthesize pathListEdited;
@synthesize pendingIndex;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	pathListEdited = NO;
	pendingIndex = -1;
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	NSMutableArray* paths = [[NSMutableArray alloc] init];
	StringList_struct libDirs = ProjectData_getLibDirs(appDelegate.projData);
	for(int i=0; i<StringList_size(&libDirs); i++)
	{
		NSString* dir = [[NSString alloc] initWithUTF8String:StringList_get(&libDirs, i)];
		[paths addObject:dir];
		[dir release];
	}
	
	self = [super initWithProjectTreeViewController:projectTreeViewController paths:paths];
	if(self==nil)
	{
		[paths release];
		return nil;
	}
	[paths release];
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
		//Cancel
	{
		if(self.pathList.pathTable.editing)
		{
			[self.pathList.pathTable setEditing:NO animated:NO];
			[self.pathList.pathTable setEditing:YES animated:NO];
		}
	}
	else if(buttonIndex==1)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		StringList_struct libDirs = ProjectData_getLibDirs(appDelegate.projData);
		StringList_remove(&libDirs, pendingIndex);
		
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		[self.pathList removePathAtIndex:pendingIndex];
		
		pathListEdited = YES;
	}
	else if(buttonIndex==2)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[fullPath appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[fullPath appendString:saveFolder];
		[saveFolder release];
		[fullPath appendString:@"/ext/"];
		[fullPath appendString:[self.pathList.pathArray objectAtIndex:pendingIndex]];
		
		[self showObstructionInView:self.pathList.navigationController.view];
		self.operationHUD = [LGViewHUD defaultHUD];
		[self.operationHUD setTopText:@"Deleting..."];
		[self.operationHUD setBottomText:@""];
		[self.operationHUD setActivityIndicatorOn:YES];
		[self.operationHUD showInView:self.pathList.view];
		
		performFileOperationThread([fullPath UTF8String], NULL, FILEOPERATION_DELETE, self, &EditLibFoldersAction_FileOperationFinishCallback);
		
		[fullPath release];
		
		pathListEdited = YES;
	}
}

- (BOOL)pathListController:(PathListTableViewController*)pathListController shouldRemovePathAtIndex:(NSUInteger)index
{
	pendingIndex = index;
	
	NSString* path = [self.pathList.pathArray objectAtIndex:index];
	if([path UTF8String][0]=='/')
	{
		NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Remove \""];
		[message appendString:path];
		[message appendString:@"\" from lib paths?"];
		
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
															message:message
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Remove", nil];
		[message release];
		
		[alertView show];
		[alertView release];
	}
	else
	{
		NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Remove \""];
		[message appendString:path];
		[message appendString:@"\" from lib paths?"];
		
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
															message:message
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Remove", @"Remove and delete folder", nil];
		[message release];
		
		[alertView show];
		[alertView release];
	}
	return NO;
}

- (void)pathListController:(PathListTableViewController*)pathListController viewWillDisappear:(BOOL)animated
{
	if(pathListEdited)
	{
		if([self.viewCtrl.libCell isBranchOpen])
		{
			[self.viewCtrl.libCell setBranchOpen:NO];
			[self.viewCtrl.libCell setBranchOpen:YES];
		}
	}
	[self release];
}

@end

typedef struct
{
	void*data;
	int result;
} EditLibFoldersAction_FileOperationPacket;

void EditLibFoldersAction_FileOperationFinishCallback(void*data, int result)
{
	EditLibFoldersAction_FileOperationPacket*packet = (EditLibFoldersAction_FileOperationPacket*)malloc(sizeof(EditLibFoldersAction_FileOperationPacket));
	packet->data = data;
	packet->result = result;
	runCallbackInMainThread(&EditLibFoldersAction_FileOperationFinishHandler, packet, false);
}

void EditLibFoldersAction_FileOperationFinishHandler(void*data)
{
	EditLibFoldersAction_FileOperationPacket*packet = (EditLibFoldersAction_FileOperationPacket*)data;
	EditLibFoldersAction* action = (EditLibFoldersAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		StringList_struct libDirs = ProjectData_getLibDirs(appDelegate.projData);
		StringList_remove(&libDirs, action.pendingIndex);
		
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		[action.pathList removePathAtIndex:action.pendingIndex];
		
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Deleted"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
		
		action.pathListEdited = YES;
	}
	else
	{
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Delete Failed"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-fail.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
		
		NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Error deleting "];
		[message appendString:@"lib path \""];
		[message appendString:[action.pathList.pathArray objectAtIndex:action.pendingIndex]];
		[message appendString:@"\" from project"];
		
		showSimpleMessageBox("Error", [message UTF8String]);
		
		[message release];
	}
}

