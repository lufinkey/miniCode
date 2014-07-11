
#import "ConsoleViewController.h"
#import "../Util/UIBarImageButtonItem.h"
#import "../Util/UIImageManager.h"
#import "../Util/Subprocess.h"

@interface ConsoleViewController()
- (void)onOptionsButtonSelected:(id)sender;
- (void)appendOutputString:(NSString*)outputString;
- (void)appendErrorString:(NSString*)errorString;
- (void)appendResultString:(NSString*)resultString;
@end


void ConsoleViewController_OutputReciever(void*data, const char* output)
{
	[((ConsoleViewController*)data) performSelectorOnMainThread:@selector(appendOutputString:) withObject:[NSString stringWithUTF8String:output] waitUntilDone:NO];
}

void ConsoleViewController_ErrorReciever(void*data, const char* error)
{
	[((ConsoleViewController*)data) performSelectorOnMainThread:@selector(appendErrorString:) withObject:[NSString stringWithUTF8String:error] waitUntilDone:NO];
}

void ConsoleViewController_ResultReciever(void*data, int result)
{
	NSMutableString* resultString = [[NSMutableString alloc] initWithUTF8String:"\nresult: "];
	NSNumber* resultNum = [[NSNumber alloc] initWithInt:result];
	[resultString appendString:[resultNum stringValue]];
	[resultNum release];
	[resultString appendString:@"\n"];
	[resultString autorelease];
	
	[((ConsoleViewController*)data) performSelectorOnMainThread:@selector(appendResultString:) withObject:resultString waitUntilDone:NO];
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
	outputView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[outputView setBackgroundColor:[UIColor blackColor]];
	[outputView setTextColor:[UIColor whiteColor]];
	[outputView setEditable:NO];
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
	inputPipe = subprocess_execute([command UTF8String], self, &ConsoleViewController_OutputReciever, &ConsoleViewController_ErrorReciever, &ConsoleViewController_ResultReciever, &pid);
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
	[outputView setText:output];
	[outputView setSelectedRange:NSMakeRange([output length], 0)];
}

- (void)appendErrorString:(NSString*)errorString
{
	[output appendString:errorString];
	[outputView setText:output];
	[outputView setSelectedRange:NSMakeRange([output length], 0)];
}

- (void)appendResultString:(NSString*)resultString
{
	inputPipe = NULL;
	pid = -1;
	[self.navigationItem setHidesBackButton:NO animated:YES];
	
	[output appendString:resultString];
	[outputView setText:output];
	[outputView setSelectedRange:NSMakeRange([output length], 0)];
}

- (void)dealloc
{
	[outputView release];
	[output release];
	[command release];
	[super dealloc];
}

@end
