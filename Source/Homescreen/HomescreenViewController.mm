
#import "HomescreenViewController.h"
#import "../iCodeAppDelegate.h"
#import "../Util/UIImageManager.h"
#import <QuartzCore/QuartzCore.h>
#import "../DeprecationFix/DeprecationDefines.h"

@implementation HomescreenViewController

@synthesize xcodeLogo;

- (id)init
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	[self setTitle:@"miniCode"];
	
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	recentProjects = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
	recentProjects.layer.cornerRadius = 20;
	
	//project options table
	int tableOffsetY = 250;
	projectOptions = [[UITableView alloc] initWithFrame:CGRectMake(0, tableOffsetY, self.view.bounds.size.width, self.view.bounds.size.height-tableOffsetY) style:UITableViewStyleGrouped];
	projectOptions.delegate = self;
	projectOptions.dataSource = self;
	projectOptions.scrollEnabled = NO;
	[projectOptions setBackgroundView:nil];
	
	[self.view addSubview:projectOptions];
	
	//xcode logo image
	int centerX = self.view.bounds.size.width/2;
	int logoOffsetY = 8;
	int logoScale = 200;
	[UIImageManager loadImage:@"Images/xcode_logo.png"];
	xcodeLogo = [UIImageManager getImage:@"Images/xcode_logo.png"];
	
	xcodeLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(centerX-(logoScale/2), logoOffsetY, logoScale, logoScale)];
	[xcodeLogoView setImage:xcodeLogo];
	
	[self.view addSubview:xcodeLogoView];
	
	//"Welcome to Minicode" text
	int welcomeLabelHeight = 50;
	welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, logoScale+logoOffsetY, self.view.bounds.size.width, welcomeLabelHeight)];
	[welcomeLabel setText:@"Welcome to miniCode"];
	[welcomeLabel setTextColor:[UIColor darkGrayColor]];
	[welcomeLabel setTextAlignment:UITextAlignmentCenter];
	[welcomeLabel setBackgroundColor:[UIColor clearColor]];
	[welcomeLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 24.0f]];
	[self.view addSubview:welcomeLabel];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	if(orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		[projectOptions reloadData];
		
		recentProjects.delegate = nil;
		recentProjects.dataSource = nil;
		[recentProjects removeFromSuperview];
		
		int tableOffsetY = 250;
		[projectOptions setFrame:CGRectMake(0, tableOffsetY, self.view.bounds.size.width, self.view.bounds.size.height-tableOffsetY)];
		int centerX = self.view.bounds.size.width/2;
		int logoOffsetY = 8;
		int logoScale = 200;
		[xcodeLogoView setFrame:CGRectMake(centerX-(logoScale/2), logoOffsetY, logoScale, logoScale)];
		int welcomeLabelHeight = 50;
		[welcomeLabel setFrame:CGRectMake(0, logoOffsetY+logoScale, self.view.bounds.size.width, welcomeLabelHeight)];
	}
	else if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		recentProjects.delegate = nil;
		recentProjects.dataSource = nil;
		[recentProjects removeFromSuperview];
		
		if([projectOptions numberOfRowsInSection:0]==3)
		{
			NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
			NSArray* indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
			[projectOptions deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
			[indexPaths release];
		}
		
		int allOffset = 40;
		
		int w = self.view.bounds.size.width;
		int centerX = w/2;
		int tableOffsetY = 250+allOffset;
		[projectOptions setFrame:CGRectMake(10, tableOffsetY, centerX - 20, self.view.bounds.size.height - tableOffsetY)];
		int logoOffsetY = 8+allOffset;
		int logoScale = 200;
		[xcodeLogoView setFrame:CGRectMake((centerX/2)-(logoScale/2), logoOffsetY, logoScale, logoScale)];
		int welcomeLabelHeight = 50;
		[welcomeLabel setFrame:CGRectMake(0, logoOffsetY+logoScale, (w/2), welcomeLabelHeight)];
		
		[recentProjects setFrame:CGRectMake(centerX + 10, 20, (w/2)-20, self.view.bounds.size.height - 40)];
		
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		[appDelegate.loadProjectController loadSavedProjectList];
		recentProjects.delegate = appDelegate.loadProjectController;
		recentProjects.dataSource = appDelegate.loadProjectController;
		[recentProjects reloadData];
		[self.view addSubview:recentProjects];
	}
	else
	{
		[projectOptions reloadData];
		
		recentProjects.delegate = nil;
		recentProjects.dataSource = nil;
		[recentProjects removeFromSuperview];
		
		int centerX = self.view.bounds.size.width/2;
		[projectOptions setFrame:CGRectMake(centerX, 0, self.view.bounds.size.width/2, self.view.bounds.size.height)];
		centerX = centerX/2;
		int logoOffsetY = 8;
		int logoScale = 200;
		[xcodeLogoView setFrame:CGRectMake(centerX-(logoScale/2), logoOffsetY, logoScale, logoScale)];
		int welcomeLabelHeight = 50;
		[welcomeLabel setFrame:CGRectMake(0, logoOffsetY+logoScale, self.view.bounds.size.width/2, welcomeLabelHeight)];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad
	   && (self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight))
	{
		return 2;
	}
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"";
	NSString *cellText = @"";
	switch(indexPath.row)
	{
		case 0:
		cellIdentifier = @"createProject";
		cellText = @"Create New Project";
		break;
			
		case 1:
		if(!(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad
		   && (self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)))
		{
			cellIdentifier = @"loadProject";
			cellText = @"Load Project";
			break;
		}
			
		case 2:
		cellIdentifier = @"preferences";
		cellText = @"Preferences";
		break;
			
		default:
		Console_Log("Unknown cell index in HomescreenOptionsTableDelegate in cellForRowAtIndexPath");
		cellIdentifier = @"unknown";
		cellText = @"dafuq";
		break;
	}
	UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	[cell.textLabel setText:cellText];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	
	switch(indexPath.row)
	{
		case 0:
		[self.navigationController presentModalViewController:appDelegate.createProjectNavigator animated:YES];
		break;
		
		case 1:
		if(!(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad
			 && (self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)))
		{
			[self.navigationController presentModalViewController:appDelegate.loadProjectController animated:YES];
			break;
		}
		
		case 2:
		[self.navigationController presentModalViewController:appDelegate.preferencesNavigator animated:YES];
		break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
	[xcodeLogo release];
	[recentProjects release];
	[projectOptions release];
	[xcodeLogoView release];
	[welcomeLabel release];
	[super dealloc];
}

@end
