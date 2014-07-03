
#import "UINavigator.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "NavigatedViewController.h"
#import <UIKit/UINavigationController.h>


@implementation UINavigator

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController:rootViewController];
	if(self==nil)
	{
		return nil;
	}
	
	shouldPopItemCalled = NO;
	shouldPopViewCalled = NO;
	isAnimated = YES;
	
	return self;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
	return NO;
}

- (BOOL)navigationBar:(UINavigationBar*)bar shouldPopItem:(UINavigationItem*)item
{
	if(shouldPopItemCalled)
	{
		shouldPopItemCalled = NO;
		return NO;
	}
	else if(shouldPopViewCalled)
	{
		shouldPopViewCalled = NO;
		return YES;
	}
	shouldPopItemCalled = YES;
	if([self.topViewController isKindOfClass:[NavigatedViewController class]])
	{
		NavigatedViewController* viewCtrl = (NavigatedViewController*)self.topViewController;
		BOOL should = [viewCtrl shouldNavigateBackward];
		if(should)
		{
			[self popViewControllerAnimated:isAnimated];
		}
		isAnimated = YES;
		shouldPopItemCalled = NO;
		return should;
	}
	[self popViewControllerAnimated:isAnimated];
	isAnimated = YES;
	shouldPopItemCalled = NO;
	return YES;
}

- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	if([self.visibleViewController isKindOfClass:[NavigatedViewController class]])
	{
		[((NavigatedViewController*)self.visibleViewController) willNavigateForwardTo:viewController];
	}
	[super pushViewController:viewController animated:animated];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated
{
	isAnimated = animated;
	if(!shouldPopItemCalled)
	{
		if([self.topViewController isKindOfClass:[NavigatedViewController class]])
		{
			NavigatedViewController* viewCtrl = (NavigatedViewController*)self.topViewController;
			BOOL should = [viewCtrl shouldNavigateBackward];
			if(should)
			{
				shouldPopViewCalled = YES;
				return [super popViewControllerAnimated:animated];
			}
			return nil;
		}
	}
	return [super popViewControllerAnimated:animated];
}

- (NSArray*)popToViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	isAnimated = animated;
	return [super popToViewController:viewController animated:animated];
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
	isAnimated = animated;
	return [super popToRootViewControllerAnimated:animated];
}

- (void)dealloc
{
	[super dealloc];
}

@end
