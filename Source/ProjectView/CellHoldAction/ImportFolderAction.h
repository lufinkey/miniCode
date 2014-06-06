
#import "FileBrowserAction.h"

@interface ImportFolderAction : FileBrowserAction
{
@private
	NSString* pendingPath;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
