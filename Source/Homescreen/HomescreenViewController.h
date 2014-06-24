
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"

@interface HomescreenViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource>
{
	UIImage*xcodeLogo;
	
	@private
	UITableView* projectOptions;
	UITableView* recentProjects;
	UIImageView* xcodeLogoView;
	UILabel* welcomeLabel;
}

@property (nonatomic, retain) UIImage*xcodeLogo;

@end
