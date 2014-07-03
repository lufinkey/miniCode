
#import "LinkLibFolderAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"


@interface LinkLibFolderAction()
- (void)onFileBrowserCancelButtonSelected;
- (void)onFileBrowserSelectButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@end


void LinkLibFolderAction_AlertViewDismissHandler(void*data, int buttonIndex);


@implementation LinkLibFolderAction

@synthesize pendingPath;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController *)projectTreeViewController
{
	self = [super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:@"/"];
	if(self==nil)
	{
		return nil;
	}
	
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

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated
{
	[self release];
}

- (void)onFileBrowserCancelButtonSelected
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
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Would you like to link the folder \""];
	NSString* title = [[NSString alloc] initWithUTF8String:"Link Folder"];
	[message appendString:folder];
	[message appendString:@"\"?"];
	
	const char* buttons[2] = {"Cancel", "Confirm"};
	showSimpleMessageBox([title UTF8String], [message UTF8String], buttons, 2, self, &LinkLibFolderAction_AlertViewDismissHandler, NULL);
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

void LinkLibFolderAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	LinkLibFolderAction* action = (LinkLibFolderAction*)data;
	if(buttonIndex==1)
	{
		//TODO implement linking
		
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSFilePath* fullPath = [[NSFilePath alloc] initWithString:action.pendingPath];
		NSMutableString* extFolderString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[extFolderString appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[extFolderString appendString:saveFolder];
		[saveFolder release];
		[extFolderString appendString:@"/ext"];
		NSFilePath* extPath = [[NSFilePath alloc] initWithString:extFolderString];
		[extFolderString release];
		
		if([fullPath isEqual:extPath])
		{
			showSimpleMessageBox("Error", "Cannot set project ext folder as lib directory");
			
			[fullPath release];
			[extPath release];
			
			return;
		}
		
		NSMutableString* relPathString = nil;
		
		if([fullPath containsSubfoldersOf:extPath])
		{
			NSFilePath* relPath = [fullPath pathRelativeTo:extPath];
			relPathString = [[NSMutableString alloc] initWithString:[relPath pathAsString]];
			if([relPathString UTF8String][0]=='/')
			{
				[relPathString deleteCharactersInRange:NSMakeRange(0, 1)];
			}
		}
		else
		{
			relPathString = [[NSMutableString alloc] initWithString:[fullPath pathAsString]];
		}
		
		[fullPath release];
		[extPath release];
		
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

