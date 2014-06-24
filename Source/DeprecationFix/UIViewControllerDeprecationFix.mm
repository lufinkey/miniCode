
/*#import <UIKit/UIKit.h>
#import "NSObjectDeprecationFix.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@interface UIViewController (DeprecationFix)

- (void)presentModalViewController:(UIViewController*)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;

@end

@implementation UIViewController (DeprecationFix)

- (void)presentModalViewController:(UIViewController*)modalViewController animated:(BOOL)animated
{
	[self performSelector:@selector(presentViewController:animated:completion:) withValue:modalViewController withValue:&animated withValue:NULL];
	//[self presentViewController:modalViewController animated:animated completion:NULL];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
	[self performSelector:@selector(dismissViewControllerAnimated:completion:) withValue:&animated withValue:NULL];
	//[self dismissViewControllerAnimated:animated completion:NULL];
}

@end

#pragma clang diagnostic pop
#pragma clang diagnostic pop*/
