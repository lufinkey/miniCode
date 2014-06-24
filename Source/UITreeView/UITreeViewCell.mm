
#import "UITreeViewCell.h"
#import "../Util/UIImageManager.h"
#import "UITreeView.h"
#import "UITreeViewCell+UITreeView.h"

@interface UITreeViewCell()
- (NSInteger)getIconSize;
- (void)addToTreeView;
- (NSUInteger)getCurrentOffset;
- (void)pushCellsAfterCell:(UITreeViewCell*)cell by:(NSInteger)offset;
- (void)onButtonSelect;
- (void)onControlEventTouchDown;
- (void)onControlEventTouchDragOutside;
- (void)onControlEventTouchUpInside;
- (void)onGestureEventHoldLong:(UIGestureRecognizer*)gestureRecognizer;
@property (nonatomic, retain) UIView* bgView;
@property (nonatomic, retain) UIImageView* carrotView;
@property (nonatomic, retain) UIImageView* iconView;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UIButton* button;
@end


@implementation UITreeViewCell

@synthesize tree;
@synthesize supercell;
@synthesize text;
@synthesize bgView;
@synthesize carrotView;
@synthesize iconView;
@synthesize label;
@synthesize button;
@synthesize cells;

static unsigned int iconPadding = 4;

- (id)initWithText:(NSString*)txt
{
	int offsetX = 0;
	branchOpened = NO;
	isBranch = NO;
	isSelected = NO;
	tree = nil;
	supercell = nil;
	
	int iconsize = [self getIconSize];
	
	if([super initWithFrame:CGRectMake(0, 0, 320, iconsize)]==nil)
	{
		return nil;
	}
	
	[self setUserInteractionEnabled:YES];
	UILongPressGestureRecognizer* gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onGestureEventHoldLong:)];
	gestureRecognizer.minimumPressDuration = 1;
	[self addGestureRecognizer:gestureRecognizer];
	[gestureRecognizer release];
	[self addTarget:self action:@selector(onControlEventTouchDown) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(onControlEventTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
	[self addTarget:self action:@selector(onControlEventTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	
	self.text = txt;
	
	bgView = [[UIView alloc] initWithFrame:CGRectMake(iconsize,0, 320, iconsize)];
	[self addSubview:bgView];
	[bgView setUserInteractionEnabled:NO];
	
	[UIImageManager loadImage:@"Images/arrow_open.png"];
	[UIImageManager loadImage:@"Images/arrow_closed.png"];
	carrotView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, iconsize, iconsize)];
	[carrotView setImage:[UIImageManager getImage:@"Images/arrow_closed.png"]];
	
	[UIImageManager loadImage:@"Images/icons/folder.png"];
	[UIImageManager loadImage:@"Images/icons/file.png"];
	
	offsetX = carrotView.frame.origin.x+iconsize;
	
	iconView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, iconsize, iconsize)];
	[iconView setImage:[UIImageManager getImage:@"Images/icons/file.png"]];
	[self addSubview:iconView];
	[iconView setUserInteractionEnabled:NO];
	
	offsetX = iconView.frame.origin.x+iconView.frame.size.width;
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(offsetX+iconPadding, 0, self.frame.size.width-offsetX-iconPadding, iconsize)];
	[label setText:text];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextColor:[UIColor blackColor]];
	[self addSubview:label];
	[label setUserInteractionEnabled:NO];
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconsize, iconsize)];
	[button addTarget:self action:@selector(onButtonSelect) forControlEvents:UIControlEventTouchUpInside];
	
	cells = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)setText:(NSString*)txt
{
	if(text!=txt)
	{
		[text release];
		text = txt;
		[text retain];
	}
	[label setText:text];
}

- (void)setTree:(UITreeView*)treeView
{
	tree = treeView;
	if(tree!=nil)
	{
		[self updateFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, tree.cellHeight)];
	}
	for(unsigned int i=0; i<[cells count]; i++)
	{
		UITreeViewCell* cell = [cells objectAtIndex:i];
		[cell setTree:treeView];
	}
}

- (void)setSupercell:(UITreeViewCell*)cell
{
	supercell = cell;
	tree = supercell.tree;
}

- (void)updateFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	int iconsize = [self getIconSize];
	
	int offsetX = 0;
	[carrotView setFrame:CGRectMake(offsetX, 0, iconsize, iconsize)];
	
	offsetX = carrotView.frame.origin.x+carrotView.frame.size.width;
	[iconView setFrame:CGRectMake(offsetX, 0, iconsize, iconsize)];
	
	offsetX = iconView.frame.origin.x+iconView.frame.size.width;
	if([self.subviews indexOfObject:button]==NSNotFound)
	{
		[label setFrame:CGRectMake(offsetX+iconPadding, 0, frame.size.width-offsetX-iconPadding, iconsize)];
	}
	else
	{
		[label setFrame:CGRectMake(offsetX+iconPadding, 0, frame.size.width-offsetX-iconsize-iconPadding, iconsize)];
		
		offsetX = label.frame.origin.x+label.frame.size.width;
		[button setFrame:CGRectMake(offsetX, 0, iconsize, iconsize)];
	}
}

- (void)fixFrame:(CGRect)frame
{
	[self updateFrame:frame];
	if(isBranch==YES && branchOpened==YES)
	{
		int iconsize = [self getIconSize];
		
		unsigned int subWidth = frame.size.width-iconsize;
		unsigned int offsetY = frame.origin.y+iconsize;
		int offsetX = frame.origin.x+iconsize;
		for(unsigned int i=0; i<[cells count]; i++)
		{
			UITreeViewCell*cell = [cells objectAtIndex:i];
			[cell fixFrame:CGRectMake(offsetX, offsetY, subWidth, iconsize)];
			int offset = [cell getCurrentHeight];
			offsetY+=offset;
		}
	}
}

- (void)setFrame:(CGRect)frame
{
	if(tree==nil)
	{
		[self fixFrame:frame];
	}
}

- (NSInteger)getIconSize
{
	if(tree!=nil)
	{
		return tree.cellHeight;
	}
	else
	{
		return 26;
	}
}

- (void)removeFromSuperview
{
	if(isBranch==YES && branchOpened==YES)
	{
		for(unsigned int i=0; i<[cells count]; i++)
		{
			[[cells objectAtIndex:i] removeFromSuperview];
		}
	}
	[super removeFromSuperview];
}

- (void)addToTreeView
{
	if(self.tree!=nil)
	{
		int iconsize = [self getIconSize];
		
		[self.tree addSubview:self];
		if(branchOpened==YES)
		{
			unsigned int subWidth = self.frame.size.width-iconsize;
			unsigned int offsetY = self.frame.origin.y+iconsize;
			unsigned int offsetX = self.frame.origin.x+iconsize;
			for(unsigned int i=0; i<[cells count]; i++)
			{
				UITreeViewCell*cell = [cells objectAtIndex:i];
				[cell fixFrame:CGRectMake(offsetX, offsetY, subWidth, iconsize)];
				[cell addToTreeView];
				unsigned int cellHeight = [cell getCurrentHeight];
				offsetY += cellHeight;
			}
		}
	}
}

- (NSUInteger)getCurrentHeight
{
	int iconsize = [self getIconSize];
	if(isBranch==YES && branchOpened==YES)
	{
		unsigned int totalSize = iconsize;
		for(unsigned int i=0; i<[cells count]; i++)
		{
			totalSize += [[cells objectAtIndex:i] getCurrentHeight];
		}
		return totalSize;
	}
	return iconsize;
}

- (NSUInteger)getCurrentOffset
{
	if(supercell==nil)
	{
		return 0;
	}
	else
	{
		int index = [supercell indexOfMember:self];
		if(index==0)
		{
			return [supercell getIconSize] + [supercell getCurrentOffset];
		}
		else
		{
			UITreeViewCell* prevCell = [supercell memberAtIndex:(index-1)];
			return [prevCell getCurrentHeight] + [prevCell getCurrentHeight];
		}
	}
}

- (void)pushCellsAfterCell:(UITreeViewCell*)cell by:(NSInteger)offset
{
	NSUInteger startIndex = [cells indexOfObject:cell];
	if(startIndex!=NSNotFound)
	{
		for(unsigned int i=(startIndex+1); i<[cells count]; i++)
		{
			UITreeViewCell*cell = [cells objectAtIndex:i];
			[cell fixFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+offset, cell.frame.size.width, cell.frame.size.height)];
		}
		
		if(self.supercell!=nil)
		{
			[self.supercell pushCellsAfterCell:self by:offset];
		}
	}
}

- (NSUInteger)getCurrentLevel
{
	if(supercell==nil)
	{
		return 0;
	}
	return 1 + [supercell getCurrentLevel];
}

- (void)setAsBranch:(BOOL)toggle
{
	isBranch = toggle;
	if(toggle==YES)
	{
		if([self.subviews indexOfObject:carrotView]==NSNotFound)
		{
			[self addSubview:carrotView];
		}
	}
	else
	{
		[self setBranchOpen:NO];
		if([self.subviews indexOfObject:carrotView]!=NSNotFound)
		{
			[carrotView removeFromSuperview];
		}
	}
}

- (BOOL)isSetAsBranch
{
	return isBranch;
}

- (void)setBranchOpen:(BOOL)toggle
{
	if(isBranch)
	{
		int iconsize = [self getIconSize];
		
		if(toggle && !branchOpened)
		{
			if(self.tree!=nil && self.tree.delegate!=nil && [self.tree.delegate respondsToSelector:@selector(treeView:branchWillOpen:)])
			{
				[self.tree.delegate treeView:self.tree branchWillOpen:self];
			}
			
			branchOpened = YES;
			//open the branch
			
			[carrotView setImage:[UIImageManager getImage:@"Images/arrow_open.png"]];
			
			unsigned int subWidth = self.frame.size.width-iconsize;
			unsigned int offsetY = self.frame.origin.y+iconsize;
			unsigned int offsetX = self.frame.origin.x+iconsize;
			int pushOffset = 0;
			for(unsigned int i=0; i<[cells count]; i++)
			{
				UITreeViewCell*cell = [cells objectAtIndex:i];
				[cell fixFrame:CGRectMake(offsetX, offsetY, subWidth, iconsize)];
				if(self.tree!=nil)
				{
					[cell addToTreeView];
				}
				unsigned int cellHeight = [cell getCurrentHeight];
				pushOffset += cellHeight;
				offsetY+=cellHeight;
			}
			if(self.supercell!=nil)
			{
				[self.supercell pushCellsAfterCell:self by:pushOffset];
			}
			
			if(self.tree!=nil && self.tree.delegate!=nil && [self.tree.delegate respondsToSelector:@selector(treeView:branchDidOpen:)])
			{
				[self.tree.delegate treeView:self.tree branchDidOpen:self];
			}
		}
		else if(!toggle && branchOpened)
		{
			if(self.tree!=nil && self.tree.delegate!=nil && [self.tree.delegate respondsToSelector:@selector(treeView:branchWillClose:)])
			{
				[self.tree.delegate treeView:self.tree branchWillClose:self];
			}
			
			branchOpened = NO;
			//close the branch
			
			[carrotView setImage:[UIImageManager getImage:@"Images/arrow_closed.png"]];
			
			int pushOffset = 0;
			for(unsigned int i=0; i<[cells count]; i++)
			{
				UITreeViewCell*cell = [cells objectAtIndex:i];
				pushOffset -= [cell getCurrentHeight];
				[cell removeFromSuperview];
			}
			
			if(self.supercell!=nil)
			{
				[self.supercell pushCellsAfterCell:self by:pushOffset];
			}
			
			if(self.tree!=nil && self.tree.delegate!=nil && [self.tree.delegate respondsToSelector:@selector(treeView:branchDidClose:)])
			{
				[self.tree.delegate treeView:self.tree branchDidClose:self];
			}
		}
		if(self.tree!=nil)
		{
			[self.tree refreshContentSize];
		}
	}
}

- (BOOL)isBranchOpen
{
	return branchOpened;
}

- (NSUInteger)count
{
	return [cells count];
}

- (void)addMember:(UITreeViewCell*)cell
{
	if(branchOpened && self.tree!=nil)
	{
		int iconsize = [self getIconSize];
		int offsetY = [self getCurrentHeight];
		[cell setTree:self.tree];
		[cell setSupercell:self];
		[cell fixFrame:CGRectMake(self.frame.origin.x+iconsize, self.frame.origin.y+offsetY, self.frame.size.width-iconsize, iconsize)];
		if(supercell!=nil)
		{
			int pushOffset = [cell getCurrentHeight];
			[supercell pushCellsAfterCell:self by:(pushOffset)];
		}
		[cell addToTreeView];
		[cells addObject:cell];
	}
	else
	{
		[cell setTree:self.tree];
		[cell setSupercell:self];
		[cells addObject:cell];
	}
	if(self.tree!=nil)
	{
		[self.tree refreshContentSize];
	}
}

- (void)insertMember:(UITreeViewCell *)cell atIndex:(NSUInteger)index
{
	if(index==[cells count])
	{
		[self addMember:cell];
	}
	else if(index<[cells count])
	{
		/*BOOL reOpenWhenDone = branchOpened;
		if(branchOpened && self.tree!=nil)
		{
			[self setBranchOpen:NO];
		}*/
		if(branchOpened && self.tree!=nil)
		{
			int iconsize = [self getIconSize];
			[cell setTree:self.tree];
			[cell setSupercell:self];
			int pushOffset = 0;
			pushOffset = [cell getCurrentHeight];
			
			int offsetY = 0;
			if(index==0 && supercell!=nil)
			{
				offsetY = [supercell getIconSize];
			}
			else if(index>0)
			{
				offsetY = [supercell getIconSize];
				for(int i=0; i<index; i++)
				{
					offsetY += [[cells objectAtIndex:i] getCurrentHeight];
				}
			}
			
			[cell fixFrame:CGRectMake(self.frame.origin.x+iconsize, self.frame.origin.y+offsetY, self.frame.size.width-iconsize, iconsize)];
			[cells insertObject:cell atIndex:index];
			[self pushCellsAfterCell:cell by:pushOffset];
			[cell addToTreeView];
		}
		else
		{
			[cell setTree:self.tree];
			[cell setSupercell:self];
			[cells insertObject:cell atIndex:index];
		}
		/*if(reOpenWhenDone)
		{
			[self setBranchOpen:YES];
		}*/
	}
	if(self.tree!=nil)
	{
		[self.tree refreshContentSize];
	}
}

- (void)removeMember:(UITreeViewCell*)cell
{
	[cell retain];
	int index = [cells indexOfObject:cell];
	if(index!=NSNotFound)
	{
		if(branchOpened)
		{
			int cellHeight = [cell getCurrentHeight];
			[self pushCellsAfterCell:cell by:(-cellHeight)];
			[cells removeObjectAtIndex:index];
			[cell removeFromSuperview];
		}
		else
		{
			[cells removeObjectAtIndex:index];
			[cell removeFromSuperview];
		}
		if(self.tree!=nil)
		{
			[self.tree refreshContentSize];
		}
	}
	[cell release];
}

- (void)removeMemberAtIndex:(NSUInteger)index
{
	UITreeViewCell* cell = [cells objectAtIndex:index];
	if(cell!=nil)
	{
		if(branchOpened)
		{
			int cellHeight = [cell getCurrentHeight];
			[self pushCellsAfterCell:cell by:(-cellHeight)];
			[cells removeObjectAtIndex:index];
			[cell removeFromSuperview];
		}
		else
		{
			[cells removeObjectAtIndex:index];
			[cell removeFromSuperview];
		}
		if(self.tree!=nil)
		{
			[self.tree refreshContentSize];
		}
	}
}

- (void)removeAllMembers
{
	if(isBranch && branchOpened)
	{
		[self setBranchOpen:NO];
	}
	
	[cells removeAllObjects];
}

- (UITreeViewCell*)memberAtIndex:(NSUInteger)index
{
	return [cells objectAtIndex:index];
}

- (NSInteger)indexOfMember:(UITreeViewCell*)cell
{
	return [cells indexOfObject:cell];
}

- (void)moveMemberAtIndex:(NSUInteger)srcIndex toIndex:(NSUInteger)dstIndex
{
	UITreeViewCell* cell = [[cells objectAtIndex:srcIndex] retain];
	[self removeMemberAtIndex:srcIndex];
	[self insertMember:cell atIndex:dstIndex];
	[cell release];
}

- (void)setIcon:(UIImage*)icon
{
	[iconView setImage:icon];
}

- (void)setButtonShown:(BOOL)toggle
{
	if(toggle==YES)
	{
		int iconsize = [self getIconSize];
		
		int offsetX = iconView.frame.origin.x+iconView.frame.size.width;
		[label setFrame:CGRectMake(offsetX, 0, self.frame.size.width-offsetX-iconsize, iconsize)];
		
		offsetX = label.frame.origin.x+label.frame.size.width;
		[button setFrame:CGRectMake(offsetX, 0, iconsize, iconsize)];
		
		if([self.subviews indexOfObject:carrotView]==NSNotFound)
		{
			[self addSubview:button];
		}
	}
	else
	{
		int iconsize = [self getIconSize];
		
		if([self.subviews indexOfObject:carrotView]!=NSNotFound)
		{
			[button removeFromSuperview];
			[button setFrame:CGRectMake(0, 0, iconsize, iconsize)];
		}
	}
}

- (void)setButtonImage:(UIImage*)image forState:(UIControlState)state
{
	[button setImage:image forState:state];
}

- (void)deselect
{
	isSelected = NO;
	[bgView setBackgroundColor:[UIColor clearColor]];
}

- (void)onButtonSelect
{
	if(self.tree!=nil && self.tree.delegate!=nil && [self.tree.delegate respondsToSelector:@selector(treeView:didSelectButtonOnCell:)])
	{
		[self.tree.delegate treeView:self.tree didSelectButtonOnCell:self];
	}
}



//Events



- (void)onControlEventTouchDown
{
	isSelected = YES;
	int iconsize = [self getIconSize];
	if(isBranch==YES)
	{
		[bgView setFrame:CGRectMake(0,0,self.frame.size.width,iconsize)];
	}
	else
	{
		[bgView setFrame:CGRectMake(iconsize,0,self.frame.size.width-iconsize,iconsize)];
	}
	[bgView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
}

- (void)onControlEventTouchUpInside
{
	if(isSelected)
	{
		[self deselect];
		if(isBranch==YES && self.tree!=nil)
		{
			if(branchOpened==YES)
			{
				//close the branch
				[self setBranchOpen:NO];
			}
			else
			{
				//open the branch
				[self setBranchOpen:YES];
			}
		}
		else
		{
			//perform selection action
			if(self.tree!=nil && self.tree.delegate!=nil && [self.tree.delegate respondsToSelector:@selector(treeView:didSelectCell:)])
			{
				[self.tree.delegate treeView:self.tree didSelectCell:self];
			}
		}
	}
}

- (void)onControlEventTouchDragOutside
{
	[self deselect];
}

- (void)onGestureEventHoldLong:(UIGestureRecognizer*)gesture
{
	if(gesture.state==UIGestureRecognizerStateBegan)
	{
		if(tree!=nil && tree.delegate!=nil && [self.tree.delegate respondsToSelector:@selector(treeView:didHoldDownOnCell:)])
		{
			[self.tree.delegate treeView:self.tree didHoldDownOnCell:self];
		}
	}
	else if(gesture.state==UIGestureRecognizerStateCancelled)
	{
		[self deselect];
	}
	else if(gesture.state==UIGestureRecognizerStateEnded)
	{
		[self onControlEventTouchUpInside];
	}
}

- (void)dealloc
{
	[text release];
	[bgView release];
	[carrotView release];
	[iconView release];
	[label release];
	[button release];
	[cells release];
	[super dealloc];
}

@end
