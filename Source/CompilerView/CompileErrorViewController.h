
#import <UIKit/UIKit.h>
#import "../Compiler/CompilerTools.h"
#import "../Navigation/NavigatedViewController.h"

@interface CompileErrorViewController : NavigatedViewController
{
	@private
	UIImageView* icon;
	UILabel* name;
	UITextView* info;
}

- (id)initWithOutputLine:(CompilerOutputLine_struct)outputLine;

@end
