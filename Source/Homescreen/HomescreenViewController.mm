
#import "HomescreenViewController.h"
#import "../iCodeAppDelegate.h"
#import "../Util/UIImageManager.h"

@implementation HomescreenViewController

@synthesize xcodeLogo;

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	[self setTitle:@"miniCode"];
	
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	//project options table
	int tableOffsetY = 250;
	projectOptions = [[UITableView alloc] initWithFrame:CGRectMake(0, tableOffsetY, self.view.frame.size.width, self.view.frame.size.height-tableOffsetY) style:UITableViewStyleGrouped];
	projectOptions.delegate = self;
	projectOptions.dataSource = self;
	projectOptions.scrollEnabled = NO;
	[projectOptions setBackgroundView:nil];
	
	[self.view addSubview:projectOptions];
	
	//xcode logo image
	int centerX = self.view.frame.size.width/2;
	int logoOffsetY = 8;
	int logoScale = 200;
	[UIImageManager loadImage:@"Images/xcode_logo.png"];
	xcodeLogo = [UIImageManager getImage:@"Images/xcode_logo.png"];
	
	xcodeLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(centerX-(logoScale/2), logoOffsetY, logoScale, logoScale)];
	[xcodeLogoView setImage:xcodeLogo];
	
	[self.view addSubview:xcodeLogoView];
	
	//"Welcome to Minicode" text
	int welcomeLabelHeight = 50;
	welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, logoScale+8, self.view.frame.size.width, welcomeLabelHeight)];
	[welcomeLabel setText:@"Welcome to miniCode"];
	[welcomeLabel setTextColor:[UIColor darkGrayColor]];
	[welcomeLabel setTextAlignment:UITextAlignmentCenter];
	[welcomeLabel setBackgroundColor:[UIColor clearColor]];
	[welcomeLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 24.0f]];
	[self.view addSubview:welcomeLabel];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[projectOptions setFrame:CGRectMake(0, projectOptions.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-projectOptions.frame.origin.y)];
	int centerX = self.view.frame.size.width/2;
	[xcodeLogoView setFrame:CGRectMake(centerX-(xcodeLogoView.frame.size.width/2), xcodeLogoView.frame.origin.y, xcodeLogoView.frame.size.width, xcodeLogoView.frame.size.height)];
	[welcomeLabel setFrame:CGRectMake(0, welcomeLabel.frame.origin.y, self.view.frame.size.width, welcomeLabel.frame.size.height)];
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
		cellIdentifier = @"loadProject";
		cellText = @"Load Project";
		break;
			
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
		[self.navigationController presentModalViewController:appDelegate.loadProjectController animated:YES];
		break;
		
		case 2:
		[self.navigationController presentModalViewController:appDelegate.preferencesNavigator animated:YES];
		break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
	[xcodeLogo release];
	[projectOptions release];
	[xcodeLogoView release];
	[welcomeLabel release];
	[super dealloc];
}

@end
