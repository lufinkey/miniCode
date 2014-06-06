
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../UITreeView/UITreeView.h"
#import "../Navigation/NavigatedViewController.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "ProjectTreeViewCell.h"
#import "FileEditorDelegate.h"
#import "../LGViewHUD/LGViewHUD.h"
#import "../UIFileBrowserViewController/UIFileBrowserViewController.h"
#import "PathListTableViewController.h"

static NSArray* EXTENSIONS_CODEEDITOR  = [[NSArray alloc]
										  initWithObjects:@"c", @"cc", @"cpp", @"h", @"m", @"mm",
										  @"txt", @"strings", nil];
static NSArray* EXTENSIONS_TEXTEDITOR  = [[NSArray alloc]
										  initWithObjects:@"txt", @"list", @"strings", nil];
static NSArray* EXTENSIONS_IMAGEVIEWER = [[NSArray alloc]
										  initWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", @"tif", nil];
static NSArray* EXTENSIONS_AUDIOPLAYER = [[NSArray alloc]
										  initWithObjects:@"mp3", @"wav", @"aac", @"m4a", nil];
static NSArray* EXTENSIONS_PLISTEDITOR = [[NSArray alloc]
										  initWithObjects:@"plist", nil];

@class CellHoldAction;

@interface ProjectTreeViewController : NavigatedViewController <UITreeViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIFileBrowserDelegate, PathListTableViewControllerDelegate>
{
	UITreeView* treeView;
	
	ProjectTreeViewCell* srcCell;
	ProjectTreeViewCell* resCell;
	ProjectTreeViewCell* extCell;
	ProjectTreeViewCell* includeCell;
	ProjectTreeViewCell* libCell;
	ProjectTreeViewCell* frameworksCell;
	
	ProjectTreeViewCell* selectedCell;
	
	LGViewHUD* operationHUD;
	UIView* obstructView;
	
@private
	CellHoldAction* currentHoldAction;
	
	UIActionSheet* srcFolderMenu;
	UIActionSheet* resFolderMenu;
	UIActionSheet* extFolderMenu;
	UIActionSheet* includeMenu;
	UIActionSheet* libMenu;
	UIActionSheet* frameworksMenu;
	UIActionSheet* fileMenu;
	UIActionSheet* folderMenu;
	UIActionSheet* frameworkMenu;
}

- (void)loadWithProjectData:(ProjectData_struct*)projData;
- (id<FileEditorDelegate>)getFileViewerByExtension:(NSString*)extension;
- (void)exitProjectView;

+ (void)addStringTreeToCell:(ProjectTreeViewCell*)cell tree:(StringTree_struct*)tree;
+ (void)addDirectoryListToCell:(ProjectTreeViewCell*)cell list:(StringList_struct*)list;
+ (void)expandDynamicFolderCell:(ProjectTreeViewCell*)cell;

- (void)buildButtonSelected;

- (void)showObstructionInView:(UIView*)view;
- (void)hideOperationHUDZoom;
- (void)hideOperationHUDFade;

@property (nonatomic, retain) UITreeView* treeView;
@property (nonatomic, retain) ProjectTreeViewCell* srcCell;
@property (nonatomic, retain) ProjectTreeViewCell* resCell;
@property (nonatomic, retain) ProjectTreeViewCell* extCell;
@property (nonatomic, retain) ProjectTreeViewCell* includeCell;
@property (nonatomic, retain) ProjectTreeViewCell* libCell;
@property (nonatomic, retain) ProjectTreeViewCell* frameworksCell;

@property (nonatomic, assign, readonly) ProjectTreeViewCell* selectedCell;

@property (nonatomic, assign) LGViewHUD* operationHUD;
@property (nonatomic, retain) UIView* obstructView;

@end
