
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BuildOptionsActionSheet : UIActionSheet <UIActionSheetDelegate>
{
	@private
	UIViewController* viewController;
	
	int buildIndex;
	int buildAndRunIndex;
	int cleanIndex;
	int resultsIndex;
}

- (id)initForViewController:(UIViewController*)viewController;

@end
