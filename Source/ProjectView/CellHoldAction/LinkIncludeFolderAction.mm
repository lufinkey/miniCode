
#import "LinkIncludeFolderAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../ProjectLoad/ProjLoadTools.h"


@interface LinkIncludeFolderAction()
- (void)onFileBrowserCancelButtonSelected;
- (void)onFileBrowserSelectButtonSelected;
@property (nonatomic, retain) NSString* pendingPath;
@end


void LinkIncludeFolderAction_AlertViewDismissHandler(void*data, int buttonIndex);


@implementation LinkIncludeFolderAction

@synthesize pendingPath;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	if([super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:@"/"]==nil)
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
	showSimpleMessageBox([title UTF8String], [message UTF8String], buttons, 2, self, &LinkIncludeFolderAction_AlertViewDismissHandler, NULL);
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

void LinkIncludeFolderAction_AlertViewDismissHandler(void*data, int buttonIndex)
{
	LinkIncludeFolderAction* action = (LinkIncludeFolderAction*)data;
	
	if(buttonIndex==1)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		NSFilePath* fullPath = [[NSFilePath alloc] initWithString:action.pendingPath];
		NSMutableString* extFolderString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[extFolderString appendString:@"/"];
		NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
		[extFolderString appendString:saveFolder];
		[saveFolder release];
		[extFolderString appendString:@"/ext"];
		
		char* pathPtr = (char*)malloc(PATH_MAX);
		if(realpath([extFolderString UTF8String], pathPtr)!=NULL)
		{
			[extFolderString release];
			extFolderString = [[NSString alloc] initWithUTF8String:pathPtr];
		}
		NSFilePath* extPath = [[NSFilePath alloc] initWithString:extFolderString];
		[extFolderString release];
		
		if(realpath([[fullPath pathAsString] UTF8String], pathPtr)!=NULL)
		{
			[fullPath release];
			NSString* fullPathString = [[NSString alloc] initWithUTF8String:pathPtr];
			fullPath = [[NSFilePath alloc] initWithString:fullPathString];
			[fullPathString release];
		}
		free(pathPtr);
		
		if([fullPath isEqual:extPath])
		{
			showSimpleMessageBox("Error", "Cannot set project ext folder as include directory");
			
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
		
		StringList_struct includeDirs = ProjectData_getIncludeDirs(appDelegate.projData);
		StringList_add(&includeDirs, [relPathString UTF8String]);
		ProjectData_saveProjectPlist(appDelegate.projData);
		
		[relPathString release];
		
		if([action.viewCtrl.includeCell isBranchOpen])
		{
			[action.viewCtrl.includeCell setBranchOpen:NO];
			[action.viewCtrl.includeCell setBranchOpen:YES];
		}
		
		[action.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
	}
}	


