
#import "ImageViewerViewController.h"
#import "../Util/UIImageManager.h"

@interface UIPictureViewer()
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIView* bgView;
@property (nonatomic, retain) UIColor* transpBG;
@end

@implementation UIPictureViewer

@synthesize image;
@synthesize imageView;
@synthesize bgView;
@synthesize transpBG;

- (id)initWithFrame:(CGRect)frame
{
	initted = NO;
	
	self = [super initWithFrame:frame];
	if(self==nil)
	{
		return nil;
	}
	
	initted = YES;
	
	offset = CGPointMake(0, 0);
	
	[UIImageManager loadImage:@"Images/transparency_background.png"];
	transpBG = [[UIColor alloc] initWithPatternImage:[UIImageManager getImage:@"Images/transparency_background.png"]];
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,1,1)];
	[bgView setBackgroundColor:transpBG];
	image = nil;
	
	self.delegate = self;
	
	bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
	[bgView addSubview:imageView];
	[self addSubview:bgView];
	
	[self setBounces:YES];
	[self setBouncesZoom:YES];
	[self setAlwaysBounceVertical:YES];
	[self setAlwaysBounceHorizontal:YES];
	[self setScrollEnabled:YES];
	
	[self setMaximumZoomScale:2.0];
	[self setUserInteractionEnabled:YES];
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
	[doubleTap setNumberOfTapsRequired:2];
	[self addGestureRecognizer:doubleTap];
	[doubleTap release];
	
	return self;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
	return bgView;
}

- (void)scrollViewDidZoom:(UIScrollView*)scrollView
{
	int offsetX = offset.x;
	int offsetY = offset.y;
	
	int wDif = ((imageView.frame.size.width*self.zoomScale) - imageView.frame.size.width)/2;
	if(offset.x>0)
	{
		if(wDif>offset.x)
		{
			offsetX = 0;
		}
		else
		{
			offsetX = offset.x - wDif;
		}
	}
	int hDif = ((imageView.frame.size.height*self.zoomScale) - imageView.frame.size.height)/2;
	if(offset.y>0)
	{
		if(hDif>offset.y)
		{
			offsetY = 0;
		}
		else
		{
			offsetY = offset.y - hDif;
		}
	}
	
	[self setContentInset:UIEdgeInsetsMake(offsetY, offsetX, offsetY, offsetX)];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self resetImageFrame];
}

- (void)setImage:(UIImage*)img
{
	if(image!=img)
	{
		[image release];
		[img retain];
		image = img;
		[imageView setImage:image];
		[bgView setBackgroundColor:transpBG];
	}
	
	if(image!=nil)
	{
		[self resetImageFrame];
	}
}

- (void)resetImageFrame
{
	if(!initted)
	{
		return;
	}
	
	[self setZoomScale:1];
	
	if(image.size.width<self.frame.size.width && image.size.height<self.frame.size.height)
	{
		[bgView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
		offset = CGPointMake((self.frame.size.width/2)-(image.size.width/2), (self.frame.size.height/2)-(image.size.height/2));
	}
	else if(self.frame.size.width<=self.frame.size.height)
	{
		float frameRat = (float)self.frame.size.width/(float)self.frame.size.height;
		float imageRat = (float)image.size.width/(float)image.size.height;
		if(imageRat>=frameRat)
		{
			int w = self.frame.size.width;
			int h = ((float)self.frame.size.width/(float)image.size.width)*image.size.height;
			[bgView setFrame:CGRectMake(0, 0, w, h)];
			offset = CGPointMake((self.frame.size.width/2)-(w/2), (self.frame.size.height/2)-(h/2));
		}
		else
		{
			int h = self.frame.size.height;
			int w = ((float)self.frame.size.height/(float)image.size.height)*image.size.width;
			[bgView setFrame:CGRectMake(0, 0, w, h)];
			offset = CGPointMake((self.frame.size.width/2)-(w/2), (self.frame.size.height/2)-(h/2));
		}
	}
	else
	{
		float frameRat = (float)self.frame.size.height/(float)self.frame.size.width;
		float imageRat = (float)image.size.height/(float)image.size.width;
		if(imageRat>=frameRat)
		{
			int h = self.frame.size.height;
			int w = ((float)self.frame.size.height/(float)image.size.height)*image.size.width;
			[bgView setFrame:CGRectMake(0, 0, w, h)];
			offset = CGPointMake((self.frame.size.width/2)-(w/2), (self.frame.size.height/2)-(h/2));
		}
		else
		{
			int w = self.frame.size.width;
			int h = ((float)self.frame.size.width/(float)image.size.width)*image.size.height;
			[bgView setFrame:CGRectMake(0, 0, w, h)];
			offset = CGPointMake((self.frame.size.width/2)-(w/2), (self.frame.size.height/2)-(h/2));
		}
	}
	
	[imageView setFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)];
	
	[self setContentInset:UIEdgeInsetsMake(offset.y, offset.x, offset.y, offset.x)];
	[self setContentSize:CGSizeMake(bgView.frame.size.width, bgView.frame.size.height)];
}

- (void)onDoubleTap:(UIGestureRecognizer*)gestureRecognizer
{
	if(self.zoomScale > self.minimumZoomScale)
	{
		[self setZoomScale:self.minimumZoomScale animated:YES];
	}
	else
	{
		[self setZoomScale:self.maximumZoomScale animated:YES];
	}
}

- (void)dealloc
{
	[image release];
	[imageView release];
	[bgView release];
	[transpBG release];
	[super dealloc];
}

@end

@implementation ImageViewerViewController

@synthesize pictureViewer;
@synthesize currentFilePath;

- (id)init
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	self.currentFilePath = nil;
	
	pictureViewer = [[UIPictureViewer alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:pictureViewer];
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[pictureViewer setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (BOOL)loadWithFile:(NSString*)filePath
{
	BOOL alreadyLoaded = [UIImageManager isImageLoaded:filePath];
	if(!alreadyLoaded)
	{
		BOOL success = [UIImageManager loadImage:filePath];
		if(!success)
		{
			return NO;
		}
	}
	[pictureViewer setImage:[UIImageManager getImage:filePath]];
	if(!alreadyLoaded)
	{
		[UIImageManager unloadImage:filePath];
	}
	self.currentFilePath = filePath;
	
	return YES;
}

- (void)setFileLocked:(BOOL)locked
{
	//Does nothing
}

- (void)didNavigateBackwardTo:(UIViewController*)viewController
{
	[pictureViewer setImage:nil];
}

- (void)dealloc
{
	[pictureViewer release];
	[currentFilePath release];
	[super dealloc];
}

@end

