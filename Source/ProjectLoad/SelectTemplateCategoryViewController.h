
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"
#import "../ObjCBridge/ObjCBridge.h"

@interface SelectTemplateCategoryViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView*categoryList;
	
	StringList_struct*defaultCategoryNames;
	NSMutableArray*defaultCategoryIcons;
	NSMutableArray*defaultCategoryViews;
	
	StringList_struct*userCategoryNames;
	NSMutableArray*userCategoryIcons;
	NSMutableArray*userCategoryViews;
}

- (void)reloadCategories;

@property (nonatomic, retain) UITableView* categoryList;

@property (nonatomic, retain) NSArray*defaultCategoryIcons;
@property (nonatomic, retain) NSArray*defaultCategoryViews;

@property (nonatomic, retain) NSArray*userCategoryIcons;
@property (nonatomic, retain) NSArray*userCategoryViews;

@end
