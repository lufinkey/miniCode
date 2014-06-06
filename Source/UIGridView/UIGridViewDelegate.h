
#import <Foundation/Foundation.h>

@class UIGridView;

@protocol UIGridViewDelegate <UIScrollViewDelegate>

@optional
- (void)gridView:(UIGridView*)gridView didSelectIndex:(NSUInteger)index;

@end
