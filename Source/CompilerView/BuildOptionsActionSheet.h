
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BuildOptionsActionSheet : UIActionSheet <UIActionSheetDelegate>
{
	@private
	UIViewController* viewController;
}

- (id)initForViewController:(UIViewController*)viewController;

@end
