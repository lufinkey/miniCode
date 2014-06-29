
#import "UIScrollableToolbar.h"

@implementation UIScrollableToolbar

@synthesize toolbar;
@synthesize minimumToolbarWidth;

- (id)initWithFrame:(CGRect)frame
{
	minimumToolbarWidth = frame.size.width;
	
	if([super initWithFrame:frame]==nil)
	{
		return nil;
	}
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
	[self addSubview:toolbar];
	
	return self;
}

- (NSArray*)items
{
	return toolbar.items;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
	[toolbar setItems:items animated:animated];
}

- (UIBarStyle)barStyle
{
	return toolbar.barStyle;
}

- (void)setBarStyle:(UIBarStyle)barStyle
{
	[toolbar setBarStyle:barStyle];
}

- (void)setMinimumToolbarWidth:(NSUInteger)width
{
	minimumToolbarWidth = width;
	if(width >= self.bounds.size.width)
	{
		[toolbar setFrame:CGRectMake(0, 0, width, self.bounds.size.height)];
		[self setContentSize:CGSizeMake(width, self.bounds.size.height)];
	}
	else
	{
		[toolbar setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[self setContentSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
	}
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	if(frame.size.width < minimumToolbarWidth)
	{
		[toolbar setFrame:CGRectMake(0, 0, minimumToolbarWidth, frame.size.height)];
		[self setContentSize:CGSizeMake(minimumToolbarWidth, frame.size.height)];
	}
	else
	{
		[toolbar setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
	}
}

- (void)dealloc
{
	[toolbar release];
	[super dealloc];
}

@end
