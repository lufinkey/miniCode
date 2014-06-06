
#import "FileBrowserAction.h"

@interface ImportExternalLibraryAction : FileBrowserAction
{
@private
	NSString* pendingPath;
	BOOL presentWaiting;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
