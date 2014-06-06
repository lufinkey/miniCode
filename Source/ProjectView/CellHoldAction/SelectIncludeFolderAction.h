
#import "FileBrowserAction.h"

@interface SelectIncludeFolderAction : FileBrowserAction
{
@private
	NSString* pendingPath;
	BOOL presentWaiting;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController root:(NSString*)root;

@end
