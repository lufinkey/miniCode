
#import <Foundation/Foundation.h>
#import "../Navigation/NavigatedViewController.h"
#import "../UIGridView/UIGridView.h"
#import "../ObjCBridge/ObjCBridge.h"

@interface TemplateGridViewController : NavigatedViewController <UIGridViewDelegate>
{
	StringList_struct* templates;
	UIGridView* grid;
	NSMutableArray* templateViews;
}

- (id)initWithCategory:(NSString*)category;

@property (nonatomic) StringList_struct* templates;
@property (nonatomic, retain) UIGridView* grid;
@property (nonatomic, retain) NSMutableArray* templateViews;

@end
