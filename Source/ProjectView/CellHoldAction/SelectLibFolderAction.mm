
#import "SelectLibFolderAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"

@interface SelectLibFolderAction()
- (void)onFileBrowserSkipButtonSelected;
- (void)onFileBrowserSelectButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@end


void SelectLibFolderAction_AlertViewDismissHandler(void*data, int buttonIndex);


@implementation SelectLibFolderAction

@synthesize pendingPath;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController root:(NSString*)root
{
	self.pendingPath = root;
	
	if([super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:root]==nil)
	{
		return nil;
	}
	
	[self.fileBrowserCtrl setGlobalToolbarHidden:NO];
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbarItems addObject:flexibleSpace];
	UIBarButtonItem* titleButton = [[UIBarButtonItem alloc] initWithTitle:@"Select Lib Folder" style:UIBarButtonItemStylePlain target:nil action:nil];
	[toolbarItems addObject:titleButton];
	[titleButton release];
	[toolbarItems addObject:flexibleSpace];
	[flexibleSpace release];
	UIBarButtonItem* skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStyleBordered target:self action:@selector(onFileBrowserSkipButtonSelected)];
	[toolbarItems addObject:skipButton];
	[skipButton release];
	[self.fileBrowserCtrl.globalToolbar setItems:toolbarItems];
	[toolbarItems release];
	
	return self;
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated
{
	[self release];
}

- (void)onFileBrowserSkipButtonSelected
{
	[self.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
}

- (void)onFileBrowserSelectButtonSelected
{
	NSMutableFilePath* fullPath = [[NSMutableFilePath alloc] initWithFilePath:self.fileBrowserCtrl.root];
	[fullPath appendPath:self.fileBrowserCtrl.path];
	self.pendingPath = [NSString stringWithString:[fullPath pathAsString]];
	NSString* folder = [[fullPath lastMember] retain];
	[fullPath release];
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Would you like to set the folder \""];
	NSString* title = [[NSString alloc] initWithUTF8String:"Set Lib Folder"];
	[message appendString:folder];
	[message appendString:@"\" as a lib folder?"];
	
	const char* buttons[2] = {"Cancel", "Confirm"};
	showSimpleMessageBox([title UTF8String], [message UTF8String], buttons, 2, self, &SelectLibFolderAction_AlertViewDismissHandler, NULL);
	[message release];
	[title release];
	
	[folder release];
}

- (void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	if(navigationController==self.fileBrowserCtrl)
	{
		UIBarButtonItem* selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(onFileBrowserSelectButtonSelected)];
		[viewController.navigationItem setRightBarButtonItem:selectButton];
		[selectButton release];
	}
}

- (void)dealloc
{
	[pendingPath release];
	[super dealloc];
}

@end

void SelectLibFolderAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	SelectLibFolderAction* action = (SelectLibFolderAction*)data;
	if(buttonIndex==1)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSMutableString* extFolderString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[extFolderString appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[extFolderString appendString:saveFolder];
		[saveFolder release];
		[extFolderString appendString:@"/ext/"];
		
		NSFilePath* extPath = [[NSFilePath alloc] initWithString:extFolderString];
		[extFolderString release];
		NSFilePath* pendingFolderPath = [[NSFilePath alloc] initWithString:action.pendingPath];
		NSFilePath* relPath = [pendingFolderPath pathRelativeTo:extPath];
		[extPath release];
		[pendingFolderPath release];
		
		NSMutableString* relPathString = [[NSMutableString alloc] initWithString:[relPath pathAsString]];
		if([relPathString UTF8String][0]=='/')
		{
			[relPathString deleteCharactersInRange:NSMakeRange(0, 1)];
		}
		
		StringList_struct libDirs = ProjectData_getLibDirs(appDelegate.projData);
		StringList_add(&libDirs, [relPathString UTF8String]);
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		[relPathString release];
		
		if([action.viewCtrl.libCell isBranchOpen])
		{
			[action.viewCtrl.libCell setBranchOpen:NO];
			[action.viewCtrl.libCell setBranchOpen:YES];
		}
		
		[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
	}
}
