
#import "../Navigation/NavigatedViewController.h"

@interface AppManagerViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
	UITableView* appTable;
	NSString* pendingApp;
	NSIndexPath* pendingIndex;
}

@property (nonatomic, retain, readonly) UITableView* appTable;
@end
