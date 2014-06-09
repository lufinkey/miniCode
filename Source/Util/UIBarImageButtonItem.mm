
#import "UIBarImageButtonItem.h"

@implementation UIBarImageButtonItem

@synthesize button;
@synthesize target;
@synthesize action;

- (id)initWithImage:(UIImage*)image target:(id)targ action:(SEL)act
{
	button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonTouchDown) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(buttonTouchUp) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:self action:@selector(buttonTouchCancel) forControlEvents:UIControlEventTouchCancel];
	[button addTarget:self action:@selector(buttonTouchCancel) forControlEvents:UIControlEventTouchUpOutside];
	
	target = targ;
	action = act;
	
	if([self initWithCustomView:button]==nil)
	{
		return nil;
	}
	
	return self;
}

- (void)setSize:(NSUInteger)size
{
	[button setFrame:CGRectMake(0, 0, size, size)];
}

- (void)buttonTouchDown
{
	
}

- (void)buttonTouchUp
{
	if(target!=nil)
	{
		[target performSelector:action];
	}
}

- (void)buttonTouchCancel
{
	//
}

- (void)dealloc
{
	[button release];
	[super dealloc];
}

@end