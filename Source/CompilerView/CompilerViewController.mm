
#import "CompilerViewController.h"
#import "../Compiler/CompilerTools.h"
#import "../ProjectView/CodeEditorViewController.h"
#import "../Util/UIImageManager.h"
#import "../ProjectLoad/ProjLoadTools.h"
#import "../iCodeAppDelegate.h"
#import "../PreferencesView/GlobalPreferences.h"
#import "CompileErrorViewController.h"
#import "../ConsoleView/ConsoleViewController.h"

@interface CompilerViewController()
- (void)refreshErrorTable;
- (void)setStatus:(const char*)status;
- (void)finishedRunningCompilerWithResult:(int)result;
- (void)finishedCopyingResourcesWithResult:(bool)result;
- (void)finishedInstallingWithResult:(bool)result;
@property (nonatomic, retain) UINavigationBar* statusBar;
@property (nonatomic, retain) UILabel* statusLabel;
@property (nonatomic, retain) NSIndexPath* selectedPath;
@property (nonatomic, retain) NSFilePath* projectRootPath;
@property (nonatomic, assign) LGViewHUD* installHUD;
@end

void CompilerViewController_OutputCallback(void*data, CompilerOutputLine_struct outputLine)
{
	CompilerViewController* viewCtrl = (CompilerViewController*)data;
	[viewCtrl refreshErrorTable];
}

void CompilerViewController_CompileFinishCallback(void*data, int result)
{
	CompilerViewController* viewCtrl = (CompilerViewController*)data;
	[viewCtrl finishedRunningCompilerWithResult:result];
}

void CompilerViewController_CompilerStatusCallback(void*data, const char*status)
{
	CompilerViewController* viewCtrl = (CompilerViewController*)data;
	NSString* statusString = [[NSString alloc] initWithUTF8String:status];
	[viewCtrl.statusLabel setText:statusString];
	[statusString release];
}

void CompilerViewController_CopyResourcesFinishHandler(void*data, bool success)
{
	CompilerViewController* viewCtrl = (CompilerViewController*)data;
	[viewCtrl finishedCopyingResourcesWithResult:success];
}

void CompilerViewController_InstallFinishHandler(void*data, bool success)
{
	CompilerViewController* viewCtrl = (CompilerViewController*)data;
	[viewCtrl finishedInstallingWithResult:success];
}

@implementation CompilerViewController

@synthesize statusBar;
@synthesize statusLabel;
@synthesize projectRootPath;
@synthesize installHUD;
@synthesize selectedPath;

- (id)initWithProjectData:(ProjectData_struct *)data
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	running = NO;
	runWhenFinished = NO;
	closing = NO;
	//scrollOffset = 0;
	selectedPath = nil;
	
	[UIImageManager loadImage:@"Images/error.png"];
	[UIImageManager loadImage:@"Images/warning.png"];
	
	projData = data;
	organizer = CompilerOrganizer_createInstance(projData);
	errorTable = nil;
	installHUD = nil;
	
	NSMutableString* projectRootString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
	[projectRootString appendString:@"/"];
	NSString* projectFolderString = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(projData)];
	[projectRootString appendString:projectFolderString];
	[projectFolderString release];
	projectRootPath = [[NSFilePath alloc] initWithString:projectRootString];
	[projectRootString release];
	
	errorTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
	errorTable.delegate = self;
	errorTable.dataSource = self;
	[self.view addSubview:errorTable];
	
	statusBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
	[statusBar setBarStyle:UIBarStyleBlack];
	UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@""];
	statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-10, 44)];
	[statusLabel setBackgroundColor:[UIColor clearColor]];
	[statusLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
	[statusLabel setTextColor:[UIColor whiteColor]];
	[statusLabel setTextAlignment:NSTextAlignmentLeft];
	[statusLabel setText:navItem.title];
	[navItem setTitleView:statusLabel];
	[statusBar pushNavigationItem:navItem animated:NO];
	[navItem release];
	[self.view addSubview:statusBar];
	
	[UIImageManager loadImage:@"Images/success_strip.png"];
	UIImage* successImage = [UIImageManager getImage:@"Images/success_strip.png"];
	successView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, successImage.size.height)];
	[successView setImage:successImage];
	[UIImageManager loadImage:@"Images/check.png"];
	UIImage* checkMark = [UIImageManager getImage:@"Images/check.png"];
	CGRect checkMarkFrame = CGRectMake(20, (successImage.size.height/2)-(checkMark.size.height/2), checkMark.size.width, checkMark.size.height);
	UIImageView* checkMarkView = [[UIImageView alloc] initWithFrame:checkMarkFrame];
	[checkMarkView setImage:checkMark];
	[successView addSubview:checkMarkView];
	[checkMarkView release];
	CGRect successLabelFrame = CGRectMake(checkMarkFrame.origin.x+checkMarkFrame.size.width+20, (successView.frame.size.height/2)-28, 200, 26);
	UILabel* successLabel = [[UILabel alloc] initWithFrame:successLabelFrame];
	[successLabel setText:@"Build Succeeded"];
	[successLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
	[successLabel setTextColor:[UIColor blackColor]];
	[successLabel setTextAlignment:NSTextAlignmentLeft];
	[successLabel setBackgroundColor:[UIColor clearColor]];
	[successView addSubview:successLabel];
	[successLabel release];
	CGRect successLabel2Frame = CGRectMake(successLabelFrame.origin.x, successLabelFrame.origin.y+successLabelFrame.size.height+5, 200, 26);
	UILabel* successLabel2 = [[UILabel alloc] initWithFrame:successLabel2Frame];
	[successLabel2 setText:@"No Issues"];
	[successLabel2 setFont:[UIFont fontWithName:@"Helvetica" size:16]];
	[successLabel2 setTextColor:[UIColor blackColor]];
	[successLabel2 setTextAlignment:NSTextAlignmentLeft];
	[successLabel2 setBackgroundColor:[UIColor clearColor]];
	[successView addSubview:successLabel2];
	[successLabel2 release];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
	[self.navigationItem setRightBarButtonItem:doneButton animated:NO];
	[doneButton release];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[errorTable setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44)];
	[statusBar setFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
	[statusLabel setFrame:CGRectMake(10, 0, self.view.bounds.size.width-10, 44)];
	[successView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, successView.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	/*if(CompilerOrganizer_totalFiles(organizer)==0)
	{
		scrollOffset = 0;
	}
	
	[errorTable setContentOffset:CGPointMake(0,scrollOffset)];*/
	
	if(selectedPath!=nil && CompilerOrganizer_totalFiles(organizer)!=0)
	{
		[errorTable deselectRowAtIndexPath:selectedPath animated:YES];
	}
	
	if(!running)
	{
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
		[self.navigationItem setRightBarButtonItem:doneButton animated:NO];
		[doneButton release];
	}
}

/*- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	scrollOffset = errorTable.contentOffset.y;
}*/

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if(closing)
	{
		closing = NO;
		[self.navigationItem setRightBarButtonItem:nil animated:NO];
	}
}

- (BOOL)isRunning
{
	return CompilerOrganizer_isRunning(organizer);
}

- (void)setStatus:(const char*)status
{
	CompilerViewController_CompilerStatusCallback(self, status);
}

- (void)build
{
	if(CompilerOrganizer_isRunning(organizer))
	{
		return;
	}
	else
	{
		CompilerOrganizer_clear(organizer);
		[self refreshErrorTable];
	}
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectSettings_struct projSettings = ProjectData_getProjectSettings(appDelegate.projData);
	const char* sdk = ProjectSettings_getSDK(&projSettings);
	if(strlen(sdk)==0 || !Global_checkSDKFolderValid(sdk))
	{
		showSimpleMessageBox("Error", "You need to select a valid SDK for this project");
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
		[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[doneButton release];
	}
	else
	{
		if(organizer==NULL)
		{
			Console_Log("Error: organizer equals NULL");
		}
		else if(organizer->data==NULL)
		{
			Console_Log("Error: organizer->data equals NULL");
		}
		[successView removeFromSuperview];
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
		runWhenFinished = NO;
		[self.navigationItem setTitle:@"Compiling..."];
		running = YES;
		errorTable.delegate = self;
		errorTable.dataSource = self;
		CompilerOrganizer_setCallbacks(organizer, &CompilerViewController_OutputCallback, &CompilerViewController_CompileFinishCallback, &CompilerViewController_CompilerStatusCallback, self);
		CompilerOrganizer_runCompiler(organizer);
	}
}

- (void)buildAndRun
{
	if(CompilerOrganizer_isRunning(organizer))
	{
		return;
	}
	else
	{
		CompilerOrganizer_clear(organizer);
		[self refreshErrorTable];
	}
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectSettings_struct projSettings = ProjectData_getProjectSettings(appDelegate.projData);
	const char* sdk = ProjectSettings_getSDK(&projSettings);
	if(strlen(sdk)==0 || !Global_checkSDKFolderValid(sdk))
	{
		showSimpleMessageBox("Error", "You need to select a valid SDK for this project");
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
		[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[doneButton release];
	}
	else
	{
		if(organizer==NULL)
		{
			Console_Log("Error: organizer equals NULL");
		}
		else if(organizer->data==NULL)
		{
			Console_Log("Error: organizer->data equals NULL");
		}
		[successView removeFromSuperview];
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
		runWhenFinished = YES;
		[self.navigationItem setTitle:@"Compiling..."];
		running = YES;
		errorTable.delegate = self;
		errorTable.dataSource = self;
		CompilerOrganizer_setCallbacks(organizer, &CompilerViewController_OutputCallback, &CompilerViewController_CompileFinishCallback, &CompilerViewController_CompilerStatusCallback, self);
		CompilerOrganizer_runCompiler(organizer);
	}
}

- (void)doneButtonSelected
{
	closing = YES;
	self.selectedPath = nil;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)finishedRunningCompilerWithResult:(int)result
{
	if(result==0)
	{
		CompilerTools_clearInfoPlist(projData);
		CompilerTools_copyResources(projData, &CompilerViewController_CopyResourcesFinishHandler, self);
		[self.navigationItem setTitle:@"Copying Resources.."];
		[self setStatus:"Copying resources"];
	}
	else
	{
		running = NO;
		[self.navigationItem setTitle:@"Compile Failed"];
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
		[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[doneButton release];
		[self setStatus:"Failed"];
	}
}

- (void)finishedCopyingResourcesWithResult:(bool)result
{
	if(runWhenFinished)
	{
		if(result)
		{
			CompilerTools_fillInfoPlist(projData);
			
			if(CompilerOrganizer_totalFiles(organizer)==0)
			{
				[self.view addSubview:successView];
			}
			
			ProjectType projType = ProjectData_getProjectType(projData);
			if(projType==PROJECTTYPE_APPLICATION)
			{
				installHUD = [LGViewHUD defaultHUD];
				[installHUD setActivityIndicatorOn:YES];
				[installHUD setTopText:@"Installing..."];
				[installHUD setBottomText:@""];
				[installHUD showInView:self.view withAnimation:HUDAnimationShowZoom];
				
				[self.navigationItem setTitle:@"Installing..."];
				CompilerTools_installApplication(projData, &CompilerViewController_InstallFinishHandler, self);
				
				[self setStatus:"Installing"];
			}
			else if(projType==PROJECTTYPE_CONSOLE)
			{
				[self.navigationItem setTitle:@"Finished"];
				[self setStatus:"Success"];
				UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
				[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
				[doneButton release];
				
				NSString* slashString = [[NSString alloc] initWithUTF8String:"/"];
				NSMutableString* command = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
				[command appendString:slashString];
				NSString* folderName = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(projData)];
				[command appendString:folderName];
				[folderName release];
				NSString* relPath = [[NSString alloc] initWithUTF8String:"/bin/release/"];
				[command appendString:relPath];
				[relPath release];
				NSString* productName = [[NSString alloc] initWithUTF8String:ProjectData_getProductName(projData)];
				[command appendString:productName];
				[productName release];
				[command appendString:slashString];
				NSString* executableName = [[NSString alloc] initWithUTF8String:ProjectData_getExecutableName(projData)];
				[command appendString:executableName];
				[executableName release];
				
				ConsoleViewController* consoleViewCtrl = [[ConsoleViewController alloc] initWithCommand:command];
				[self.navigationController pushViewController:consoleViewCtrl animated:YES];
				[command release];
				
				running = NO;
			}
		}
		else
		{
			running = NO;
			[self.navigationItem setTitle:@"Resources Failed"];
			UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
			[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
			[doneButton release];
			
			[self setStatus:"Failed to copy resources"];
		}
	}
	else
	{
		if(result)
		{
			CompilerTools_fillInfoPlist(projData);
			
			if(CompilerOrganizer_totalFiles(organizer)==0)
			{
				[self.view addSubview:successView];
			}
			[self.navigationItem setTitle:@"Finished"];
			
			[self setStatus:"Success"];
		}
		else
		{
			[self.navigationItem setTitle:@"Resources Failed"];
			[self setStatus:"Failed to copy resources"];
		}
		running = NO;
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
		[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[doneButton release];
	}
}

- (void)finishedInstallingWithResult:(bool)result
{
	if(result)
	{
		running = NO;
		
		[UIImageManager loadImage:@"Images/rounded-checkmark.png"];
		[installHUD setImage:[UIImageManager getImage:@"Images/rounded-checkmark.png"]];
		[installHUD setTopText:@"Success!"];
		[installHUD setBottomText:@""];
		[installHUD hideAfterDelay:1.5 withAnimation:HUDAnimationHideFadeOut];
		
		[self.navigationItem setTitle:@"Installed"];
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
		[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[doneButton release];
		
		[self setStatus:"Installed"];
		
		CompilerTools_runApplication(ProjectData_getBundleIdentifier(projData));
	}
	else
	{
		running = NO;
		
		[UIImageManager loadImage:@"Images/rounded-fail.png"];
		[installHUD setImage:[UIImageManager getImage:@"Images/rounded-fail.png"]];
		[installHUD setTopText:@"Install Failed"];
		[installHUD setBottomText:@""];
		[installHUD hideAfterDelay:1.5 withAnimation:HUDAnimationHideFadeOut];
		
		[self.navigationItem setTitle:@"Install Failed"];
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
		[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
		[doneButton release];
		
		[self setStatus:"Failed to install"];
	}
	
	installHUD = nil;
}

- (void)refreshErrorTable
{
	[errorTable reloadData];
}

- (void)dealloc
{
	CompilerOrganizer_destroyInstance(organizer);
	organizer = NULL;
	[errorTable release];
	[projectRootPath release];
	[successView release];
	[statusBar release];
	[statusLabel release];
	[selectedPath release];
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return CompilerOrganizer_totalFiles(organizer);
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* pathString = [[NSString alloc] initWithUTF8String:CompilerOrganizer_getFile(organizer, (unsigned int)section)];
	NSFilePath* fullFilePath = [[NSFilePath alloc] initWithString:pathString];
	if([fullFilePath containsSubfoldersOf:projectRootPath])
	{
		NSFilePath* subFilePath = [fullFilePath pathRelativeTo:projectRootPath];
		[pathString release];
		[fullFilePath release];
		return [subFilePath pathAsString];
	}
	else
	{
		[pathString release];
		NSString* pathString = [fullFilePath pathAsString];
		[fullFilePath release];
		return pathString;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return CompilerOrganizer_totalErrors(organizer, (unsigned int)section);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSMutableString* cellID = [[NSMutableString alloc] initWithString:@"s"];
	NSNumber* num = [[NSNumber alloc] initWithInt:indexPath.section];
	[cellID appendString:[num stringValue]];
	[num release];
	[cellID appendString:@"r"];
	num = [[NSNumber alloc] initWithInt:indexPath.row];
	[cellID appendString:[num stringValue]];
	[num release];
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	[cell.textLabel setNumberOfLines:0];
	[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	
	NSMutableString* cellText = [[NSMutableString alloc] initWithUTF8String:""];
	NSString* sectionFilePathString = [[NSString alloc] initWithUTF8String:CompilerOrganizer_getFile(organizer, indexPath.section)];
	
	CompilerOutputLine_struct outputLine = CompilerOrganizer_getError(organizer, indexPath.section, indexPath.row);
	
	NSString* errorType = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getErrorType(&outputLine)];
	
	BOOL isWarning = [errorType isEqual:@"warning"];
	BOOL isClangWarning = [errorType isEqual:@"clang warning"];
	BOOL isLibtoolWarning = [errorType isEqual:@"libtool warning"];
	
	if(isWarning || isClangWarning || isLibtoolWarning || [errorType isEqual:@"error"] || [errorType isEqual:@"fatal error"] || [errorType isEqual:@"ld"]
	   || [errorType isEqual:@"clang error"] || [errorType isEqual:@"clang fatal error"] || [errorType isEqual:@"undefined symbols"] || [errorType isEqual:@"libtool error"] || [errorType isEqual:@"libtool fatal error"])
	{
		NSString* filePathString = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getFileName(&outputLine)];
		if(filePathString==nil || [filePathString length]==0)
		{
			NSString* outputString = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getOutput(&outputLine)];
			[cellText appendString:outputString];
			[outputString release];
		}
		else
		{
			if([filePathString isEqual:sectionFilePathString])
			{
				NSString* messageString = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getMessage(&outputLine)];
				[cellText appendString:messageString];
				[messageString release];
			}
			else
			{
				[cellText appendString:filePathString];
				[cellText appendString:@": "];
				NSString* messageString = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getMessage(&outputLine)];
				[cellText appendString:messageString];
				[messageString release];
			}
		}
		if(isWarning || isClangWarning || isLibtoolWarning)
		{
			[cell.imageView setImage:[UIImageManager getImage:@"Images/warning.png"]];
		}
		else
		{
			[cell.imageView setImage:[UIImageManager getImage:@"Images/error.png"]];
		}
		[filePathString release];
	}
	else if([errorType isEqual:@"Error in file included from"])
	{
		[cellText appendString:@"Error in file included from "];
		NSString* filePathString = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getFileName(&outputLine)];
		NSFilePath* filePath = [[NSFilePath alloc] initWithString:filePathString];
		if([filePath containsSubfoldersOf:projectRootPath])
		{
			[filePathString release];
			NSString* pathString = [[filePath pathRelativeTo:projectRootPath] pathAsString];
			if([pathString UTF8String][0]=='/')
			{
				filePathString = [[NSString alloc] initWithString:[pathString substringFromIndex:1]];
			}
			else
			{
				filePathString = [[NSString alloc] initWithString:pathString];
			}
		}
		[cellText appendString:filePathString];
		[filePathString release];
		[filePath release];
		
		[cell.imageView setImage:[UIImageManager getImage:@"Images/error.png"]];
	}
	else
	{
		NSString* outputString = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getOutput(&outputLine)];
		[cellText appendString:outputString];
		[outputString release];
		
		[cell.imageView setImage:[UIImageManager getImage:@"Images/warning.png"]];
	}
	
	[cell.textLabel setText:cellText];
	[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	
	[sectionFilePathString release];
	[errorType release];
	[cellText release];
	[cellID release];
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	CompilerOutputLine_struct outputLine = CompilerOrganizer_getError(organizer, indexPath.section, indexPath.row);
	const char* fileName = CompilerOutputLine_getFileName(&outputLine);
	if(strlen(fileName)>1)
	{
		NSString* filePathString = [[NSString alloc] initWithUTF8String:fileName];
		
		CodeEditorViewController* codeEditor = [[CodeEditorViewController alloc] init];
		if([codeEditor loadWithFile:filePathString])
		{
			self.selectedPath = indexPath;
			NSFilePath* filePath = [[NSFilePath alloc] initWithString:filePathString];
			if(![filePath containsSubfoldersOf:projectRootPath])
			{
				[codeEditor setFileLocked:YES];
			}
			[filePath release];
			
			[self.navigationController pushViewController:codeEditor animated:YES];
			int line = CompilerOutputLine_getLine(&outputLine);
			if(line>0)
			{
				line-=1;
			}
			int offset = CompilerOutputLine_getOffset(&outputLine);
			if(offset>0)
			{
				offset-=1;
			}
			[codeEditor goToLine:line offset:offset];
		}
		else
		{
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		[codeEditor release];
		[filePathString release];
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	CompilerOutputLine_struct outputLine = CompilerOrganizer_getError(organizer, indexPath.section, indexPath.row);
	CompileErrorViewController* viewCtrl = [[CompileErrorViewController alloc] initWithOutputLine:outputLine];
	[self.navigationController pushViewController:viewCtrl animated:YES];
	[viewCtrl release];
}

@end
