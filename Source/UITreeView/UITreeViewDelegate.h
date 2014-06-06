
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UITreeView;
@class UITreeViewCell;

@protocol UITreeViewDelegate <UIScrollViewDelegate>

@optional
- (void)treeView:(UITreeView*)treeView didSelectButtonOnCell:(UITreeViewCell*)cell;
- (void)treeView:(UITreeView*)treeView didSelectCell:(UITreeViewCell*)cell;
- (void)treeView:(UITreeView*)treeView didHoldDownOnCell:(UITreeViewCell*)cell;

- (void)treeView:(UITreeView*)treeView branchWillOpen:(UITreeViewCell*)cell;
- (void)treeView:(UITreeView*)treeView branchDidOpen:(UITreeViewCell*)cell;
- (void)treeView:(UITreeView*)treeView branchWillClose:(UITreeViewCell*)cell;
- (void)treeView:(UITreeView*)treeView branchDidClose:(UITreeViewCell*)cell;

@end
