
#import "UIViewCategory.h"

@implementation UIView (Animation)

- (void)setFrame:(CGRect)rect animated:(BOOL)animated
{
	if(animated)
	{
		[UIView animateWithDuration:0.5 animations:^{
			[self setFrame:rect];
		}];
	}
	else
	{
		[self setFrame:rect];
	}
}

@end