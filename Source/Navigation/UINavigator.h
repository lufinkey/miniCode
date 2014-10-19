
#import <UIKit/UIKit.h>

@interface UINavigator : UINavigationController <UINavigationBarDelegate>
{
	@private
	BOOL shouldPopItemCalled;
	BOOL shouldPopViewCalled;
	BOOL isAnimated;
}

@end
