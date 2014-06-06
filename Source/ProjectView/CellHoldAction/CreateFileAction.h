
#import "CellHoldAction.h"

@interface CreateFileAction : CellHoldAction <UIAlertViewDelegate>
{
	//
}
- (void)createTextFieldAlertViewWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder;
@end
