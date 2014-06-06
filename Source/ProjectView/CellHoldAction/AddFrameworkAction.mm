
#import "AddFrameworkAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../PreferencesView/GlobalPreferences.h"


@interface AddFrameworkAction()
- (void)onFileBrowserCancelButtonSelected;
@end


@implementation AddFrameworkAction

- (id)initWithProjectTreeViewController:(ProjectTreeViewController *)projectTreeViewController
{
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectSettings_struct projSettings = ProjectData_getProjectSettings(appDelegate.projData);
	const char* sdk = ProjectSettings_getSDK(&projSettings);
	if(strlen(sdk)==0)
	{
		showSimpleMessageBox("No SDK Selected", "You must select a valid SDK to use for this project");
		[self release];
		return nil;
	}
	else if(!Global_checkSDKFolderValid(sdk))
	{
		showSimpleMessageBox("Error", "Invalid SDK selected");
		[self release];
		return nil;
	}
	else
	{
		NSMutableString* frameworksPath = [[NSMutableString alloc] initWithUTF8String:Global_getSDKFolderPath()];
		[frameworksPath appendString:@"/"];
		NSString*sdkString = [[NSString alloc] initWithUTF8String:sdk];
		[frameworksPath appendString:sdkString];
		[sdkString release];
		[frameworksPath appendString:@"/System/Library/Frameworks"];
		
		if([super initWithProjectTreeViewController:projectTreeViewController path:@"/" root:frameworksPath]==nil)
		{
			[frameworksPath release];
			return nil;
		}
		[frameworksPath release];
		
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
	}
	
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

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFile:(NSFilePath*)file
{
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController *)fileBrowser shouldHideFolder:(NSFilePath*)folder
{
	NSString* folderName = [folder lastMember];
	if([folderName length]>10 && [[folderName substringFromIndex:([folderName length]-10)] isEqual:@".framework"])
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		NSString* frameworkName = [folderName substringToIndex:([folderName length]-10)];
		StringList_struct frameworks = ProjectData_getFrameworkList(appDelegate.projData);
		for(int i=0; i<StringList_size(&frameworks); i++)
		{
			NSString*framework = [[NSString alloc] initWithUTF8String:StringList_get(&frameworks, i)];
			if([framework isEqual:frameworkName])
			{
				[framework release];
				return YES;
			}
			[framework release];
		}
		return NO;
	}
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFileLink:(NSFilePath*)file
{
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFolderLink:(NSFilePath*)folder
{
	return [self fileBrowser:fileBrowser shouldHideFolder:folder];
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFolderLink:(NSString*)folder
{
	[self fileBrowser:fileBrowser didSelectFolder:folder];
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFolder:(NSString*)folder
{
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSString* frameworkName = [folder substringToIndex:([folder length]-10)];
	ProjectData_addFramework(appDelegate.projData, [frameworkName UTF8String]);
	
	ProjectTreeViewCell* pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FRAMEWORK identifier:folder];
	[self.viewCtrl.frameworksCell addMember:pcell];
	
	ProjectData_saveProjectPlist(appDelegate.projData);
	
	[self.fileBrowserCtrl dismissModalViewControllerAnimated:YES];
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldOpenFolder:(NSString*)folder
{
	return NO;
}

@end


