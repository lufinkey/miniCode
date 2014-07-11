
#import <UIKit/UIKit.h>

@class ConsoleViewController;

@interface ConsoleOptionsActionSheet : UIActionSheet <UIActionSheetDelegate>
{
	@private
	ConsoleViewController* viewCtrl;
}

- (id)initForConsoleViewController:(ConsoleViewController*)consoleViewCtrl;
@end
