
#import <Foundation/Foundation.h>
#import "UITreeViewDelegate.h"
#import "UITreeViewCell.h"

@interface UITreeView : UIScrollView
{
	UITreeViewCell* rootCell;
	
	id delegate;
	NSUInteger cellHeight;
	
	@private
	unsigned int lowestIndex;
}

- (void)refreshContentSize;

@property (nonatomic) NSUInteger cellHeight;
@property (nonatomic, assign) id<UITreeViewDelegate> delegate;
@property (nonatomic, retain) UITreeViewCell* rootCell;

@end
