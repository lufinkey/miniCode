
#import "UITreeView.h"
#import "UITreeViewCell+UITreeView.h"

@implementation UITreeView

@synthesize cellHeight;
@synthesize delegate;
@synthesize rootCell;

- (id)initWithFrame:(CGRect)frame
{
	if([super initWithFrame:frame]==nil)
	{
		return nil;
	}
	
	[self setScrollEnabled:YES];
	
	delegate = nil;
	lowestIndex = 0;
	cellHeight = 26;
	
	rootCell = [[UITreeViewCell alloc] initWithText:@"Root"];
	[self addSubview:rootCell];
	[rootCell setTree:self];
	[rootCell setSupercell:nil];
	[rootCell setAsBranch:YES];
	[rootCell setBranchOpen:YES];
	[rootCell fixFrame:CGRectMake(0,0, self.frame.size.width, cellHeight)];
	
	[self refreshContentSize];
	
	return self;
}

- (void)setRootCell:(UITreeViewCell*)cell
{
	if(rootCell!=cell)
	{
		[rootCell removeFromSuperview];
		[rootCell release];
		rootCell = cell;
		[rootCell retain];
		[rootCell fixFrame:CGRectMake(0,0, self.frame.size.width, cellHeight)];
		[rootCell setTree:self];
		if(rootCell!=nil)
		{
			[self addSubview:rootCell];
		}
	}
}

- (void)setCellHeight:(NSUInteger)height
{
	cellHeight = height;
	[rootCell fixFrame:CGRectMake(0, 0, self.frame.size.width, cellHeight)];
}

- (void)refreshContentSize
{
	lowestIndex = [rootCell getCurrentHeight];
	[self setContentSize:CGSizeMake(self.frame.size.width, lowestIndex)];
}

- (void)dealloc
{
	[rootCell release];
	[super dealloc];
}

@end
