
#import "TemplateInfoViewController.h"
#import "../iCodeAppDelegate.h"
#import "CreateProjectViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ProjLoadTools.h"

@implementation TemplateInfoViewController

@synthesize templateName;
@synthesize categoryName;

@synthesize name;
@synthesize icon;
@synthesize info;

- (id)initWithTemplate:(NSString*)templateTitle category:(NSString*)category
{
	UIImage*image = (UIImage*)ProjLoad_loadTemplateIcon([category UTF8String], [templateTitle UTF8String]);
	NSMutableDictionary*nfo = (NSMutableDictionary*)ProjLoad_loadTemplateInfo([category UTF8String], [templateTitle UTF8String]);
	if(image==nil || nfo==nil)
	{
		[self release];
		return nil;
	}
	NSString*description = [nfo objectForKey:@"Description"];
	
	if([super init]==nil)
	{
		return nil;
	}
	
	self.templateName = templateTitle;
	self.categoryName = category;
	
	int size = (self.view.frame.size.width)/2;
	
	name = [[UILabel alloc] initWithFrame:CGRectMake(size, 0, size, size)];
	[self.name setText:templateTitle];
	[self.name setBackgroundColor:[UIColor clearColor]];
	[self.name setFont:[UIFont fontWithName: @"Trebuchet MS" size: 18.0f]];
	[self.name setNumberOfLines:0];
	[self.name setTextAlignment:UITextAlignmentCenter];
	icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
	[self.icon setImage:image];
	info = [[UITextView alloc] initWithFrame:CGRectMake(0, size, self.view.frame.size.width, self.view.frame.size.height-size)];
	[self.info setText:description];
	[self.info setEditable:NO];
	[self.info setFont:[UIFont fontWithName: @"Helvetica" size: 16.0f]];
	self.info.layer.borderWidth = 2;
	self.info.layer.borderColor = [[UIColor grayColor] CGColor];
	self.info.contentInset = UIEdgeInsetsMake(2,0,0,0);
	
	[self.view addSubview:self.name];
	[self.view addSubview:self.icon];
	[self.view addSubview:self.info];
	
	UIBarButtonItem*selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(selectTemplate)];
	[self.navigationItem setRightBarButtonItem:selectButton animated:YES];
	[selectButton release];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	int size = (self.view.frame.size.width)/2;
	[name setFrame:CGRectMake(size, 0, size, size)];
	[icon setFrame:CGRectMake(0, 0, size, size)];
	[info setFrame:CGRectMake(0, size, self.view.frame.size.width, self.view.frame.size.height-size)];
}

- (void)selectTemplate
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.createProjectController closeAndLoadTemplate:templateName category:categoryName];
}

- (void)dealloc
{
	[templateName release];
	[categoryName release];
	
	[name release];
	[info release];
	[icon release];
	[super dealloc];
}

@end
