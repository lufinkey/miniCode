
#import "ProjectSettingsViewController.h"
#import "PlistViewerViewController.h"
#import "../iCodeAppDelegate.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../Navigation/UINavigator.h"
#import "../PreferencesView/GlobalPreferences.h"
#import "../Util/UIBarImageButtonItem.h"
#import "../IconManager/IconManager.h"
#import "../Compiler/CompilerTools.h"
#import "../DDAlertPrompt/DDAlertPrompt.h"

static const int SETTINGSSECTION_PROJECTPROPERTIES = 0;
static const int SETTINGSSECTION_COMPILERSETTINGS = 1;

static const int PROJPROPERTIES_NAME = 0;
static const int PROJPROPERTIES_AUTHOR = 1;
static const int PROJPROPERTIES_BUNDLEID = 2;
static const int PROJPROPERTIES_EXECUTABLE = 3;
static const int PROJPROPERTIES_PRODUCTNAME = 4;

static const int COMPILERSETTINGS_SDK = 0;
static const int COMPILERSETTINGS_WARNINGS = 1;
static const int COMPILERSETTINGS_ASSEMBLERFLAGS = 2;
static const int COMPILERSETTINGS_COMPILERFLAGS = 3;

@implementation ProjectSettingsViewController

@synthesize settingsTable;

@synthesize name;
@synthesize author;
@synthesize bundleID;
@synthesize execName;
@synthesize prodName;
@synthesize sdk;
@synthesize warnings;

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
	warnings = [[NSMutableArray alloc] init];
	StringList_struct disabledWarnings = ProjectSettings_getDisabledWarnings(&projSettings);
	for(int i=0; i<StringList_size(&disabledWarnings); i++)
	{
		NSString* warning = [[NSString alloc] initWithUTF8String:StringList_get(&disabledWarnings, i)];
		[warnings addObject:warning];
		[warning release];
	}
	assemblerFlags = [[NSMutableArray alloc] init];
	StringList_struct flags = ProjectSettings_getAssemblerFlags(&projSettings);
	for(int i=0; i<StringList_size(&flags); i++)
	{
		NSString* flag = [[NSString alloc] initWithUTF8String:StringList_get(&flags, i)];
		[assemblerFlags addObject:flag];
		[flag release];
	}
	compilerFlags = [[NSMutableArray alloc] init];
	flags = ProjectSettings_getCompilerFlags(&projSettings);
	for(int i=0; i<StringList_size(&flags); i++)
	{
		NSString* flag = [[NSString alloc] initWithUTF8String:StringList_get(&flags, i)];
		[compilerFlags addObject:flag];
		[flag release];
	}
	
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
	StringList_struct disabledWarnings = ProjectSettings_getDisabledWarnings(&projSettings);
	StringList_clear(&disabledWarnings);
	for(unsigned int i=0; i<[warnings count]; i++)
	{
		StringList_add(&disabledWarnings, [[warnings objectAtIndex:i] UTF8String]);
	}
	StringList_struct flags = ProjectSettings_getAssemblerFlags(&projSettings);
	StringList_clear(&flags);
	for(unsigned int i=0; i<[assemblerFlags count]; i++)
	{
		StringList_add(&flags, [[assemblerFlags objectAtIndex:i] UTF8String]);
	}
	flags = ProjectSettings_getCompilerFlags(&projSettings);
	StringList_clear(&flags);
	for(unsigned int i=0; i<[compilerFlags count]; i++)
	{
		StringList_add(&flags, [[compilerFlags objectAtIndex:i] UTF8String]);
	}
	
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
		return 4;
	}
	
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* cellID = nil;
	id objVal = nil;
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
			
			case COMPILERSETTINGS_WARNINGS:
			//Warnings
			cellID = [[NSString alloc] initWithUTF8String:"Warnings"];
			objVal = warnings;
			break;
			
			case COMPILERSETTINGS_ASSEMBLERFLAGS:
			//Assembler flags
			cellID = [[NSString alloc] initWithUTF8String:"Assembler Flags"];
			objVal = assemblerFlags;
			break;
			
			case COMPILERSETTINGS_COMPILERFLAGS:
			//Compiler flags
			cellID = [[NSString alloc] initWithUTF8String:"Compiler Flags"];
			objVal = compilerFlags;
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
	[cell setDelegate:self];
	[cellID release];
	
	if(indexPath.section==SETTINGSSECTION_COMPILERSETTINGS)
	{
		if(indexPath.row==COMPILERSETTINGS_WARNINGS || indexPath.row==COMPILERSETTINGS_ASSEMBLERFLAGS
		   || indexPath.row==COMPILERSETTINGS_COMPILERFLAGS)
		{
			[cell.detailTextLabel setText:@""];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		}
	}
	
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
		switch(indexPath.row)
		{
			case COMPILERSETTINGS_SDK:
			//SDK
			{
				NSString* sdkFolder = [[NSString alloc] initWithUTF8String:Global_getSDKFolderPath()];
				FileTools_createDirectory([sdkFolder UTF8String]);
				fileExplorer = [[UIFileBrowserViewController alloc] initWithString:sdkFolder delegate:self];
				[sdkFolder release];
				if(fileExplorer!=nil)
				{
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
			break;
			
			case COMPILERSETTINGS_WARNINGS:
			//Warnings
			{
				StringList_struct* list = CompilerTools_loadWarningList();
				ProjectSettingsToggleListViewController* toggleList = [[ProjectSettingsToggleListViewController alloc] initWithList:list disabled:warnings];
				if(toggleList!=nil)
				{
					[self.navigationController pushViewController:toggleList animated:YES];
					[toggleList release];
				} 
			}
			break;
			
			case COMPILERSETTINGS_ASSEMBLERFLAGS:
			//Assembler flags
			{
				ProjectSettingsStringArrayViewController* stringArray = [[ProjectSettingsStringArrayViewController alloc] initWithArray:assemblerFlags];
				[self.navigationController pushViewController:stringArray animated:YES];
				[stringArray release];
			}
			break;
			
			case COMPILERSETTINGS_COMPILERFLAGS:
			//Compiler flags
			{
				ProjectSettingsStringArrayViewController* stringArray = [[ProjectSettingsStringArrayViewController alloc] initWithArray:compilerFlags];
				[self.navigationController pushViewController:stringArray animated:YES];
				[stringArray release];
			}
			break;
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
	[warnings release];
	[assemblerFlags release];
	[compilerFlags release];
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
		if(indexPath.row==PROJPROPERTIES_BUNDLEID)
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



@implementation ProjectSettingsToggleListViewController

@synthesize listTable;

- (id)initWithList:(StringList_struct*)elementList disabled:(NSMutableArray*)elementsDisabled
{
	list = elementList;
	disabled = elementsDisabled;
	
	if([super init]==nil)
	{
		return nil;
	}
	
	listTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[listTable setDelegate:self];
	[listTable setDataSource:self];
	[self.view addSubview:listTable];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[listTable setFrame:self.view.frame];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return StringList_size(list);
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* cellID = [[NSString alloc] initWithUTF8String:StringList_get(list, indexPath.row)];
	BOOL toggle = YES;
	for(unsigned int i=0; i<[disabled count]; i++)
	{
		if([cellID isEqual:[disabled objectAtIndex:i]])
		{
			toggle = NO;
			i = [disabled count];
		}
	}
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	[cell.textLabel setText:cellID];
	if(toggle)
	{
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	}
	else
	{
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	[cellID release];
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString* cellID = [[NSString alloc] initWithUTF8String:StringList_get(list, indexPath.row)];
	
	for(unsigned int i=0; i<[disabled count]; i++)
	{
		if([cellID isEqual:[disabled objectAtIndex:i]])
		{
			[disabled removeObjectAtIndex:i];
			[cellID release];
			
			UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			return;
			
		}
	}
	[disabled addObject:cellID];
	[cellID release];
	
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setAccessoryType:UITableViewCellAccessoryNone];
}

- (void)dealloc
{
	[listTable release];
	StringList_destroyInstance(list);
	[super dealloc];
}

@end



@interface ProjectSettingsStringArrayViewController()
- (void)onAddButtonSelected;
@end

@implementation ProjectSettingsStringArrayViewController

@synthesize listTable;

- (id)initWithArray:(NSMutableArray*)list
{
	array = list;
	selectedIndex = -1;
	
	if([super init]==nil)
	{
		return nil;
	}
	
	listTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[listTable setDelegate:self];
	[listTable setDataSource:self];
	[self.view addSubview:listTable];
	
	UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButtonSelected)];
	[self.navigationItem setRightBarButtonItem:addButton];
	[addButton release];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[listTable setFrame:self.view.frame];
}

- (void)onAddButtonSelected
{
	selectedIndex = -1;
	
	DDAlertPrompt* alert = [[DDAlertPrompt alloc] initWithTitle:@"Add Flag" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitle:@"Confirm"];
	[alert show];
	[alert.plainTextField setPlaceholder:@""];
	[alert release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [array count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSNumber* num = [[NSNumber alloc] initWithInt:indexPath.row];
	NSString* cellID = [num stringValue];
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	[num release];
	
	[cell.textLabel setText:[array objectAtIndex:indexPath.row]];
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	selectedIndex = indexPath.row;
	
	DDAlertPrompt* alert = [[DDAlertPrompt alloc] initWithTitle:@"Edit Flag" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitle:@"Confirm"];
	[alert show];
	[alert.plainTextField setText:[array objectAtIndex:indexPath.row]];
	[alert.plainTextField setPlaceholder:@""];
	[alert release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[array removeObjectAtIndex:indexPath.row];
	NSArray* indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
	[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
	[indexPaths release];
}

- (void)didPresentAlertView:(UIAlertView*)alertView
{
	if([alertView isKindOfClass:[DDAlertPrompt class]])
	{
		DDAlertPrompt* textFieldAlert = (DDAlertPrompt*)alertView;
		[textFieldAlert.plainTextField becomeFirstResponder];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if([alertView isKindOfClass:[DDAlertPrompt class]])
	{
		DDAlertPrompt* textFieldAlert = (DDAlertPrompt*)alertView;
		UITextField*textField = textFieldAlert.plainTextField;
		if(buttonIndex==1)
		//OK
		{
			if(selectedIndex==-1)
			{
				[array addObject:textField.text];
				[listTable reloadData];
			}
			else
			{
				[array replaceObjectAtIndex:buttonIndex withObject:textField.text];
				NSIndexPath* indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
				UITableViewCell* cell = [listTable cellForRowAtIndexPath:indexPath];
				[cell.textLabel setText:textField.text];
			}
		}
	}
}

- (void)dealloc
{
	[listTable release];
	[super dealloc];
}

@end



