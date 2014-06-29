
#import "TemplateGridViewController.h"
#import "ProjLoadTools.h"
#import "TemplateInfoViewController.h"

@implementation TemplateGridViewController

@synthesize grid;
@synthesize templates;
@synthesize templateViews;

- (id)initWithCategory:(NSString*)category
{
	if([super init]==nil)
	{
		return nil;
	}
	
	const char* categoryName = [category UTF8String];
	
	grid = [[UIGridView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[grid setDelegate:self];
	
	templateViews = [[NSMutableArray alloc] init];
	
	templates = ProjLoad_loadTemplateList(categoryName);
	for(int i=0; i<StringList_size(templates); i++)
	{
		const char* templateName = StringList_get(templates, i);
		
		NSString*title = [NSString stringWithUTF8String:templateName];
		
		TemplateInfoViewController*templateView = [[TemplateInfoViewController alloc] initWithTemplate:title category:[NSString stringWithUTF8String:categoryName]];
		
		UIGridViewCell*cell = [[UIGridViewCell alloc] initWithTitle:title image:templateView.icon.image];
		[grid addCell:cell];
		[cell release];
		
		if(templateView==nil)
		{
			StringList_remove(templates, i);
			i--;
		}
		else
		{
			[templateViews addObject:templateView];
			[templateView release];
		}
	}
	
	[self.view addSubview:grid];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[grid setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (void)gridView:(UIGridView *)gridView didSelectIndex:(NSUInteger)index
{
	TemplateInfoViewController*viewController = [templateViews objectAtIndex:index];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)dealloc
{
	StringList_destroyInstance(templates);
	[grid release];
	[templateViews release];
	[super dealloc];
}

@end
