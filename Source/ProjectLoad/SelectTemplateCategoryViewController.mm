
#import "SelectTemplateCategoryViewController.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../iCodeAppDelegate.h"
#import "ProjLoadTools.h"
#import "TemplateGridViewController.h"

@implementation SelectTemplateCategoryViewController

@synthesize categoryList;
@synthesize categoryIcons;
@synthesize categoryViews;

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	categoryNames = NULL;
	categoryIcons = nil;
	categoryViews = nil;
	categoryList = nil;
	
	[self setTitle:@"Select Template"];
	
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	[self reloadCategories];
	
	categoryList = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
	categoryList.delegate = self;
	categoryList.dataSource = self;
	
	[self.view addSubview:categoryList];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[categoryList setFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)reloadCategories
{
	if(categoryNames!=NULL)
	{
		StringList_destroyInstance(categoryNames);
		categoryNames = NULL;
	}
	if(categoryIcons!=nil)
	{
		[categoryIcons release];
		categoryIcons = nil;
	}
	if(categoryViews!=nil)
	{
		[categoryViews release];
		categoryViews = nil;
	}
	
	categoryNames = ProjLoad_loadCategoryList();
	categoryIcons = [[NSMutableArray alloc] init];
	categoryViews = [[NSMutableArray alloc] init];
	
	for(int i=0; i<StringList_size(categoryNames); i++)
	{
		const char* categoryName = StringList_get(categoryNames,i);
		UIImage*img = (UIImage*)ProjLoad_loadCategoryIcon(categoryName);
		[categoryIcons addObject:img];
		[img release];
		
		TemplateGridViewController*templateView = [[TemplateGridViewController alloc] initWithCategory:[NSString stringWithUTF8String:categoryName]];
		[categoryViews addObject:templateView];
		[templateView release];
	}
	
	if(categoryList!=nil)
	{
		[categoryList reloadData];
	}
}

- (void)willNavigateBackward:(UIViewController*)viewController
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	if(appDelegate.projData!=NULL)
	{
		ProjectData_destroyInstance(appDelegate.projData);
		appDelegate.projData = NULL;
	}
}

- (void)dealloc
{
	StringList_destroyInstance(categoryNames);
	[categoryList release];
	[categoryIcons release];
	[categoryViews release];
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
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return StringList_size(categoryNames);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString*cellText = [NSString stringWithUTF8String:StringList_get(categoryNames, indexPath.row)];
	
	UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellText];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellText] autorelease];
	}
	[cell.textLabel setText:cellText];
	[cell.imageView setImage:[categoryIcons objectAtIndex:indexPath.row]];
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[self.navigationController pushViewController:[categoryViews objectAtIndex:indexPath.row] animated:YES];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
