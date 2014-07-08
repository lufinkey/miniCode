
#import "FileBrowserAction.h"

@interface ImportFileAction : FileBrowserAction
{
@private
	NSString* pendingPath;
	BOOL copyingBranches;
	StringTree_struct* contents;
	StringTree_struct destBranch;
	NSInteger currentIndex;
	
	NSString* srcFolder;
	NSString* dstFolder;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
