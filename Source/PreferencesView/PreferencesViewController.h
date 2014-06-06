
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "../UIFileBrowserViewController/UIFileBrowserViewController.h"
#import "../Navigation/NavigatedViewController.h"

@interface PreferencesViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource, UIFileBrowserDelegate>
{
	UITableView*preferences;
	UIFileBrowserViewController* fileExplorer;
}

- (void)doneButtonSelected;
- (void)cancelFileExplorer;

@property (nonatomic, retain) UITableView* preferences;
@property (nonatomic, retain) UIFileBrowserViewController* fileExplorer;

@end
