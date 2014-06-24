
#import "UITreeView.h"
#import "UITreeViewCell.h"

@interface UITreeViewCell()
- (void)setTree:(UITreeView*)tree;
- (void)setSupercell:(UITreeViewCell*)cell;
- (void)fixFrame:(CGRect)frame;
- (void)updateFrame:(CGRect)frame;
- (NSUInteger)getCurrentHeight;
@end
