
#import <UIKit/UIKit.h>
#import "../Compiler/CompilerTools.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../Navigation/NavigatedViewController.h"
#import "../UIFileBrowserViewController/NSFilePath.h"
#import "../LGViewHUD/LGViewHUD.h"

@interface CompilerViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource>
{
	@private
	BOOL closing;
	BOOL runWhenFinished;
	BOOL running;
	//int scrollOffset;
	NSIndexPath* selectedPath;
	UITableView* errorTable;
	UIImageView* successView;
	UINavigationBar* statusBar;
	UILabel* statusLabel;
	LGViewHUD* installHUD;
	NSFilePath* projectRootPath;
	CompilerOrganizer_struct* organizer;
	ProjectData_struct* projData;
}

- (id)initWithProjectData:(ProjectData_struct*)projData;

- (void)build;
- (void)buildAndRun;

- (BOOL)isRunning;

- (void)doneButtonSelected;

@end
