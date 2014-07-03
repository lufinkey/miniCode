
#import "LoadProjectViewController.h"
#import "../iCodeAppDelegate.h"
#import "ProjLoadTools.h"

void deleteProjectAlertHandler(void*data, int buttonIndex)
{
	LoadProjectViewController* viewCtrl = (LoadProjectViewController*)data;
	
	NSIndexPath* indexPath = viewCtrl.pendingDelete;
	
	if(buttonIndex == 1)
	{
		NSMutableString*path = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
		[path appendString:@"/"];
		[path appendString:[viewCtrl.projectFolders objectAtIndex:indexPath.row]];
		bool success = FileTools_deleteFromFilesystem([path UTF8String]);
		if(success)
		{
			[viewCtrl.projectFolders removeObjectAtIndex:indexPath.row];
			[viewCtrl.projectNames removeObjectAtIndex:indexPath.row];
			[viewCtrl.projectDates removeObjectAtIndex:indexPath.row];
			[viewCtrl.recentProjects deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		}
		else
		{
			NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Unable to delete project "];
			[message appendString:[viewCtrl.projectNames objectAtIndex:indexPath.row]];
			
			showSimpleMessageBox("Error", [message UTF8String]);
			
			[message release];
		}
		
		[path release];
	}
	
	viewCtrl.pendingDelete = nil;
}

@implementation LoadProjectViewController

@synthesize pendingDelete;

@synthesize navBar;
@synthesize recentProjects;

@synthesize projectNames;
@synthesize projectFolders;
@synthesize projectDates;

- (id)init
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	pendingDelete = nil;
	
	projectNames = [[NSMutableArray alloc] init];
	projectFolders = [[NSMutableArray alloc] init];
	projectDates = [[NSMutableArray alloc] init];
	
	navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	[navBar setBarStyle:UIBarStyleBlack];
	UINavigationItem*navItem = [[UINavigationItem alloc] initWithTitle:@"Load Project"];
	UIBarButtonItem*cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonSelected)];
	[navItem setLeftBarButtonItem:cancelButton];
	[navBar pushNavigationItem:navItem animated:YES];
	[self.view addSubview:navBar];
	[navItem release];
	[cancelButton release];
	
	recentProjects = [[UITableView alloc] initWithFrame:CGRectMake(0, navBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-navBar.frame.size.height)];
	recentProjects.delegate = self;
	recentProjects.dataSource = self;
	[self.view addSubview:recentProjects];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self loadSavedProjectList];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self resetLayout];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[navBar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, navBar.bounds.size.height)];
	[recentProjects setFrame:CGRectMake(0, navBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height-navBar.bounds.size.height)];
	//[recentProjects reloadData];
}

- (void)cancelButtonSelected
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)loadSavedProjectList
{
	[projectFolders removeAllObjects];
	[projectNames removeAllObjects];
	[projectDates removeAllObjects];
	
	StringList_struct* folders = FileTools_getFoldersInDirectory(ProjLoad_getSavedProjectsFolder());
	if(folders==NULL)
	{
		return;
	}
	
	NSString*savedProjectsFolder = [[NSString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
	for(int i=0; i<StringList_size(folders); i++)
	{
		NSString*folder = [[NSString alloc] initWithUTF8String:StringList_get(folders, i)];
		NSMutableString* path = [[NSMutableString alloc] initWithString:savedProjectsFolder];
		[path appendString:@"/"];
		[path appendString:folder];
		[path appendString:@"/project.plist"];
		
		NSDictionary*dict = (NSDictionary*)ProjLoad_loadAllocatedPlist([path UTF8String]);
		if(dict==nil)
		{
			StringList_remove(folders, i);
			i--;
		}
		else
		{
			NSString*projectName = [dict objectForKey:@"name"];
			if(projectName == nil)
			{
				projectName = folder;
			}
			NSDate*projectDate = [dict objectForKey:@"LastAccess"];
			if(projectDate==nil)
			{
				projectDate = [NSDate distantPast];
			}
			
			[projectFolders addObject:folder];
			[projectNames addObject:projectName];
			[projectDates addObject:projectDate];
			
			[dict release];
		}
		
		[folder release];
		[path release];
	}
	[savedProjectsFolder release];
	StringList_destroyInstance(folders);
	
	[self sortProjectList];
	
	[recentProjects reloadData];
}

- (void)sortProjectList
{
	int total = [projectDates count];
	
	for(unsigned int i = 0; i < total; i++)
	{
		for(unsigned int j = 1; j < (total-i); j++)
		{
			if([[projectDates objectAtIndex:(j-1)] compare:[projectDates objectAtIndex:j]]==NSOrderedAscending)
			{
				NSDate*date = [projectDates objectAtIndex:(j-1)];
				[date retain];
				[projectDates replaceObjectAtIndex:(j-1) withObject:[projectDates objectAtIndex:j]];
				[projectDates replaceObjectAtIndex:j withObject:date];
				[date release];
				
				NSString*name = [projectNames objectAtIndex:(j-1)];
				[name retain];
				[projectNames replaceObjectAtIndex:(j-1) withObject:[projectNames objectAtIndex:j]];
				[projectNames replaceObjectAtIndex:j withObject:name];
				[name release];
				
				NSString*folder = [projectFolders objectAtIndex:(j-1)];
				[folder retain];
				[projectFolders replaceObjectAtIndex:(j-1) withObject:[projectFolders objectAtIndex:j]];
				[projectFolders replaceObjectAtIndex:j withObject:folder];
				[folder release];
			}
		}
	}
	
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[projectNames release];
	[projectFolders release];
	[projectDates release];
	
	[navBar release];
	[recentProjects release];
	[super dealloc];
}

#pragma mark -
#pragma mark Table View Events

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Recent Projects";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [projectNames count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* cellIdentifier = [projectFolders objectAtIndex:indexPath.row];
	UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
	}
	
	[cell.textLabel setText:[projectNames objectAtIndex:indexPath.row]];
	
	NSMutableString* details = [[NSMutableString alloc] initWithString:cellIdentifier];
	[details appendString:@" - "];
	[details appendString:[[[projectDates objectAtIndex:indexPath.row] description] substringToIndex:20]];
	
	[cell.detailTextLabel setText:details];
	
	[details release];
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		const char* buttonLabels[2] = {"Cancel", "OK"};
		NSMutableString* message = [[NSMutableString alloc] initWithUTF8String:"Are you sure that you want to delete the project "];
		[message appendString:[projectNames objectAtIndex:indexPath.row]];
		[message appendString:@"? This cannot be undone."];
		
		self.pendingDelete = indexPath;
		
		showSimpleMessageBox("Warning", [message UTF8String], buttonLabels, 2, self, NULL, &deleteProjectAlertHandler);
		
		[message release];
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	
	appDelegate.projData = ProjLoad_loadProjectDataFromSavedProject([[projectFolders objectAtIndex:indexPath.row] UTF8String]);
	if(appDelegate.projData==NULL)
	{
		showSimpleMessageBox("Error", "Unable to load project");
	}
	else
	{
		[appDelegate.projectTreeController loadWithProjectData:appDelegate.projData];
		if(self.parentViewController!=nil || ([self respondsToSelector:@selector(presentingViewController)] && [self performSelector:@selector(presentingViewController)]!=nil))
		{
			[self dismissModalViewControllerAnimated:YES];
		}
		[appDelegate.rootNavigator pushViewController:appDelegate.projectTreeController animated:YES];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
