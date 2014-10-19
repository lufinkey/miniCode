
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"
#import "../Util/UIControlLabel.h"

@interface FontSizePreviewViewController : NavigatedViewController
{
	UIControlLabel* preview;
	UISlider* sizer;
	UILabel* sizeLabel;
}

- (void)sizerDidChangeValue;

@property (nonatomic, retain) UIControlLabel* preview;
@property (nonatomic, retain) UISlider* sizer;
@end
