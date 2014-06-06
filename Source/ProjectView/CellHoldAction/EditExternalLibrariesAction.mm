
#import "EditExternalLibrariesAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/FileOperationThread.h"
#import "../../Util/UIImageManager.h"


@interface EditExternalLibrariesAction()
- (void)onFileBrowserCancelButtonSelected;
- (void)onFileBrowserEditButtonSelected;
- (void)onFileBrowserDoneButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@property (nonatomic) BOOL includesEdited;
@property (nonatomic) BOOL libsEdited;
@end


void EditExternalLibrariesAction_FileOperationFinishCallback(void*data, int result);
void EditExternalLibrariesAction_FileOperationFinishHandler(void*data);


@implementation EditExternalLibrariesAction

@synthesize pendingPath;
@synthesize includesEdited;
@synthesize libsEdited;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	includesEdited = NO;
	libsEdited = NO;
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	NSMutableString* extFolderPath = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
	[extFolderPath appendString:@"/"];
	NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
	[extFolderPath appendString:saveFolder];
	[saveFolder release];
	[extFolderPath appendString:@"/ext"];
	
	if([super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:extFolderPath]==nil)
	{
		[extFolderPath release];
		return nil;
	}
	[extFolderPath release];
	
	[self.fileBrowserCtrl setGlobalToolbarHidden:NO];
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(onFileBrowserCancelButtonSelected)];
	[toolbarItems addObject:closeButton];
	[closeButton release];
	UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbarItems addObject:flexibleSpace];
	[flexibleSpace release];
	[self.fileBrowserCtrl.globalToolbar setItems:toolbarItems];
	[toolbarItems release];
	
	return self;
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
	//Cancel
	{
		if(self.fileBrowserCtrl.editing)
		{
			[self.fileBrowserCtrl setEditing:NO animated:NO];
			[self.fileBrowserCtrl setEditing:YES animated:NO];
		}
	}
	else if(buttonIndex==1)
	{
		NSMutableFilePath* fullPath = [[NSMutableFilePath alloc] initWithFilePath:self.fileBrowserCtrl.root];
		NSFilePath* relPath = [[NSFilePath alloc] initWithString:pendingPath];
		[fullPath appendPath:relPath];
		[relPath release];
		
		[self showObstructionInView:self.fileBrowserCtrl.view];
		self.operationHUD = [LGViewHUD defaultHUD];
		[self.operationHUD setTopText:@"Deleting..."];
		[self.operationHUD setBottomText:@""];
		[self.operationHUD setActivityIndicatorOn:YES];
		[self.operationHUD showInView:self.fileBrowserCtrl.view];
		
		performFileOperationThread([[fullPath pathAsString] UTF8String], NULL, FILEOPERATION_DELETE, self, &EditExternalLibrariesAction_FileOperationFinishCallback);
		[fullPath release];
	}
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated
{
	[self release];
}

- (BOOL)canEditItemsInFileBrowser:(UIFileBrowserViewController*)fileBrowser
{
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFile:(NSFilePath*)file
{
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFileLink:(NSFilePath*)file
{
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldDeleteFolder:(NSFilePath*)folder
{
	NSFilePath* relPath = [folder pathRelativeTo:self.fileBrowserCtrl.root];
	self.pendingPath = [NSMutableString stringWithString:[relPath pathAsString]];
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Delete the folder \""];
	[message appendString:[folder lastMember]];
	[message appendString:@"\"?"];
	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete"
														message:message
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Confirm", nil];
	[alertView show];
	[alertView release];
	
	[message release];
	
	return NO;
}

- (void)onFileBrowserCancelButtonSelected
{
	[self.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
}

- (void)onFileBrowserEditButtonSelected
{
	[self.fileBrowserCtrl setEditing:YES animated:YES];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onFileBrowserDoneButtonSelected)];
	[self.fileBrowserCtrl.visibleViewController.navigationItem setRightBarButtonItem:doneButton animated:YES];
	[doneButton release];
}

- (void)onFileBrowserDoneButtonSelected
{
	[self.fileBrowserCtrl setEditing:NO animated:YES];
	
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onFileBrowserEditButtonSelected)];
	[self.fileBrowserCtrl.visibleViewController.navigationItem setRightBarButtonItem:editButton animated:YES];
	[editButton release];
}

- (void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	if(navigationController==self.fileBrowserCtrl)
	{
		UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onFileBrowserEditButtonSelected)];
		[viewController.navigationItem setRightBarButtonItem:editButton];
		[editButton release];
	}
}

- (void)dealloc
{
	[pendingPath release];
	[super dealloc];
}

@end

typedef struct
{
	void*data;
	int result;
} EditExternalLibrariesAction_FileOperationPacket;

void EditExternalLibrariesAction_FileOperationFinishCallback(void*data, int result)
{
	EditExternalLibrariesAction_FileOperationPacket*packet = (EditExternalLibrariesAction_FileOperationPacket*)malloc(sizeof(EditExternalLibrariesAction_FileOperationPacket));
	packet->data = data;
	packet->result = result;
	runCallbackInMainThread(&EditExternalLibrariesAction_FileOperationFinishHandler, packet, false);
}

void EditExternalLibrariesAction_FileOperationFinishHandler(void*data)
{
	EditExternalLibrariesAction_FileOperationPacket*packet = (EditExternalLibrariesAction_FileOperationPacket*)data;
	EditExternalLibrariesAction* action = (EditExternalLibrariesAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSFilePath* relPath = [[NSFilePath alloc] initWithString:action.pendingPath];
		
		StringList_struct includeDirs = ProjectData_getIncludeDirs(appDelegate.projData);
		for(int i=0; i<StringList_size(&includeDirs); i++)
		{
			const char* dir = StringList_get(&includeDirs, i);
			if(dir[0]!='/' && dir[0]!='\0')
			{
				NSString* dirString = [[NSString alloc] initWithUTF8String:dir];
				NSFilePath* dirPath = [[NSFilePath alloc] initWithString:dirString];
				[dirString release];
				
				if([dirPath containsSubfoldersOf:relPath])
				{
					StringList_remove(&includeDirs, i);
					i--;
					action.includesEdited = YES;
				}
				[dirPath release];
			}
		}
		
		StringList_struct libDirs = ProjectData_getLibDirs(appDelegate.projData);
		for(int i=0; i<StringList_size(&libDirs); i++)
		{
			const char* dir = StringList_get(&libDirs, i);
			if(dir[0]!='/' && dir[0]!='\0')
			{
				NSString* dirString = [[NSString alloc] initWithUTF8String:dir];
				NSFilePath* dirPath = [[NSFilePath alloc] initWithString:dirString];
				[dirString release];
				
				if([dirPath containsSubfoldersOf:relPath])
				{
					StringList_remove(&libDirs, i);
					i--;
					action.libsEdited = YES;
				}
				[dirPath release];
			}
		}
		
		[relPath release];
		
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		[action.fileBrowserCtrl refreshFolders];
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Deleted"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
	}
	else
	{
		showSimpleMessageBox("Error", "Error deleting folder");
		
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Delete Failed"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-fail.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
	}
}



