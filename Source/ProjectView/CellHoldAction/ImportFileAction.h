
#import "FileBrowserAction.h"

@interface ImportFileAction : FileBrowserAction
{
@private
	NSString* pendingPath;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
