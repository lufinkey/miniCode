
#import <UIKit/UIKit.h>

@interface UIColor (DeprecationFix)

+ (UIColor *)groupTableViewBackgroundColor;

@end

@implementation UIColor (DeprecationFix)

+ (UIColor*)groupTableViewBackgroundColor
{
	__strong static UIImage* tableViewBackgroundImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(7.f, 1.f), NO, 0.0);
		CGContextRef c = UIGraphicsGetCurrentContext();
		[[UIColor colorWithRed:185/255.f green:192/255.f blue:202/255.f alpha:1.f] setFill];
		CGContextFillRect(c, CGRectMake(0, 0, 4, 1));
		[[UIColor colorWithRed:185/255.f green:193/255.f blue:200/255.f alpha:1.f] setFill];
		CGContextFillRect(c, CGRectMake(4, 0, 1, 1));
		[[UIColor colorWithRed:192/255.f green:200/255.f blue:207/255.f alpha:1.f] setFill];
		CGContextFillRect(c, CGRectMake(5, 0, 2, 1));
		tableViewBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
		UIGraphicsEndImageContext();
    });
    return [self colorWithPatternImage:tableViewBackgroundImage];
}

@end