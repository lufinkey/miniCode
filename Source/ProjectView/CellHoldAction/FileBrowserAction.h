
#import "CellHoldAction.h"
#import "../../LGViewHUD/LGViewHUD.h"
#import "../../UIFileBrowserViewController/UIFileBrowserViewController.h"

@interface FileBrowserAction : CellHoldAction <UIFileBrowserDelegate>
{
	UIFileBrowserViewController* fileBrowserCtrl;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController path:(NSString*)path root:(NSString*)root;

@property (nonatomic, retain) UIFileBrowserViewController* fileBrowserCtrl;
@end
