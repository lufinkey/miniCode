
#import "PathListAction.h"

@interface EditLibFoldersAction : PathListAction <UIAlertViewDelegate>
{
@private
	BOOL pathListEdited;
	int pendingIndex;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
