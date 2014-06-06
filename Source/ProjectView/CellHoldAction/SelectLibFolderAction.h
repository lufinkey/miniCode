
#import "FileBrowserAction.h"

@interface SelectLibFolderAction : FileBrowserAction
{
@private
	NSString* pendingPath;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController root:(NSString*)root;

@end
