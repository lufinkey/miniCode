
#import "UITreeView.h"
#import "UITreeViewCell+UITreeView.h"

@implementation UITreeView

@synthesize cellHeight;
@synthesize delegate;
@synthesize rootCell;
@synthesize animatesByDefault;
@synthesize animationTime;

- (id)initWithFrame:(CGRect)frame
{
	if([super initWithFrame:frame]==nil)
	{
		return nil;
	}
	
	delegate = nil;
	lowestIndex = 0;
	cellHeight = 26;
	animatesByDefault = NO;
	animationTime = 0.5;
	
	[self setScrollEnabled:YES];
	
	rootCell = [[UITreeViewCell alloc] initWithText:@"Root"];
	[self addSubview:rootCell];
	[rootCell setTree:self];
	[rootCell setSupercell:nil];
	[rootCell setAsBranch:YES];
	[rootCell setBranchOpen:YES];
	[rootCell fixFrame:CGRectMake(0,0, self.bounds.size.width, cellHeight)];
	
	[self refreshContentSize];
	
	return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[rootCell fixFrame:CGRectMake(0, 0, self.bounds.size.width, cellHeight)];
	[self refreshContentSize];
}

- (void)addSubview:(UIView*)subview animated:(BOOL)animated
{
	if(animated)
	{
		[UIView animateWithDuration:animationTime animations:^{
			[self addSubview:subview];
		}];
	}
	else
	{
		[self addSubview:subview];
	}
}

- (void)setRootCell:(UITreeViewCell*)cell animated:(BOOL)animated
{
	if(rootCell!=cell)
	{
		[rootCell removeFromSuperviewAnimated:animated];
		[rootCell release];
		rootCell = cell;
		[rootCell retain];
		
		[rootCell fixFrame:CGRectMake(0,0, self.frame.size.width, cellHeight) animated:animated];
		[rootCell setTree:self];
		if(rootCell!=nil)
		{
			[self addSubview:rootCell animated:animated];
		}
	}
}

- (void)setCellHeight:(NSUInteger)height animated:(BOOL)animated
{
	cellHeight = height;
	[rootCell fixFrame:CGRectMake(0, 0, self.bounds.size.width, cellHeight) animated:animated];
}

- (void)setRootCell:(UITreeViewCell*)cell
{
	[self setRootCell:cell animated:NO];
}

- (void)setCellHeight:(NSUInteger)height
{
	[self setCellHeight:height animated:NO];
}

- (void)refreshContentSize
{
	lowestIndex = [rootCell getCurrentHeight];
	[self setContentSize:CGSizeMake(self.bounds.size.width, lowestIndex)];
}

- (void)dealloc
{
	[rootCell release];
	[super dealloc];
}

@end
