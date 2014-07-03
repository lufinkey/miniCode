
#import "CellHoldAction.h"

@implementation CellHoldAction

@synthesize viewCtrl;
@synthesize operationHUD;
@synthesize obstructView;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	viewCtrl = projectTreeViewController;
	operationHUD = [LGViewHUD defaultHUD];
	obstructView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	return self;
}

- (void)showObstructionInView:(UIView*)view
{
	if(obstructView==nil)
	{
		obstructView = [[UIView alloc] initWithFrame:view.frame];
	}
	[obstructView setUserInteractionEnabled:YES];
	[obstructView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
	[obstructView setFrame:view.frame];
	[view addSubview:obstructView];
}

- (void)hideOperationHUDZoom
{
	[operationHUD hideWithAnimation:HUDAnimationHideZoom];
}

- (void)hideOperationHUDFade
{
	[operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
}

- (void)dealloc
{
	[obstructView release];
	[super dealloc];
}

@end
