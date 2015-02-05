
#import "CompileErrorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "../Util/UIImageManager.h"
#import "../DeprecationFix/DeprecationDefines.h"

@implementation CompileErrorViewController

- (id)initWithOutputLine:(CompilerOutputLine_struct)outputLine
{
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	int size = (self.view.frame.size.width)/2;
	
	name = [[UILabel alloc] initWithFrame:CGRectMake(size, 0, size, size)];
	[name setBackgroundColor:[UIColor clearColor]];
	[name setTextColor:[UIColor whiteColor]];
	[name setFont:[UIFont fontWithName: @"Trebuchet MS" size: 18.0f]];
	[name setNumberOfLines:0];
	[name setTextAlignment:UITextAlignmentCenter];
	icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
	info = [[UITextView alloc] initWithFrame:CGRectMake(0, size, self.view.frame.size.width, self.view.frame.size.height-size)];
	[info setEditable:NO];
	[info setScrollEnabled:YES];
	[info setFont:[UIFont fontWithName: @"Helvetica" size: 12.0f]];
	info.layer.borderWidth = 2;
	info.layer.borderColor = [[UIColor grayColor] CGColor];
	info.contentInset = UIEdgeInsetsMake(2,0,0,0);
	
	NSString* errorType = [[NSString alloc] initWithUTF8String:CompilerOutputLine_getErrorType(&outputLine)];
	if([errorType isEqual:@"warning"] || [errorType isEqual:@"clang warning"] || [errorType isEqual:@"note"] || [errorType isEqual:@"libtool file"] || [errorType isEqual:@"libtool warning"])
	{
		[icon setImage:[UIImageManager getImage:@"Images/warning.png"]];
		if([errorType length]>0)
		{
			[name setText:errorType];
		}
	}
	else
	{
		[icon setImage:[UIImageManager getImage:@"Images/error.png"]];
		[name setText:errorType];
	}
	[errorType release];
	
	NSMutableString* output = [[NSMutableString alloc] initWithUTF8String:CompilerOutputLine_getOutput(&outputLine)];
	StringList_struct suppOutput = CompilerOutputLine_getSupplementaryOutput(&outputLine);
	for(int i=0; i<StringList_size(&suppOutput); i++)
	{
		NSString* newLine = [[NSString alloc] initWithUTF8String:"\n"];
		NSString* suppLine = [[NSString alloc] initWithUTF8String:StringList_get(&suppOutput, i)];
		[output appendString:newLine];
		[output appendString:suppLine];
		[newLine release];
		[suppLine release];
	}
	[info setText:output];
	[output release];
	
	[self.view addSubview:name];
	[self.view addSubview:icon];
	[self.view addSubview:info];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	if(/*UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad || */self.interfaceOrientation==UIInterfaceOrientationPortrait
	   || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		int size = (self.view.bounds.size.width)/2;
		[name setFrame:CGRectMake(size, 0, size, size)];
		[icon setFrame:CGRectMake(0, 0, size, size)];
		[info setFrame:CGRectMake(0, size, self.view.bounds.size.width, self.view.bounds.size.height-size)];
	}
	else
	{
		int w = self.view.bounds.size.width;
		int h = self.view.bounds.size.height;
		[icon setFrame:CGRectMake(20, 10, (w/2)-40, (w/2)-40)];
		[name setFrame:CGRectMake(0, icon.frame.size.height+10, w/2, 40)];
		[info setFrame:CGRectMake(w/2, 0, w/2, h)];
	}
}

- (void)dealloc
{
	[name release];
	[icon release];
	[info release];
	[super dealloc];
}

@end
