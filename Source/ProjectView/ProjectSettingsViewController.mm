
#import "ProjectSettingsViewController.h"
#import "PlistViewerViewController.h"
#import "../iCodeAppDelegate.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../Navigation/UINavigator.h"
#import "../PreferencesView/GlobalPreferences.h"
#import "../Util/UIBarImageButtonItem.h"
#import "../IconManager/IconManager.h"

static const int SETTINGSSECTION_PROJECTPROPERTIES = 0;
static const int SETTINGSSECTION_COMPILERSETTINGS = 1;

static const int PROJPROPERTIES_NAME = 0;
static const int PROJPROPERTIES_AUTHOR = 1;
static const int PROJPROPERTIES_BUNDLEID = 2;
static const int PROJPROPERTIES_EXECUTABLE = 3;
static const int PROJPROPERTIES_PRODUCTNAME = 4;

static const int COMPILERSETTINGS_SDK = 0;

@implementation ProjectSettingsViewController

@synthesize settingsTable;

@synthesize name;
@synthesize author;
@synthesize bundleID;
@synthesize execName;
@synthesize prodName;
@synthesize sdk;

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectData_struct* projData = appDelegate.projData;
	ProjectSettings_struct projSettings = ProjectData_getProjectSettings(projData);
	
	name = [[NSString alloc] initWithUTF8String:ProjectData_getName(projData)];
	author = [[NSString alloc] initWithUTF8String:ProjectData_getAuthor(projData)];
	bundleID = [[NSString alloc] initWithUTF8String:ProjectData_getBundleIdentifier(projData)];
	execName = [[NSString alloc] initWithUTF8String:ProjectData_getExecutableName(projData)];
	prodName = [[NSString alloc] initWithUTF8String:ProjectData_getProductName(projData)];
	sdk = [[NSString alloc] initWithUTF8String:ProjectSettings_getSDK(&projSettings)];
	
	settingsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
	[settingsTable setDelegate:self];
	[settingsTable setDataSource:self];
	[self.view addSubview:settingsTable];
	
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonSelected)];
	[self.navigationItem setLeftBarButtonItem:cancelButton];
	[cancelButton release];
	
	UIBarButtonItem* applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(applyButtonSelected)];
	[self.navigationItem setRightBarButtonItem:applyButton];
	[applyButton release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[settingsTable setFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height)];
	[settingsTable reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)applyButtonSelected
{
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectData_struct* projData = appDelegate.projData;
	ProjectSettings_struct projSettings = ProjectData_getProjectSettings(projData);
	
	ProjectData_setName(projData, [name UTF8String]);
	ProjectData_setAuthor(projData, [author UTF8String]);
	ProjectData_setBundleIdentifier(projData, [bundleID UTF8String]);
	ProjectData_setExecutableName(projData, [execName UTF8String]);
	ProjectData_setProductName(projData, [prodName UTF8String]);
	ProjectSettings_setSDK(&projSettings, [sdk UTF8String]);
	
	bool success1 = ProjectData_saveProjectPlist(projData);
	bool success2 = ProjectSettings_saveSettingsPlist(&projSettings, projData);
	
	if(success1 && success2)
	{
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
}

- (void)cancelButtonSelected
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
	if(self.navigationController.topViewController==self)
	{
		CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		
		[settingsTable setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.height)];
		
		UIView* firstResponder = [settingsTable findFirstResponder];
		if(firstResponder!=nil)
		{
			int offset = [firstResponder findHeightFromSuperview:settingsTable] + firstResponder.frame.size.height - keyboardSize.height;
			[settingsTable setContentOffset:CGPointMake(0, offset) animated:YES];
		}
	}
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	[settingsTable setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch(section)
	{
		case SETTINGSSECTION_PROJECTPROPERTIES:
		return @"Project Properties";
		
		case SETTINGSSECTION_COMPILERSETTINGS:
		return @"Compiler Settings";
	}
	return nil;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	switch(section)
	{
		case SETTINGSSECTION_PROJECTPROPERTIES:
		//Project Properties
		return 5;
		
		case SETTINGSSECTION_COMPILERSETTINGS:
		//Compiler settings
		return 1;
	}
	
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* cellID = nil;
	NSString* objVal = nil;
	if(indexPath.section==SETTINGSSECTION_PROJECTPROPERTIES)
	{
		switch(indexPath.row)
		{
			default:
			return nil;
			
			case PROJPROPERTIES_NAME:
			// Name
			cellID = [[NSString alloc] initWithUTF8String:"Project Name:"];
			objVal = name;
			break;
			
			case PROJPROPERTIES_AUTHOR:
			// Author
			cellID = [[NSString alloc] initWithUTF8String:"Project Author:"];
			objVal = author;
			break;
			
			case PROJPROPERTIES_BUNDLEID:
			// Bundle Identifier
			cellID = [[NSString alloc] initWithUTF8String:"Bundle Identifier:"];
			objVal = bundleID;
			break;
			
			case PROJPROPERTIES_EXECUTABLE:
			// Executable Name
			cellID = [[NSString alloc] initWithUTF8String:"Executable Name:"];
			objVal = execName;
			break;
			
			case PROJPROPERTIES_PRODUCTNAME:
			// Product Name
			cellID = [[NSString alloc] initWithUTF8String:"Product Name:"];
			objVal = prodName;
			break;
		}
	}
	else if(indexPath.section==SETTINGSSECTION_COMPILERSETTINGS)
	{
		switch(indexPath.row)
		{
			default:
			return nil;
			
			case COMPILERSETTINGS_SDK:
			//SDK
			cellID = [[NSString alloc] initWithUTF8String:"SDK:"];
			objVal = sdk;
			break;
		}
	}
	else
	{
		return nil;
	}
	
	UIDictionaryTableViewCell* cell = (UIDictionaryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell==nil)
	{
		cell = [[[UIDictionaryTableViewCell alloc] initForObject:objVal label:cellID reuseIdentifier:cellID] autorelease];
	}
	else
	{
		[cell reloadForObject:objVal label:cellID];
	}
	
	[cellID release];
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section==SETTINGSSECTION_PROJECTPROPERTIES)
	{
		NSString* str = nil;
		NSString* header = nil;
		
		switch(indexPath.row)
		{
			case PROJPROPERTIES_NAME:
			// Name
			{
				str = name;
				header = [[NSString alloc] initWithUTF8String:"Name"];
			}
			break;
				
			case PROJPROPERTIES_AUTHOR:
			// Author
			{
				str = author;
				header = [[NSString alloc] initWithUTF8String:"Author"];
			}
			break;
				
			case PROJPROPERTIES_BUNDLEID:
			// Bundle Identifier
			{
				str = bundleID;
				header = [[NSString alloc] initWithUTF8String:"Bundle ID"];
			}
			break;
				
			case PROJPROPERTIES_EXECUTABLE:
			// Executable Name
			{
				str = execName;
				header = [[NSString alloc] initWithUTF8String:"Executable"];
			}
			break;
				
			case PROJPROPERTIES_PRODUCTNAME:
			// Product Name
			{
				str = prodName;
				header = [[NSString alloc] initWithUTF8String:"Product Name"];
			}
			break;
		}
		
		if(str!=nil)
		{
			ProjectSettingsStringViewController* viewCtrl = nil;
			viewCtrl = [[ProjectSettingsStringViewController alloc] initWithIndexPath:indexPath string:str settingsController:self];
			[viewCtrl setTitle:header];
			[header release];
			[self.navigationController pushViewController:viewCtrl animated:YES];
			[viewCtrl release];
		}
	}
	else if(indexPath.section==SETTINGSSECTION_COMPILERSETTINGS)
	{
		if(indexPath.row==COMPILERSETTINGS_SDK)
		//SDK
		{
			NSString* sdkFolder = [[NSString alloc] initWithUTF8String:Global_getSDKFolderPath()];
			FileTools_createDirectory([sdkFolder UTF8String]);
			fileExplorer = [[UIFileBrowserViewController alloc] initWithString:sdkFolder];
			[sdkFolder release];
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
				[self.navigationController presentModalViewController:fileExplorer animated:YES];
				[fileExplorer release];
			}
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didFinishEditingLabel:(NSString*)label
{
	//
}

- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didToggleSwitch:(BOOL)toggle
{
	//
}

- (void)cancelFileExplorer
{
	[fileExplorer dismissModalViewControllerAnimated:YES];
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
	[self setSdk:folder];
	[fileExplorer dismissModalViewControllerAnimated:YES];
}

- (void)onSDKInfoButtonSelected
{
	const char* message = "SDKs can be added by copying a .sdk package from xcode to /var/stash/Developer/SDKs on your device.\n\n"
	"If you have issues, you may need to zip the package before you copy it, and then unzip it on the device. "
	"Sometimes symbolic links can get messed up.";
	showSimpleMessageBox(NULL, message);
}

- (void)dealloc
{
	[settingsTable release];
	[name release];
	[author release];
	[bundleID release];
	[execName release];
	[prodName release];
	[sdk release];
	[super dealloc];
}

@end

@implementation ProjectSettingsStringViewController

@synthesize indexPath;
@synthesize stringBox;
@synthesize settingsController;

- (id)initWithIndexPath:(NSIndexPath*)indexpath string:(NSString*)string settingsController:(ProjectSettingsViewController*)settingsCtrl
{
	if([super init]==nil)
	{
		return nil;
	}
	
	settingsController = settingsCtrl;
	
	indexPath = [indexpath retain];
	stringBox = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, self.view.frame.size.width-40, 36)];
	[stringBox setText:string];
	[stringBox setFont:[UIFont fontWithName: @"Helvetica" size: 26.0f]];
	//[stringBox setBackgroundColor:[UIColor whiteColor]];
	[stringBox setBorderStyle:UITextBorderStyleRoundedRect];
	[stringBox setDelegate:self];
	
	if(indexPath.section==0)
	{
		switch(indexPath.row)
		{
			default:
			[self release];
			return nil;
			
			case PROJPROPERTIES_NAME:
			//Name
			[stringBox setPlaceholder:@"Name"];
			break;
			
			case PROJPROPERTIES_AUTHOR:
			//Author
			[stringBox setPlaceholder:@"Author"];
			break;
			
			case PROJPROPERTIES_BUNDLEID:
			//Bundle Identifier
			[stringBox setPlaceholder:@"com.yourcompany.BundleName"];
			break;
			
			case PROJPROPERTIES_EXECUTABLE:
			//Executable Name
			[stringBox setPlaceholder:@"Executable"];
			break;
			
			case PROJPROPERTIES_PRODUCTNAME:
			//Product Name
			[stringBox setPlaceholder:@"Product"];
			break;
		}
	}
	else
	{
		[self release];
		return nil;
	}
	
	[self.view addSubview:stringBox];
	
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[stringBox setFrame:CGRectMake(20, 40, self.view.frame.size.width-40, 36)];
}

- (BOOL)shouldNavigateBackward
{
	NSString* stringVal = stringBox.text;
	
	if([stringVal length]==0)
	{
		return YES;
	}
	
	if(!ProjectData_checkValidString([stringVal UTF8String]))
	{
		showSimpleMessageBox("Error", "Invalid string");
		return NO;
	}
	
	if(indexPath.section==SETTINGSSECTION_PROJECTPROPERTIES)
	{
		if(indexPath.row==indexPath.row==PROJPROPERTIES_BUNDLEID)
		{
			const char* bundleID = [stringVal UTF8String];
			int total = strlen(bundleID);
			
			int totalPeriods = 0;
			int lastPeriod = 0;
			
			for(int i=0; i<total; i++)
			{
				char c = bundleID[i];
				if(c=='.')
				{
					if(i==0 || i==(total-1) || i==(lastPeriod+1) || totalPeriods==2)
					{
						showSimpleMessageBox("Error", "Invalid bundle identifier");
						return NO;
					}
					else
					{
						totalPeriods++;
						lastPeriod = i;
					}
				}
				else if(c==' ')
				{
					showSimpleMessageBox("Error", "Bunde identifier cannot have spaces");
					return NO;
				}
				else if(c==',')
				{
					showSimpleMessageBox("Error", "Bundle identifier cannot have commas");
					return NO;
				}
			}
			
			if(totalPeriods!=2)
			{
				showSimpleMessageBox("Error", "Invalid bundle identifier");
				return NO;
			}
		}
		else if(indexPath.row==PROJPROPERTIES_EXECUTABLE)
		{
			const char* str = [stringVal UTF8String];
			int total = strlen(str);
			
			for(int i=0; i<total; i++)
			{
				char c = str[i];
				if(c==',' || c==' ')
				{
					showSimpleMessageBox("Error", "Invalid string");
					return NO;
				}
			}
		}
		else if(indexPath.row==PROJPROPERTIES_PRODUCTNAME)
		{
			const char* str = [stringVal UTF8String];
			int total = strlen(str);
			
			for(int i=0; i<total; i++)
			{
				char c = str[i];
				if(c==',')
				{
					showSimpleMessageBox("Error", "Invalid string");
					return NO;
				}
			}
		}
	}
	
	
	if(indexPath.section==SETTINGSSECTION_PROJECTPROPERTIES)
	{
		switch(indexPath.row)
		{
			case PROJPROPERTIES_NAME:
			[settingsController setName:stringVal];
			break;
			
			case PROJPROPERTIES_AUTHOR:
			[settingsController setAuthor:stringVal];
			break;
			
			case PROJPROPERTIES_BUNDLEID:
			[settingsController setBundleID:stringVal];
			break;
			
			case PROJPROPERTIES_EXECUTABLE:
			[settingsController setExecName:stringVal];
			break;
			
			case PROJPROPERTIES_PRODUCTNAME:
			[settingsController setProdName:stringVal];
			break;
		}
	}
	
	return YES;
}

- (void)dealloc
{
	[stringBox release];
	[indexPath release];
	[super dealloc];
}

@end



