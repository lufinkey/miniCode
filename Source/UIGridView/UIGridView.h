
#import <UIKit/UIKit.h>
#import "UIGridViewCell.h"
#import "UIGridViewDelegate.h"

@interface UIGridView : UIScrollView
{
	NSInteger selectedIndex;
	id delegate;
	NSUInteger cellSize;
	
	@private
	NSMutableArray* cells;
}

- (id)initWithFrame:(CGRect)frame;

- (void)addCell:(UIGridViewCell*)cell;
- (void)addCell:(UIGridViewCell *)cell atIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, retain, readonly) NSArray* cells;
@property (nonatomic, assign) id<UIGridViewDelegate> delegate;
@property (nonatomic) NSUInteger cellSize;

@end
