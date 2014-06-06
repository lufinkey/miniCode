
#import "CellHoldAction.h"
#import "../PathListTableViewController.h"

@interface PathListAction : CellHoldAction <PathListTableViewControllerDelegate>
{
	PathListTableViewController* pathList;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController paths:(NSArray*)paths;

@property (nonatomic, readonly) PathListTableViewController* pathList;
@end
