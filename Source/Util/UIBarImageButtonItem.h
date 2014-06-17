
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIBarImageButtonItem : UIBarButtonItem
{
	UIButton* button;
	
	id target;
	SEL action;
}

- (id)initWithImage:(UIImage*)image target:(id)target action:(SEL)action;
- (id)initWithType:(UIButtonType)type target:(id)target action:(SEL)action;

- (void)setSize:(NSUInteger)size;

- (void)buttonTouchDown;
- (void)buttonTouchUp;
- (void)buttonTouchCancel;

@property (nonatomic, retain, readonly) UIButton* button;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;
@end
