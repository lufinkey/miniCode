
#import <Foundation/Foundation.h>
#import "../Navigation/NavigatedViewController.h"
#import "../UIGridView/UIGridView.h"
#import "../ObjCBridge/ObjCBridge.h"

@interface TemplateGridViewController : NavigatedViewController <UIGridViewDelegate>
{
	NSString* templatesRoot;
	StringList_struct* templates;
	UIGridView* grid;
	NSMutableArray* templateViews;
}

- (id)initWithCategory:(NSString*)category templatesRoot:(NSString*)templatesRoot;

@property (nonatomic, retain) NSString* templatesRoot;
@property (nonatomic) StringList_struct* templates;
@property (nonatomic, retain) UIGridView* grid;
@property (nonatomic, retain) NSMutableArray* templateViews;

@end
