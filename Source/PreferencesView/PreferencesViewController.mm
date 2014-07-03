
#import "PreferencesViewController.h"
#import "../IconManager/IconManager.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../Navigation/UINavigator.h"
#import "../Util/UIBarImageButtonItem.h"
#import "../UIWebViewController/UIWebViewController.h"
#import "GlobalPreferences.h"
#import "FontSelectorViewController.h"
#import "FontSizePreviewViewController.h"
#import "AppManagerViewController.h"

@interface PreferencesViewController()
- (void)onSDKInfoButtonSelected;
@end

@implementation PreferencesViewController

@synthesize preferences;
@synthesize fileExplorer;

- (id)init
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	fileExplorer = nil;
	
	UIBarButtonItem*doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
	[self.navigationItem setTitle:@"Preferences"];
	[self.navigationItem setRightBarButtonItem:doneButton];
	[doneButton release];
	
	preferences = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
	preferences.delegate = self;
	preferences.dataSource = self;
	[self.view addSubview:preferences];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[preferences reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[preferences setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)doneButtonSelected
{
	if(!GlobalPreferences_save())
	{
		showSimpleMessageBox("Error", "Problem occured while saving preferences");
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancelFileExplorer
{
	[fileExplorer dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section==0)
	{
		return 3;
	}
	else if(section==1)
	{
		return 1;
	}
	else if(section==2)
	{
		return 5;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section==2)
	{
		return @"Donate to help keep this app free";
	}
	return nil;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section==0)
	{
		NSString*cellID = nil;
		
		switch(indexPath.row)
		{
			default:
			return nil;
			
			case 0:
			cellID = @"Default SDK";
			break;
			
			case 1:
			cellID = @"Code Editor Font";
			break;
			
			case 2:
			cellID = @"Code Editor Font Size";
			break;
		}
		
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
		if(cell==nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
		}
		
		NSMutableString* title = [[NSMutableString alloc] initWithString:cellID];
		[title appendString:@":"];
		[cell.textLabel setText:title];
		[title release];
		
		switch(indexPath.row)
		{
			case 0:
			[cell.detailTextLabel setText:[NSString stringWithUTF8String:GlobalPreferences_getDefaultSDK()]];
			break;
			
			case 1:
			{
				NSString* fontName = [NSString stringWithUTF8String:GlobalPreferences_getCodeEditorFont()];
				[cell.detailTextLabel setFont:[UIFont fontWithName:fontName size:cell.detailTextLabel.font.pointSize]];
				[cell.detailTextLabel setText:fontName];
			}
			break;
			
			case 2:
			{
				NSNumber* fontSize = [[NSNumber alloc] initWithUnsignedInt:GlobalPreferences_getCodeEditorFontSize()];
				[cell.detailTextLabel setText:[fontSize stringValue]];
				[fontSize release];
			}
			break;
		}
		
		return cell;
	}
	else if(indexPath.section==1)
	{
		NSString*cellID = nil;
		
		switch(indexPath.row)
		{
			default:
			return nil;
			
			case 0:
			cellID = @"Installed Apps";
			break;
		}
		
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
		if(cell==nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
		}
		
		if(indexPath.row==0)
		{
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		}
		
		[cell.textLabel setText:cellID];
		return cell;
	}
	else if(indexPath.section==2)
	{
		NSString* cellID = nil;
		
		switch(indexPath.row)
		{
			default:
			return nil;
			
			case 0:
			cellID = @"Donate";
			break;
			
			case 1:
			cellID = @"Donate with Bitcoin";
			break;
			
			case 2:
			cellID = @"Like us on Facebook";
			break;
			
			case 3:
			cellID = @"Follow on Twitter";
			break;
			
			case 4:
			cellID = @"Email Developer";
			break;
		}
		
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
		if(cell==nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		}
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[cell.textLabel setText:cellID];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section==0)
	{
		switch(indexPath.row)
		{
			case 0:
			//default SDK
			{
				NSString* sdkPath = [[NSString alloc] initWithUTF8String:Global_getSDKFolderPath()];
				fileExplorer = [[UIFileBrowserViewController alloc] initWithString:@"" root:sdkPath delegate:self];
				if(fileExplorer!=nil)
				{
					[fileExplorer setDelegate:self];
					[fileExplorer.navigationBar setBarStyle:UIBarStyleBlack];
					UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelFileExplorer)];
					[fileExplorer.navigationBar.topItem setLeftBarButtonItem:cancelButton];
					[cancelButton release];
					UIBarButtonItem* infoButton = [[UIBarImageButtonItem alloc] initWithType:UIButtonTypeInfoLight target:self action:@selector(onSDKInfoButtonSelected)];
					[fileExplorer.navigationBar.topItem setRightBarButtonItem:infoButton];
					[infoButton release];
					[self presentModalViewController:fileExplorer animated:YES];
					[fileExplorer release];
				}
				[sdkPath release];
			}
			break;
			
			case 1:
			//code editor font
			{
				FontSelectorViewController* fontSelector = [[FontSelectorViewController alloc] init];
				[self.navigationController pushViewController:fontSelector animated:YES];
				[fontSelector release];
			}
			break;
			
			case 2:
			//code editor font size
			{
				FontSizePreviewViewController* fontSizer = [[FontSizePreviewViewController alloc] init];
				[self.navigationController pushViewController:fontSizer animated:YES];
				[fontSizer release];
			}
			break;
		}
	}
	else if(indexPath.section==1)
	{
		switch(indexPath.row)
		{
			case 0:
			//installed apps
			{
				AppManagerViewController* appMgr = [[AppManagerViewController alloc] init];
				UINavigator* navigator = [[UINavigator alloc] initWithRootViewController:appMgr];
				[navigator.navigationBar setBarStyle:UIBarStyleDefault];
				[appMgr release];
				[self.navigationController presentModalViewController:navigator animated:YES];
				[navigator release];
			}
			break;
		}
	}
	else if(indexPath.section==2)
	{
		switch(indexPath.row)
		{
			case 0:
			//donate
			{
				NSString* donateURL = @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=M43B9W76GWWBS&lc=US&item_name=Broken%20Physics&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted";
				UIWebViewController* webViewController = [[UIWebViewController alloc] init];
				[webViewController loadExternalPage:donateURL];
				[self.navigationController pushViewController:webViewController animated:YES];
				[webViewController release];
			}
			break;
			
			case 1:
			//donate with bitcoin
			{
				NSString* donateURL = @"https://coinbase.com/checkouts/a1672e1864707bc7467e9a3572987ab9";
				UIWebViewController* webViewController = [[UIWebViewController alloc] init];
				[webViewController loadExternalPage:donateURL];
				[self.navigationController pushViewController:webViewController animated:YES];
				[webViewController release];
			}
				break;
			
			case 2:
			//like on facebook
			openURL("https://www.facebook.com/BrokenPhysicsStudios");
			break;
			
			case 3:
			//follow on twitter
			openURL("https://www.twitter.com/lufinkey");
			break;
			
			case 4:
			//email developer
			{
				if([MFMailComposeViewController canSendMail])
				{
					MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init];
					mailer.mailComposeDelegate = self;
					NSMutableString* subjectString = [[NSMutableString alloc] initWithUTF8String:"miniCode v"];
					NSNumber* versionNumber = [[NSNumber alloc] initWithDouble:Global_getVersion()];
					[subjectString appendString:[versionNumber stringValue]];
					[versionNumber release];
					[mailer setSubject:subjectString];
					[subjectString release];
					NSArray *toRecipients = [NSArray arrayWithObjects:@"luisfinke@gmail.com", nil];
					[mailer setToRecipients:toRecipients];
					[mailer setMessageBody:@"" isHTML:NO];
					[self presentModalViewController:mailer animated:YES];
					[mailer release];
				}
				else
				{
					showSimpleMessageBox("Error", "Cannot open email compose sheet on this device");
				}
			}
			break;
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldOpenFolder:(NSString*)folder
{
	return NO;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFolder:(NSFilePath*)path
{
	if([[IconManager getExtensionForFilename:[path lastMember]] isEqual:@"sdk"])
	{
		return NO;
	}
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFolderLink:(NSFilePath*)path
{
	return [self fileBrowser:fileBrowser shouldHideFolder:path];
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFile:(NSFilePath*)path
{
	return YES;
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFileLink:(NSFilePath*)path
{
	return YES;
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFolder:(NSString*)folder
{
	GlobalPreferences_setDefaultSDK([folder UTF8String]);
	[fileExplorer dismissModalViewControllerAnimated:YES];
}

- (void)onSDKInfoButtonSelected
{
	const char* message = "SDKs can be added by copying a .sdk package from xcode to /var/stash/Developer/SDKs on your device.\n\n"
							"If you have issues, you may need to zip the package before you copy it, and then unzip it on the device. "
							"Sometimes symbolic links can get messed up.";
	showSimpleMessageBox(NULL, message);
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
	[preferences release];
	[super dealloc];
}

@end
