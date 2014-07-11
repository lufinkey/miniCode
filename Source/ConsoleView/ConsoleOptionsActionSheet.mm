
#import "ConsoleOptionsActionSheet.h"
#import "ConsoleViewController.h"
#import "../ObjCBridge/ObjCBridge.h"
#import <signal.h>

@implementation ConsoleOptionsActionSheet

- (id)initForConsoleViewController:(ConsoleViewController*)consoleViewCtrl
{
	self = [super initWithTitle:@"Console Options"
					   delegate:self
			  cancelButtonTitle:@"Cancel"
		 destructiveButtonTitle:nil
			  otherButtonTitles:@"Kill", @"Terminate", @"Copy Output", nil];
	if(self==nil)
	{
		return nil;
	}
	
	viewCtrl = consoleViewCtrl;
	
	return self;
}

- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch(buttonIndex)
	{
		case 0:
		//Cancel
		break;
		
		case 1:
		//Kill
		if(viewCtrl.inputPipe!=NULL)
		{
			int result = kill(viewCtrl.pid, SIGKILL);
			if(result==-1)
			{
				switch(errno)
				{
					case EINVAL:
					showSimpleMessageBox("Error", "The value of sig is invalid");
					break;
					
					case EPERM:
					showSimpleMessageBox("Error", "You do not have permission to send a signal to the specified pid");
					break;
					
					case ESRCH:
					showSimpleMessageBox("Error", "No processes or process groups correspond to pid");
					break;
				}
			}
		}
		break;
		
		case 2:
		//Terminate
		if(viewCtrl.inputPipe!=NULL)
		{
			int result = kill(viewCtrl.pid, SIGTERM);
			if(result==-1)
			{
				switch(errno)
				{
					case EINVAL:
					showSimpleMessageBox("Error", "The value of sig is invalid");
					break;
					
					case EPERM:
					showSimpleMessageBox("Error", "You do not have permission to send a signal to the specified pid");
					break;
					
					case ESRCH:
					showSimpleMessageBox("Error", "No processes or process groups correspond to pid");
					break;
				}
			}
		}
		break;
		
		case 3:
		//Copy Output
		{
			NSString* copyString = [[NSString alloc] initWithString:viewCtrl.outputView.text];
			[[UIPasteboard generalPasteboard] setString:copyString];
			[copyString release];
		}
		break;
	}
}

@end
