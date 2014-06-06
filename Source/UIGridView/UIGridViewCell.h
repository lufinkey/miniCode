
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UIGridView;

@interface UIGridViewCell : UIControl
{
	UIGridView* gridView;
	
	@private
	BOOL isSelected;
	UILabel* label;
	UIImage* image;
	UIImageView* imageView;
}

- (id)initWithTitle:(NSString*)title image:(UIImage*)image;

- (void)setTitle:(NSString*)title;
- (void)setImage:(UIImage*)image;

@property (nonatomic, assign, readonly) UIGridView* gridView;
@property (nonatomic, retain) UIImage* image;

@end
