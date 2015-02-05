
#import "TemplateInfoViewController.h"
#import "../iCodeAppDelegate.h"
#import "CreateProjectViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ProjLoadTools.h"

@implementation TemplateInfoViewController

@synthesize templatesRoot;
@synthesize templateName;
@synthesize categoryName;

@synthesize name;
@synthesize icon;
@synthesize info;

- (id)initWithTemplate:(NSString*)templateTitle category:(NSString*)category templatesRoot:(NSString *)root
{
	templatesRoot = [[NSString alloc] initWithString:root];
	UIImage*image = (UIImage*)ProjLoad_loadTemplateIcon([category UTF8String], [templateTitle UTF8String], [templatesRoot UTF8String]);
	NSMutableDictionary*nfo = (NSMutableDictionary*)ProjLoad_loadTemplateInfo([category UTF8String], [templateTitle UTF8String], [templatesRoot UTF8String]);
	if(image==nil || nfo==nil)
	{
		[self release];
		return nil;
	}
	NSString*description = [nfo objectForKey:@"Description"];
	
	self = [super init];
	if(self==nil)
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
	[self.name setTextAlignment:NSTextAlignmentCenter];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	if(/*UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad || */self.interfaceOrientation==UIInterfaceOrientationPortrait
	   || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		int size = (self.view.bounds.size.width)/2;
		[name setFrame:CGRectMake(size, 0, size, size)];
		[icon setFrame:CGRectMake(0, 0, size, size)];
		[info setFrame:CGRectMake(0, size, self.view.bounds.size.width, self.view.bounds.size.height-size)];
	}
	else
	{
		int w = self.view.bounds.size.width;
		int h = self.view.bounds.size.height;
		[icon setFrame:CGRectMake(20, 10, (w/2)-40, (w/2)-40)];
		[name setFrame:CGRectMake(0, icon.frame.size.height+10, w/2, 40)];
		[info setFrame:CGRectMake(w/2, 0, w/2, h)];
	}
}

- (void)selectTemplate
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.createProjectController closeAndLoadTemplate:templateName category:categoryName templatesRoot:templatesRoot];
}

- (void)dealloc
{
	[templatesRoot release];
	[templateName release];
	[categoryName release];
	
	[name release];
	[info release];
	[icon release];
	[super dealloc];
}

@end
