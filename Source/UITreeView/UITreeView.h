
#import <Foundation/Foundation.h>
#import "UITreeViewDelegate.h"
#import "UITreeViewCell.h"

@interface UITreeView : UIScrollView
{
	UITreeViewCell* rootCell;
	
	id delegate;
	NSUInteger cellHeight;
	BOOL animatesByDefault;
	
	@private
	unsigned int lowestIndex;
	double animationTime;
}

- (void)setRootCell:(UITreeViewCell*)rootCell animated:(BOOL)animated;
- (void)setCellHeight:(NSUInteger)cellHeight animated:(BOOL)animated;

- (void)refreshContentSize;

@property (nonatomic) NSUInteger cellHeight;
@property (nonatomic) BOOL animatesByDefault;
@property (nonatomic, assign) id<UITreeViewDelegate> delegate;
@property (nonatomic, retain) UITreeViewCell* rootCell;

@end
