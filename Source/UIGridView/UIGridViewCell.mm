
#import "UIGridViewCell.h"
#import "UIGridViewCell+UIGridView.h"
#import "UIGridViewDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "../DeprecationFix/DeprecationDefines.h"

@interface UIGridViewCell()
- (void)updateFrame:(CGRect)frame;
- (void)updateImageFrame;
- (void)updateLabelFrame;
- (void)onControlEventTouchDown;
- (void)onControlEventTouchDragOutside;
- (void)onControlEventTouchUpInside;
@end


@implementation UIGridViewCell

@synthesize gridView;
@synthesize image;

- (id)initWithTitle:(NSString*)title image:(UIImage*)icon
{
	int size = 160;
	
	self = [super initWithFrame:CGRectMake(0,0,size,size)];
	if(self==nil)
	{
		return nil;
	}
	else if(icon==nil)
	{
		[self release];
		return nil;
	}
	
	isSelected = NO;
	self.layer.cornerRadius = 10;
	gridView = nil;
	
	[self setUserInteractionEnabled:YES];
	[self addTarget:self action:@selector(onControlEventTouchDown) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(onControlEventTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
	[self addTarget:self action:@selector(onControlEventTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	self.image = icon;
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,0,0)];
	[imageView setImage:image];
	[self updateImageFrame];
	[self addSubview:imageView];
	[imageView setUserInteractionEnabled:NO];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
	[label setText:title];
	[label setFont:[UIFont fontWithName: @"Helvetica" size:14.0f]];
	[label setNumberOfLines:0];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextAlignment:UITextAlignmentCenter];
	[label setUserInteractionEnabled:NO];
	[self updateLabelFrame];
	[self addSubview:label];
	
	return self;
}

- (void)setTitle:(NSString*)title
{
	[label setText:title];
}

- (void)setImage:(UIImage*)icon
{
	[image release];
	image = icon;
	[image retain];
	[self updateImageFrame];
	[imageView setImage:image];
}

- (void)setGridView:(UIGridView*)grid
{
	if(grid==gridView)
	{
		return;
	}
	if(grid==nil && gridView!=nil && isSelected)
	{
		isSelected = NO;
		[gridView setSelectedIndex:-1];
		[self onControlEventTouchDragOutside];
	}
	gridView = grid;
	if(isSelected)
	{
		if(gridView!=nil)
		{
			if(gridView.selectedIndex==-1)
			{
				NSUInteger index = [gridView.cells indexOfObject:self];
				if(index!=NSNotFound)
				{
					[gridView setSelectedIndex:index];
				}
			}
			else
			{
				NSUInteger index = [gridView.cells indexOfObject:self];
				if(index==NSNotFound || gridView.selectedIndex!=index)
				{
					[self onControlEventTouchDragOutside];
				}
			}
		}
	}
}

- (void)updateImageFrame
{
	int size = 0;
	if(gridView==nil)
	{
		size = self.frame.size.width;
	}
	else
	{
		size = gridView.cellSize;
	}
	
	int sizeW = 0;
	int sizeH = 0;
	if(image.size.width>image.size.height)
	{
		sizeW = size;
		sizeH = (int)((float)size*((float)image.size.height)/((float)image.size.width));
	}
	else
	{
		sizeW = (int)((float)size*((float)image.size.width)/((float)image.size.height));
		sizeH = size;
	}
	
	int imageRectH = size - (size/5);
	float imageSizeRatio = ((float)imageRectH)/((float)size);
	int imageSizeW = sizeW*imageSizeRatio;
	int imageSizeH = sizeH*imageSizeRatio;
	int offsetY = (imageRectH - imageSizeH)/2;
	[imageView setFrame:CGRectMake((size - imageSizeW)/2, offsetY, imageSizeW, imageSizeH)];
}

- (void)updateLabelFrame
{
	int size = self.frame.size.width;
	int imageRectH = size - (size/5);
	[label setFrame:CGRectMake(0, imageRectH, size, size-imageRectH)];
}

- (void)updateFrame:(CGRect)frame
{
	if(frame.size.width<frame.size.height)
	{
		frame.size.width = frame.size.height;
	}
	else
	{
		frame.size.height = frame.size.width;
	}
	[super setFrame:frame];
	[self updateImageFrame];
	[self updateLabelFrame];
}

- (void)setFrame:(CGRect)frame
{
	if(gridView==nil)
	{
		[self updateFrame:frame];
	}
}

- (void)fixFrame:(CGRect)frame
{
	[self updateFrame:frame];
}

- (void)onControlEventTouchDown
{
	if(gridView==nil)
	{
		isSelected = YES;
		[self setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.5]];
	}
	else if(gridView.selectedIndex==-1)
	{
		NSUInteger index = [gridView.cells indexOfObject:self];
		if(index!=NSNotFound)
		{
			isSelected = YES;
			[gridView setSelectedIndex:index];
			[self setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.5]];
		}
	}
}

- (void)onControlEventTouchUpInside
{
	[self setBackgroundColor:[UIColor clearColor]];
	if(isSelected)
	{
		if(gridView!=nil)
		{
			[gridView setSelectedIndex:-1];
			if(gridView.delegate!=nil && [gridView.delegate respondsToSelector:@selector(gridView:didSelectIndex:)])
			{
				NSUInteger index = [gridView.cells indexOfObject:self];
				if(index!=NSNotFound)
				{
					[gridView.delegate gridView:gridView didSelectIndex:index];
				}
			}
		}
	}
}

- (void)onControlEventTouchDragOutside
{
	isSelected = NO;
	if(gridView!=nil)
	{
		NSUInteger index = [gridView.cells indexOfObject:self];
		if(index!=NSNotFound && gridView.selectedIndex == index)
		{
			[gridView setSelectedIndex:-1];
		}
	}
	[self setBackgroundColor:[UIColor clearColor]];
}

- (void)dealloc
{
	[image release];
	[imageView release];
	[label release];
	[super dealloc];
}

@end
