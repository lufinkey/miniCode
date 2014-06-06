
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"

@interface LoadProjectViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSIndexPath* pendingDelete;
	
	NSMutableArray* projectNames;
	NSMutableArray* projectFolders;
	NSMutableArray* projectDates;
	
	UINavigationBar* navBar;
	UITableView* recentProjects;
}

- (void)cancelButtonSelected;

- (void)loadSavedProjectList;
- (void)sortProjectList;

@property (nonatomic, retain) NSIndexPath* pendingDelete;

@property (nonatomic, retain) UINavigationBar* navBar;
@property (nonatomic, retain) UITableView* recentProjects;

@property (nonatomic, retain) NSMutableArray* projectNames;
@property (nonatomic, retain) NSMutableArray* projectFolders;
@property (nonatomic, retain) NSMutableArray* projectDates;

@end
