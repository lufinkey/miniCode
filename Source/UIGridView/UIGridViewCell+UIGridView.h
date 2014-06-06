
#import "UIGridView.h"
#import "UIGridViewCell.h"

@interface UIGridView()
- (void)setSelectedIndex:(NSInteger)index;
@end

@interface UIGridViewCell()
- (void)setGridView:(UIGridView*)grid;
- (void)fixFrame:(CGRect)frame;
@end