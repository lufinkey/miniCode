
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UIFileBrowserViewController;

@protocol UIFileBrowserDelegate <UINavigationControllerDelegate>

@optional
- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldOpenFolder:(NSString*)folder;
- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFile:(NSFilePath*)path;
- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFolder:(NSFilePath*)path;
- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFileLink:(NSFilePath*)path;
- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFolderLink:(NSFilePath*)path;

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser willOpenFolder:(NSString*)folder;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didOpenFolder:(NSString*)folder;

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFile:(NSString*)file;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFolder:(NSString*)folder;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFileLink:(NSString*)file;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBroswer didSelectFolderLink:(NSString*)folder;

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser willNavigateBackToPath:(NSFilePath*)path;

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser reloadCell:(UITableViewCell*)cell;

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser viewDidDisappear:(BOOL)animated;

- (BOOL)canEditItemsInFileBrowser:(UIFileBrowserViewController*)fileBrowser;
- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldDeleteFile:(NSFilePath*)file;
- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldDeleteFolder:(NSFilePath*)folder;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser errorDeletingFile:(NSFilePath*)file;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser errorDeletingFolder:(NSFilePath*)folder;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didDeleteFile:(NSFilePath*)file;
- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didDeleteFolder:(NSFilePath*)folder;

@end
