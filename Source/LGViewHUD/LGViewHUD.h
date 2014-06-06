//
//  LGViewHUD.h
//  Created by y0n3l on 4/13/11.
//

#import <UIKit/UIKit.h>

typedef enum {
	HUDAnimationNone,
	HUDAnimationShowZoom,
	HUDAnimationHideZoom,
	HUDAnimationHideFadeOut
} HUDAnimation;

/**
 A HUD that mimics the native one used in iOS (when you press volume up or down 
 on the iPhone for instance) and also provides some more features (some more animations
 + activity indicator support included.)
 */

@interface LGViewHUD : UIView {
	UIImage* image;
	UIImageView* imageView;
	UILabel* bottomLabel;
	UILabel* topLabel;
	UIView* backgroundView;
	NSTimeInterval displayDuration;
	NSTimer* displayTimer;
	BOOL activityIndicatorOn;
	UIActivityIndicatorView* activityIndicator;
}
/** The image displayed at the center of the HUD. Default is nil. */
@property (readwrite, retain) UIImage* image;
/** The top text of the HUD. Shortcut to the text of the topLabel property. */
@property (readwrite, retain) NSString* topText;
/** The bottom text of the HUD. Shortcut to the text of the bottomLabel property. */
@property (readwrite, retain) NSString* bottomText;
/** The top label of the HUD. (So that you can adjust its properties ...) */
@property (readonly) UILabel* topLabel;
/** The bottom label of the HUD. (So that you can adjust its properties ...) */
@property (readonly) UILabel* bottomLabel;
/** HUD display duration. Default is 2 sec. */
@property (readwrite) NSTimeInterval displayDuration;
/** Diplays a large white activity indicator instead of the image if set to YES. 
 Default is NO. */ 
@property (readwrite) BOOL activityIndicatorOn;

/** Returns the default HUD singleton instance. */
+(LGViewHUD*) defaultHUD;

/** Shows the HUD and hides it after a delay equals to the displayDuration property value. 
 HUDAnimationNone is used by default. */
-(void) showInView:(UIView*)view;

/** Shows the HUD with the given animation and hides it after a delay equals to the displayDuration property value. */
-(void) showInView:(UIView *)view withAnimation:(HUDAnimation)animation;

/** Hides the HUD right now.
 You only need to invoke this one when the HUD is displayed with an activity indicator 
 because there's no auto hide in that case. */
-(void) hideWithAnimation:(HUDAnimation)animation;

-(void) hideAfterDelay:(NSTimeInterval)delayInSecs withAnimation:(HUDAnimation)animation;

@end
