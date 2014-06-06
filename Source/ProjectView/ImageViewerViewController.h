
#import <Foundation/Foundation.h>
#import "FileEditorDelegate.h"
#import "../Navigation/NavigatedViewController.h"

@interface UIPictureViewer : UIScrollView <UIScrollViewDelegate>
{
	UIImage* image;
	@private
	BOOL initted;
	CGPoint offset;
	UIColor* transpBG;
	UIView* bgView;
	UIImageView* imageView;
}

- (void)onDoubleTap:(UIGestureRecognizer*)gestureRecognizer;
- (void)resetImageFrame;

@property (nonatomic, retain) UIImage* image;

@end


@interface ImageViewerViewController : NavigatedViewController <FileEditorDelegate>
{
	UIPictureViewer* pictureViewer;
	NSString* currentFilePath;
}

@property (nonatomic, retain) UIPictureViewer* pictureViewer;
@property (nonatomic, retain) NSString* currentFilePath;

@end
