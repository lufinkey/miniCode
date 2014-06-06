
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"
#import "../ObjCBridge/ObjCBridge.h"

@interface SelectTemplateCategoryViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView*categoryList;
	
	StringList_struct*categoryNames;
	NSMutableArray*categoryIcons;
	NSMutableArray*categoryViews;
}

- (void)reloadCategories;

@property (nonatomic, retain) UITableView*categoryList;
@property (nonatomic, retain) NSArray*categoryIcons;
@property (nonatomic, retain) NSArray*categoryViews;

@end
