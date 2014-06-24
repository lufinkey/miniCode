
#include <UIKit/UIKit.h>

@class PathListTableViewController;

@protocol PathListTableViewControllerDelegate <NSObject>

@optional
- (BOOL)pathListController:(PathListTableViewController*)pathListController shouldRemovePathAtIndex:(NSUInteger)index;
- (void)pathListController:(PathListTableViewController*)pathListController didRemovePathAtIndex:(NSUInteger)index;
- (void)pathListController:(PathListTableViewController*)pathListController didSelectPathAtIndex:(NSUInteger)index;

- (void)pathListController:(PathListTableViewController*)pathListController viewWillDisappear:(BOOL)animated;

@end


@interface PathListTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	id delegate;
	
	@private
	NSMutableArray* pathArray;
	UITableView* pathTable;
	UINavigationBar* navigationBar;
}

- (id)initWithPaths:(NSArray*)paths delegate:(id<PathListTableViewControllerDelegate>)delegate;

- (void)removePathAtIndex:(NSUInteger)index;

@property (nonatomic, assign) id<PathListTableViewControllerDelegate> delegate;

@property (nonatomic, retain) NSArray* pathArray;
@property (nonatomic, retain, readonly) UITableView* pathTable;
@property (nonatomic, retain, readonly) UINavigationBar* navigationBar;
@end
