
#import "PathListAction.h"

@implementation PathListAction

@synthesize pathList;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController paths:(NSArray*)paths
{
	if([super initWithProjectTreeViewController:projectTreeViewController]==nil)
	{
		return nil;
	}
	
	pathList = [[PathListTableViewController alloc] initWithPaths:paths delegate:self];
	
	[self.viewCtrl presentModalViewController:pathList animated:YES];
	
	return self;
}

- (void)pathListController:(PathListTableViewController *)pathListController didSelectPathAtIndex:(NSUInteger)index
{
	showSimpleMessageBox(NULL, [[pathList.pathArray objectAtIndex:index] UTF8String]);
}

- (void)dealloc
{
	[pathList release];
	[super dealloc];
}

@end
