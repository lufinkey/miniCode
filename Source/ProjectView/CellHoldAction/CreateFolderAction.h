
#import "CellHoldAction.h"

@interface CreateFolderAction : CellHoldAction <UIAlertViewDelegate>
- (void)createTextFieldAlertViewWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder;
@end
