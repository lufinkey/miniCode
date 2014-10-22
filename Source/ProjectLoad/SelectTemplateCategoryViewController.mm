
#import "SelectTemplateCategoryViewController.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../iCodeAppDelegate.h"
#import "ProjLoadTools.h"
#import "TemplateGridViewController.h"

@implementation SelectTemplateCategoryViewController

@synthesize categoryList;

@synthesize defaultCategoryIcons;
@synthesize defaultCategoryViews;

@synthesize userCategoryIcons;
@synthesize userCategoryViews;

- (id)init
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	defaultCategoryNames = NULL;
	defaultCategoryIcons = nil;
	defaultCategoryViews = nil;
	
	userCategoryNames = NULL;
	userCategoryIcons = nil;
	userCategoryViews = nil;
	
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
	[super resetLayout];
	[categoryList setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (void)reloadCategories
{
	if(defaultCategoryNames!=NULL)
	{
		StringList_destroyInstance(defaultCategoryNames);
		defaultCategoryNames = NULL;
	}
	if(defaultCategoryIcons!=nil)
	{
		[defaultCategoryIcons release];
		defaultCategoryIcons = nil;
	}
	if(defaultCategoryViews!=nil)
	{
		[defaultCategoryViews release];
		defaultCategoryViews = nil;
	}
	
	if(userCategoryNames!=NULL)
	{
		StringList_destroyInstance(userCategoryNames);
		userCategoryNames = NULL;
	}
	if(userCategoryIcons!=nil)
	{
		[userCategoryIcons release];
		userCategoryIcons = nil;
	}
	if(userCategoryViews!=nil)
	{
		[userCategoryViews release];
		userCategoryViews = nil;
	}
	
	const char* defaultTemplatesFolder = ProjLoad_getDefaultTemplatesFolder();
	NSString* defaultTemplatesRoot = [[NSString alloc] initWithUTF8String:defaultTemplatesFolder];
	
	defaultCategoryNames = ProjLoad_loadCategoryList(defaultTemplatesFolder);
	defaultCategoryIcons = [[NSMutableArray alloc] init];
	defaultCategoryViews = [[NSMutableArray alloc] init];
	
	for(int i=0; i<StringList_size(defaultCategoryNames); i++)
	{
		const char* categoryName = StringList_get(defaultCategoryNames,i);
		UIImage*img = (UIImage*)ProjLoad_loadCategoryIcon(categoryName, defaultTemplatesFolder);
		[defaultCategoryIcons addObject:img];
		[img release];
		
		TemplateGridViewController*templateView = [[TemplateGridViewController alloc] initWithCategory:[NSString stringWithUTF8String:categoryName] templatesRoot:defaultTemplatesRoot];
		[defaultCategoryViews addObject:templateView];
		[templateView release];
	}
	
	[defaultTemplatesRoot release];
	
	const char* userTemplatesFolder = ProjLoad_getUserTemplatesFolder();
	NSString* userTemplatesRoot = [[NSString alloc] initWithUTF8String:userTemplatesFolder];
	
	userCategoryNames = ProjLoad_loadCategoryList(userTemplatesFolder);
	userCategoryIcons = [[NSMutableArray alloc] init];
	userCategoryViews = [[NSMutableArray alloc] init];
	
	for(int i=0; i<StringList_size(userCategoryNames); i++)
	{
		const char* categoryName = StringList_get(userCategoryNames,i);
		UIImage*img = (UIImage*)ProjLoad_loadCategoryIcon(categoryName, userTemplatesFolder);
		[userCategoryIcons addObject:img];
		[img release];
		
		TemplateGridViewController*templateView = [[TemplateGridViewController alloc] initWithCategory:[NSString stringWithUTF8String:categoryName] templatesRoot:userTemplatesRoot];
		[userCategoryViews addObject:templateView];
		[templateView release];
	}
	
	[userTemplatesRoot release];
	
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
	[categoryList release];
	
	StringList_destroyInstance(defaultCategoryNames);
	[defaultCategoryIcons release];
	[defaultCategoryViews release];
	
	StringList_destroyInstance(userCategoryNames);
	[userCategoryIcons release];
	[userCategoryViews release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Table View Events

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section==0)
	{
		return @"Default Templates";
	}
	else if(section==1)
	{
		return @"User Templates";
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section==0)
	{
		return StringList_size(defaultCategoryNames);
	}
	else if(section==1)
	{
		return StringList_size(userCategoryNames);
	}
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section>1)
	{
		return nil;
	}
	
	NSString*cellText = nil;
	NSMutableString* cellID = nil;
	if(indexPath.section==0)
	{
		cellText = [NSString stringWithUTF8String:StringList_get(defaultCategoryNames, indexPath.row)];
		cellID = [NSMutableString stringWithUTF8String:"default/"];
		[cellID appendString:cellText];
	}
	else
	{
		cellText = [NSString stringWithUTF8String:StringList_get(userCategoryNames, indexPath.row)];
		cellID = [NSMutableString stringWithUTF8String:"user/"];
		[cellID appendString:cellText];
	}
	
	UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	[cell.textLabel setText:cellText];
	
	if(indexPath.section==0)
	{
		[cell.imageView setImage:[defaultCategoryIcons objectAtIndex:indexPath.row]];
	}
	else
	{
		[cell.imageView setImage:[userCategoryIcons objectAtIndex:indexPath.row]];
	}
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.section==0)
	{
		[self.navigationController pushViewController:[defaultCategoryViews objectAtIndex:indexPath.row] animated:YES];
	}
	else
	{
		[self.navigationController pushViewController:[userCategoryViews objectAtIndex:indexPath.row] animated:YES];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
