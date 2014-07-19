
#import "../Navigation/NavigatedViewController.h"
#import "ConsoleOptionsActionSheet.h"

@interface ConsoleViewController : NavigatedViewController <UITextViewDelegate>
{
	NSString* command;
	NSMutableString* output;
	NSMutableString* input;
	UITextView* outputView;
	
	ConsoleOptionsActionSheet* consoleOptionsMenu;
	int pid;
	int inputPipe;
	
	@private
	BOOL settingText;
	BOOL returning;
}

- (id)initWithCommand:(NSString*)command;

- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;

@property (nonatomic, readonly) UITextView* outputView;
@property (nonatomic, readonly) NSString* command;
@property (nonatomic, readonly) int pid;
@property (nonatomic, readonly) int inputPipe;
@end
