
#import "FileBrowserAction.h"

@interface LinkIncludeFolderAction : FileBrowserAction
{
@private
	NSString* pendingPath;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
