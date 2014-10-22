
#import <Foundation/Foundation.h>
#import "../Navigation/NavigatedViewController.h"

@interface TemplateInfoViewController : NavigatedViewController
{
	NSString*templatesRoot;
	NSString*templateName;
	NSString*categoryName;
	
	UIImageView* icon;
	UILabel* name;
	UITextView* info;
}

- (id)initWithTemplate:(NSString*)templateName category:(NSString*)category templatesRoot:(NSString*)templatesRoot;
- (void)selectTemplate;

@property (nonatomic, retain) NSString* templatesRoot;
@property (nonatomic, retain) NSString* templateName;
@property (nonatomic, retain) NSString* categoryName;

@property (nonatomic, retain) UIImageView* icon;
@property (nonatomic, retain) UILabel* name;
@property (nonatomic, retain) UITextView* info;

@end
