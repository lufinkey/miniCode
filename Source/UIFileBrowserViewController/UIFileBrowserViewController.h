
#import <UIKit/UIKit.h>
#import "NSFilePath.h"
#import "UIFileBrowserDelegate.h"

@interface UIFileBrowserViewController : UINavigationController
{
	NSMutableFilePath* root;
	NSMutableFilePath* path;
	
	id delegate;
	
	UIToolbar* globalToolbar;
	BOOL globalToolbarHidden;
	
	BOOL editing;
}

- (id)initWithString:(NSString*)path;
- (id)initWithString:(NSString*)path delegate:(id<UIFileBrowserDelegate>) delegate;
- (id)initWithString:(NSString*)path root:(NSString*)root;
- (id)initWithString:(NSString*)path root:(NSString*)root delegate:(id<UIFileBrowserDelegate>) delegate;

- (id)initWithFilePath:(NSFilePath*)path;
- (id)initWithFilePath:(NSFilePath*)path delegate:(id<UIFileBrowserDelegate>) delegate;
- (id)initWithFilePath:(NSFilePath*)path root:(NSFilePath*)root;
- (id)initWithFilePath:(NSFilePath*)path root:(NSFilePath*)root delegate:(id<UIFileBrowserDelegate>) delegate;

- (BOOL)selectFile:(NSString*)file;
- (BOOL)selectFolder:(NSString*)folder;

- (void)didSelectFile:(NSString*)file;
- (void)didSelectFolder:(NSString*)folder;
- (void)didSelectFileLink:(NSString*)file;
- (void)didSelectFolderLink:(NSString*)folder;

- (BOOL)navigateToPath:(NSString*)path withRoot:(NSString*)root;
- (void)refreshFolders;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@property (nonatomic, retain, readonly) NSFilePath* root;
@property (nonatomic, retain, readonly) NSFilePath* path;
@property (nonatomic, assign) id<UIFileBrowserDelegate> delegate;
@property (nonatomic, retain, readonly) UIToolbar* globalToolbar;
@property (nonatomic) BOOL globalToolbarHidden;
@property (nonatomic) BOOL editing;

@end
