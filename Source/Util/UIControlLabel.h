
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIControlLabel : UILabel
{
	UIControlContentVerticalAlignment verticalAlignment;
}

@property (nonatomic, assign) UIControlContentVerticalAlignment verticalAlignment;

@end