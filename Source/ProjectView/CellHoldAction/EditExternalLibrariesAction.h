
#import "FileBrowserAction.h"

@interface EditExternalLibrariesAction : FileBrowserAction
{
@private
	NSString* pendingPath;
	BOOL includesEdited;
	BOOL libsEdited;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
