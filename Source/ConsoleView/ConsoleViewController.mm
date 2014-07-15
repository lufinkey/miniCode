
#import "ConsoleViewController.h"
#import "../Util/UIBarImageButtonItem.h"
#import "../Util/UIImageManager.h"
#import "../Util/Subprocess.h"

@interface ConsoleViewController()
- (void)onOptionsButtonSelected:(id)sender;
- (void)appendOutputString:(NSString*)outputString;
- (void)appendErrorString:(NSString*)errorString;
- (void)appendResultString:(NSString*)resultString;
- (void)endInput;
- (void)setText:(NSString*)text;
@end


void ConsoleViewController_OutputReciever(void*data, const char* output)
{
	NSLog(@"Recieved output: \"%s\"", output);
	[((ConsoleViewController*)data) performSelectorOnMainThread:@selector(appendOutputString:) withObject:[NSString stringWithUTF8String:output] waitUntilDone:NO];
}

void ConsoleViewController_ErrorReciever(void*data, const char* error)
{
	NSLog(@"Recieved error: \"%s\"", error);
	[((ConsoleViewController*)data) performSelectorOnMainThread:@selector(appendErrorString:) withObject:[NSString stringWithUTF8String:error] waitUntilDone:NO];
}

void ConsoleViewController_ResultReciever(void*data, int result)
{
	NSLog(@"Recieved result: %i", result);
	ConsoleViewController* viewCtrl = ((ConsoleViewController*)data);
	[viewCtrl endInput];
	
	NSMutableString* resultString = [[NSMutableString alloc] initWithUTF8String:"\nresult: "];
	NSNumber* resultNum = [[NSNumber alloc] initWithInt:result];
	[resultString appendString:[resultNum stringValue]];
	[resultNum release];
	[resultString appendString:@"\n"];
	[resultString autorelease];
	
	[viewCtrl performSelectorOnMainThread:@selector(appendResultString:) withObject:resultString waitUntilDone:NO];
}


@implementation ConsoleViewController

@synthesize outputView;
@synthesize command;
@synthesize pid;
@synthesize inputPipe;

- (id)initWithCommand:(NSString*)cmd
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	inputPipe = NULL;
	pid = -1;
	command = [[NSString alloc] initWithString:cmd];
	output = [[NSMutableString alloc] initWithUTF8String:""];
	input = [[NSMutableString alloc] initWithUTF8String:""];
	outputView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[outputView setBackgroundColor:[UIColor blackColor]];
	[outputView setTextColor:[UIColor whiteColor]];
	outputView.delegate = self;
	settingText = NO;
	returning = NO;
	[self.view addSubview:outputView];
	
	NSString* wrenchPath = @"Images/buttons_white/wrench.png";
	[UIImageManager loadImage:wrenchPath];
	UIBarImageButtonItem* optionsButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:wrenchPath] target:self action:@selector(onOptionsButtonSelected:)];
	[self.navigationItem setRightBarButtonItem:optionsButton];
	[optionsButton release];
	[self.navigationItem setHidesBackButton:YES animated:NO];
	
	return self;
}

- (void)resetLayout
{
	[super resetLayout];
	[outputView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	inputPipe = subprocess_execute([command UTF8String], self, &ConsoleViewController_OutputReciever, &ConsoleViewController_ErrorReciever, &ConsoleViewController_ResultReciever, false, &pid);
}

- (void)onOptionsButtonSelected:(id)sender
{
	consoleOptionsMenu = [[ConsoleOptionsActionSheet alloc] initForConsoleViewController:self];
	[consoleOptionsMenu showInView:self.navigationItem.rightBarButtonItem.customView];
	[consoleOptionsMenu release];
}

- (void)appendOutputString:(NSString*)outputString
{
	[output appendString:outputString];
	[input setString:@""];
	[self setText:output];
	[outputView setSelectedRange:NSMakeRange([output length], 0)];
}

- (void)appendErrorString:(NSString*)errorString
{
	[output appendString:errorString];
	[input setString:@""];
	[self setText:output];
	[outputView setSelectedRange:NSMakeRange([output length], 0)];
}

- (void)appendResultString:(NSString*)resultString
{
	inputPipe = NULL;
	pid = -1;
	[self.navigationItem setHidesBackButton:NO animated:YES];
	
	[output appendString:resultString];
	[input setString:@""];
	[self setText:output];
	[outputView setSelectedRange:NSMakeRange([output length], 0)];
}

- (void)endInput
{
	inputPipe = NULL;
	pid = -1;
}

- (void)setText:(NSString*)text
{
	settingText = YES;
	[outputView setText:text];
	settingText = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
	if(settingText)
	{
		return YES;
	}
	
	if(range.location<[output length])
	{
		[outputView setSelectedRange:NSMakeRange([output length] + [input length], 0)];
		return NO;
	}
	else
	{
		if(inputPipe==NULL)
		{
			[input deleteCharactersInRange:NSMakeRange(0, [input length])];
			return NO;
		}
		
		[input replaceCharactersInRange:NSMakeRange(range.location-[output length], range.length) withString:text];
		
		int lastNewLine = 0;
		for(int i=0; i<[input length]; i++)
		{
			if([input UTF8String][i]=='\n')
			{
				NSString* substring = [input substringWithRange:NSMakeRange(lastNewLine, i+1)];
				lastNewLine = i+1;
				[output appendString:substring];
				if(inputPipe!=NULL)
				{
					NSLog(@"Sending input to program");
					int written = fwrite([input UTF8String], 1, [input length]+1, inputPipe);
					if(written!=([input length]+1))
					{
						NSLog(@"Error sending input. Only %i bytes sent", written);
					}
					else
					{
						NSLog(@"Sent input to program");
					}
				}
				else
				{
					NSLog(@"Error sending input. Program is not running.");
				}
			}
		}
		
		if(lastNewLine!=0)
		{
			[input replaceCharactersInRange:NSMakeRange(0, lastNewLine) withString:@""];
		}
		
		return YES;
	}
}

- (void)dealloc
{
	[outputView release];
	[output release];
	[input release];
	[command release];
	[super dealloc];
}

@end
