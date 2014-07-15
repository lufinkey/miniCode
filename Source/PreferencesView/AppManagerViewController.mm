
#import "AppManagerViewController.h"
#import "../Util/UIImageManager.h"
#import "../Util/AppManager.h"
#import "../IconManager/IconManager.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "GlobalPreferences.h"
#import "../Util/Subprocess.h"

@interface AppManagerViewController()
- (void)onEditButtonSelected;
- (void)onDoneButtonSelected;
- (void)onCloseButtonSelected;
@property (nonatomic, retain) NSString* pendingApp;
@property (nonatomic, retain) NSIndexPath* pendingIndex;
@end

@implementation AppManagerViewController

@synthesize appTable;
@synthesize pendingApp;
@synthesize pendingIndex;

- (id)init
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	appTable = [[UITableView alloc] initWithFrame:self.view.frame];
	[appTable setDelegate:self];
	[appTable setDataSource:self];
	[self.view addSubview:appTable];
	
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButtonSelected)];
	[self.navigationItem setRightBarButtonItem:editButton animated:NO];
	[editButton release];
	
	UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(onCloseButtonSelected)];
	[self.navigationItem setLeftBarButtonItem:closeButton animated:NO];
	[closeButton release];
	
	[self.navigationItem setTitle:@"Installed Apps"];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[appTable setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (void)onEditButtonSelected
{
	[appTable setEditing:YES animated:YES];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButtonSelected)];
	[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
	[doneButton release];
	
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)onDoneButtonSelected
{
	[appTable setEditing:NO animated:YES];
	
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButtonSelected)];
	[self.navigationItem setRightBarButtonItem:editButton animated:YES];
	[editButton release];
	
	UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(onCloseButtonSelected)];
	[self.navigationItem setLeftBarButtonItem:closeButton animated:YES];
	[closeButton release];
}

- (void)onCloseButtonSelected
{
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return GlobalPreferences_installedApps_size();
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* appName = [[NSString alloc] initWithUTF8String:GlobalPreferences_installedApps_get(indexPath.row)];
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:appName];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:appName] autorelease];
	}
	
	[cell.textLabel setText:appName];
	
	if(cell.imageView.image==nil || cell.detailTextLabel.text==nil || [cell.detailTextLabel.text length]==0)
	{
		NSMutableString* appPath = [[NSMutableString alloc] initWithUTF8String:"/Applications/"];
		[appPath appendString:appName];
		UIImage* icon = [IconManager iconForApplication:appPath];
		[cell.imageView setImage:icon];
		
		[appPath appendString:@"/Info.plist"];
		NSDictionary* infoPlist = [[NSDictionary alloc] initWithContentsOfFile:appPath];
		if(infoPlist!=nil)
		{
			NSString* bundleID = [infoPlist objectForKey:@"CFBundleIdentifier"];
			if(bundleID!=nil)
			{
				[cell.detailTextLabel setText:bundleID];
			}
		}
		
		[infoPlist release];
		[appPath release];
	}
	
	[appName release];
	return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* appName = [[NSString alloc] initWithUTF8String:GlobalPreferences_installedApps_get(indexPath.row)];
	self.pendingApp = appName;
	self.pendingIndex = indexPath;
	
	NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Are you sure you want to uninstall "];
	[message appendString:appName];
	[appName release];
	[message appendString:@"? This cannot be undone."];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Uninstall App" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
	[alert show];
	[alert release];
	
	[message release];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1)
	{
		NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:"/Applications/"];
		if(pendingApp==nil || pendingIndex==nil || [pendingApp length]==0 || ([pendingApp length]==1 && [pendingApp UTF8String][0]=='/'))
		{
			showSimpleMessageBox("Error", "Invalid application name");
			[fullPath release];
			return;
		}
		[fullPath appendString:pendingApp];
		
		if(FileTools_folderExists([fullPath UTF8String]))
		{
			bool success = AppManager_uninstall([fullPath UTF8String]);
			if(!success)
			{
				showSimpleMessageBox("Error", "Unable to uninstall application");
				[fullPath release];
				return;
			}
			else
			{
#if !(TARGET_IPHONE_SIMULATOR)
				subprocess_execute("uicache", NULL, NULL, NULL, NULL, true, NULL, true);
#endif
			}
		}
		
		GlobalPreferences_installedApps_remove([pendingApp UTF8String]);
		GlobalPreferences_save();
		
		NSArray* indexes = [[NSArray alloc] initWithObjects:pendingIndex, nil];
		[appTable deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationBottom];
		[indexes release];
		
		NSMutableString* message = [[NSMutableString alloc] initWithString:pendingApp];
		[message appendString:@" was successfully uninstalled! You may have to wait a moment for the homescreen to refresh."];
		showSimpleMessageBox("Success", [message UTF8String]);
		[message release];
		
		[fullPath release];
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
	[appTable release];
	[pendingApp release];
	[pendingIndex release];
	[super dealloc];
}

@end
