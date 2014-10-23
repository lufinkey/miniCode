
#import <UIKit/UIKit.h>
#import "../UIFileBrowserViewController/UIFileBrowserViewController.h"
#import "../Navigation/NavigatedViewController.h"
#import "../Util/UIDictionaryTableViewCell.h"
#import <MessageUI/MessageUI.h>

@interface PreferencesViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource, UIDictionaryTableViewCellDelegate, UIFileBrowserDelegate, MFMailComposeViewControllerDelegate>
{
	UITableView*preferences;
	UIFileBrowserViewController* fileExplorer;
}

- (void)doneButtonSelected;
- (void)cancelFileExplorer;

@property (nonatomic, retain) UITableView* preferences;
@property (nonatomic, assign) UIFileBrowserViewController* fileExplorer;

@end
