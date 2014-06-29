
#import "UITreeView.h"
#import "UITreeViewCell.h"

@interface UITreeView()
- (void)addSubview:(UIView*)subview animated:(BOOL)animated;
@property (nonatomic, readonly) double animationTime;
@end

@interface UITreeViewCell()
- (void)removeFromSuperviewAnimated:(BOOL)animated;
- (void)setTree:(UITreeView*)tree;
- (void)setSupercell:(UITreeViewCell*)cell;
- (void)fixFrame:(CGRect)frame;
- (void)fixFrame:(CGRect)frame animated:(BOOL)animated;
- (void)updateFrame:(CGRect)frame;
- (void)updateFrame:(CGRect)frame animated:(BOOL)animated;
- (NSUInteger)getCurrentHeight;
@end
