
#import "FileBrowserAction.h"

@interface LinkLibFolderAction : FileBrowserAction
{
@private
	NSString* pendingPath;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
