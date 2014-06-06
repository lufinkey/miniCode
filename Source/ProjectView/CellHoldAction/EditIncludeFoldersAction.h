
#import "PathListAction.h"

@interface EditIncludeFoldersAction : PathListAction <UIAlertViewDelegate>
{
@private
	BOOL pathListEdited;
	int pendingIndex;
}

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController;

@end
