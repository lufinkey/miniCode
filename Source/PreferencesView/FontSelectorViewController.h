
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"

@interface FontSelectorViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSMutableArray* fontFamilyNames;
	NSMutableArray* fontNames;
	
	UITableView* fontTable;
}

@end
