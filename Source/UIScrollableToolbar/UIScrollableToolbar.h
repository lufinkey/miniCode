
#import <UIKit/UIKit.h>

@interface UIScrollableToolbar : UIScrollView
{
	UIToolbar* toolbar;
	NSUInteger minimumToolbarWidth;
}

- (NSArray*)items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

- (UIBarStyle)barStyle;
- (void)setBarStyle:(UIBarStyle)barStyle;

@property (nonatomic, assign, readonly) UIToolbar* toolbar;
@property (nonatomic) NSUInteger minimumToolbarWidth;
@end