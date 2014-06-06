
#import "../ProjectTreeViewController.h"

@interface CellHoldAction : NSObject
{
	ProjectTreeViewController* viewCtrl;
	
	LGViewHUD* operationHUD;
	UIView* obstructView;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

- (void)showObstructionInView:(UIView*)view;
- (void)hideOperationHUDZoom;
- (void)hideOperationHUDFade;

@property (nonatomic, assign) ProjectTreeViewController* viewCtrl;
@property (nonatomic, assign) LGViewHUD* operationHUD;
@property (nonatomic, retain) UIView* obstructView;
@end
