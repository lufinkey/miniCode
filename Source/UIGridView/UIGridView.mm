
#import "UIGridView.h"
#import "UIGridViewCell+UIGridView.h"
#import "../ObjCBridge/ObjCBridge.h"

@interface UIGridView()
- (CGPoint)getPointForIndex:(NSUInteger)index;
@end

@implementation UIGridView

@synthesize cells;
@synthesize selectedIndex;
@synthesize delegate;
@synthesize cellSize;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self==nil)
	{
		return nil;
	}
	
	self.delegate = nil;
	
	selectedIndex = -1;
	
	cells = [[NSMutableArray alloc] init];
	[self setScrollEnabled:YES];
	
	cellSize = 160;
	
	return self;
}

- (CGPoint)getPointForIndex:(NSUInteger)index
{
	unsigned int cols = self.frame.size.width/cellSize;
	int xLoc = 0;
	int yLoc = 0;
	if(index>cols)
	{
		xLoc = (index%cols)*cellSize;
		yLoc = (index/cols)*cellSize;
	}
	else
	{
		xLoc = index*cellSize;
		yLoc = 0;
	}
	return CGPointMake(xLoc, yLoc);
}

- (void)setCellSize:(NSUInteger)size
{
	cellSize = size;
	for(unsigned int i=0; i<[cells count]; i++)
	{
		CGPoint point = [self getPointForIndex:i];
		UIGridViewCell* cell = [cells objectAtIndex:i];
		[cell fixFrame:CGRectMake(point.x, point.y, cellSize, cellSize)];
		
		if(i==([cells count]-1))
		{
			[self setContentSize:CGSizeMake(self.frame.size.width, point.y+cellSize)];
		}
	}
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	for(unsigned int i=0; i<[cells count]; i++)
	{
		CGPoint point = [self getPointForIndex:i];
		UIGridViewCell* cell = [cells objectAtIndex:i];
		[cell fixFrame:CGRectMake(point.x, point.y, cellSize, cellSize)];
		
		if(i==([cells count]-1))
		{
			[self setContentSize:CGSizeMake(self.frame.size.width, point.y+cellSize)];
		}
	}
}

- (void)setSelectedIndex:(NSInteger)index
{
	selectedIndex = index;
}

- (void)addCell:(UIGridViewCell*)cell
{
	if(cell.gridView==nil)
	{
		CGPoint point = [self getPointForIndex:[cells count]];
		[cell fixFrame:CGRectMake(point.x, point.y, cellSize, cellSize)];
		[cells addObject:cell];
		[cell setGridView:self];
		[self addSubview:cell];
		
		[self setContentSize:CGSizeMake(self.frame.size.width, point.y+cellSize)];
	}
}

- (void)addCell:(UIGridViewCell *)cell atIndex:(NSUInteger)index
{
	if(cell.gridView==nil)
	{
		CGPoint point = [self getPointForIndex:index];
		[cell fixFrame:CGRectMake(point.x, point.y, cellSize, cellSize)];
		[cells insertObject:cell atIndex:index];
		[cell setGridView:self];
		[self addSubview:cell];
		if(index==([cells count]-1))
		{
			[self setContentSize:CGSizeMake(self.frame.size.width, point.y+cellSize)];
		}
		else
		{
			for(unsigned int i=(index+1); i<[cells count]; i++)
			{
				CGPoint otherPoint = [self getPointForIndex:i];
				UIGridViewCell* otherCell = [cells objectAtIndex:i];
				[otherCell fixFrame:CGRectMake(otherPoint.x, otherPoint.y, cellSize, cellSize)];
				
				if(i==([cells count]-1))
				{
					[self setContentSize:CGSizeMake(self.frame.size.width, otherPoint.y+cellSize)];
				}
			}
		}
	}
}

- (void)dealloc
{
	[cells release];
	[super dealloc];
}

@end
