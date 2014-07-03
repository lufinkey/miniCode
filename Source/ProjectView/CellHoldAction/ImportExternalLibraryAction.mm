
#import "ImportExternalLibraryAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../Util/UIImageManager.h"
#import "../../Util/FileOperationThread.h"
#import "ProjectTreeViewController+CellHoldAction.h"

#import "SelectIncludeFolderAction.h"

@interface ImportExternalLibraryAction()
- (void)onFileBrowserCancelButtonSelected;
- (void)onFileBrowserSelectButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@property (nonatomic) BOOL presentWaiting;
@end


void ImportExternalLibraryAction_AlertViewDismissHandler(void*data, int buttonIndex);
void ImportExternalLibraryAction_FileOperationFinishCallback(void*data, int result);
void ImportExternalLibraryAction_FileOperationFinishHandler(void*data);


@implementation ImportExternalLibraryAction

@synthesize pendingPath;
@synthesize presentWaiting;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	presentWaiting = NO;
	
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
	[self.fileBrowserCtrl.globalToolbar setItems:toolbarItems];
	[toolbarItems release];
	
	return self;
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated
{
	if(presentWaiting)
	{
		[self.viewCtrl.obstructView removeFromSuperview];
		self.viewCtrl.currentHoldAction = [[SelectIncludeFolderAction alloc] initWithProjectTreeViewController:viewCtrl root:pendingPath];
	}
	presentWaiting = NO;
	[self release];
}

- (void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	if(navigationController==self.fileBrowserCtrl)
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
	showSimpleMessageBox([title UTF8String], [message UTF8String], buttons, 2, self, &ImportExternalLibraryAction_AlertViewDismissHandler, NULL);
	[message release];
	[title release];
	
	[folder release];
}

- (void)dealloc
{
	[pendingPath release];
	[super dealloc];
}

@end

void ImportExternalLibraryAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	ImportExternalLibraryAction* action = (ImportExternalLibraryAction*)data;
	
	if(buttonIndex==1)
	{
		iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSMutableFilePath* srcPath = [[NSMutableFilePath alloc] initWithString:action.pendingPath];
		NSMutableString* destPathString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[destPathString appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[destPathString appendString:saveFolder];
		[saveFolder release];
		[destPathString appendString:@"/ext"];
		NSMutableFilePath* destPath = [[NSMutableFilePath alloc] initWithString:destPathString];
		[destPathString release];
		[destPath addMember:[srcPath lastMember]];
		
		if(FileTools_directoryContainsFiles([[destPath pathAsString] UTF8String]))
		{
			[srcPath release];
			[destPath release];
			showSimpleMessageBox("Error", "Folder with duplicate name already exists.");
			return;
		}
		else
		{
			[action showObstructionInView:action.fileBrowserCtrl.view];
			action.operationHUD = [LGViewHUD defaultHUD];
			[action.operationHUD setTopText:@"Importing Library..."];
			[action.operationHUD setBottomText:@""];
			[action.operationHUD setActivityIndicatorOn:YES];
			[action.operationHUD showInView:action.fileBrowserCtrl.view withAnimation:HUDAnimationShowZoom];
			
			performFileOperationThread([[srcPath pathAsString] UTF8String], [[destPath pathAsString] UTF8String], FILEOPERATION_COPYFOLDER, action, &ImportExternalLibraryAction_FileOperationFinishCallback);
		}
		
		[srcPath release];
		[destPath release];
	}
}

typedef struct
{
	void*data;
	int result;
} ImportExternalLibraryAction_FileOperationPacket;

void ImportExternalLibraryAction_FileOperationFinishCallback(void*data, int result)
{
	ImportExternalLibraryAction_FileOperationPacket*packet = (ImportExternalLibraryAction_FileOperationPacket*)malloc(sizeof(ImportExternalLibraryAction_FileOperationPacket));
	packet->data = data;
	packet->result = result;
	runCallbackInMainThread(&ImportExternalLibraryAction_FileOperationFinishHandler, packet, false);
}

void ImportExternalLibraryAction_FileOperationFinishHandler(void*data)
{
	ImportExternalLibraryAction_FileOperationPacket*packet = (ImportExternalLibraryAction_FileOperationPacket*)data;
	ImportExternalLibraryAction* action = (ImportExternalLibraryAction*)packet->data;
	int result = packet->result;
	free(packet);
	
	if(result==0)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSFilePath* srcPath = [[NSFilePath alloc] initWithString:action.pendingPath];
		NSMutableString* folderPath = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[folderPath appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[folderPath appendString:saveFolder];
		[saveFolder release];
		[folderPath appendString:@"/ext/"];
		[folderPath appendString:[srcPath lastMember]];
		
		action.pendingPath = folderPath;
		
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Imported Library"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
		
		[action.viewCtrl showObstructionInView:action.viewCtrl.navigationController.view];
		[action.viewCtrl.obstructView setBackgroundColor:[UIColor clearColor]];
		action.presentWaiting = YES;
		
		[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
		
		[srcPath release];
		[folderPath release];
	}
	else
	{
		[action.obstructView removeFromSuperview];
		[action.operationHUD setTopText:@"Import Failed"];
		[action.operationHUD setBottomText:@""];
		[UIImageManager loadImage:@"Images/rounded-fail.png"];
		[action.operationHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[action.operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
		
		showSimpleMessageBox("Error", "Error occured while importing library");
	}
}
