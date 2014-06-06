
#import "NavigatedViewController.h"
#import "../iCodeAppDelegate.h"

@implementation NavigatedViewController

@synthesize backQueueViewController;

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	navigatingBack = NO;
	self.backQueueViewController = nil;
	
	return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
	{
		UIViewController*viewCtrl = self.navigationController.visibleViewController;
		navigatingBack = YES;
		self.backQueueViewController = viewCtrl;
		[self willNavigateBackwardTo:viewCtrl];
		if([viewCtrl isKindOfClass:[NavigatedViewController class]])
		{
			[((NavigatedViewController*)viewCtrl) willReturnFrom:self];
		}
	}
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if(navigatingBack)
	{
		navigatingBack = NO;
		[self didNavigateBackwardTo:backQueueViewController];
		if(navigatingBack == NO)
		{
			self.backQueueViewController = nil;
		}
	}
}

- (BOOL)shouldNavigateBackward
{
	return YES;
}

- (void)willNavigateBackwardTo:(UIViewController*)viewController
{
	//
}

- (void)didNavigateBackwardTo:(UIViewController*)viewController
{
	//
}

- (void)willNavigateForwardTo:(UIViewController*)viewController
{
	//
}

- (void)willReturnFrom:(UIViewController*)viewController
{
	//
}

- (void)dealloc
{
	[super dealloc];
}

@end
