
#import "CellHoldAction.h"

@interface RenameAction : CellHoldAction <UIAlertViewDelegate>
- (void)createTextFieldAlertViewWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder;
@end
