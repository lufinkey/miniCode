
#import "FontSizePreviewViewController.h"
#import "GlobalPreferences.h"

@implementation FontSizePreviewViewController

@synthesize preview;
@synthesize sizer;

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	preview = [[UIControlLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CODEEDITOR_MAXFONTSIZE+60)];
	[preview setText:@"Preview"];
	[preview setTextColor:[UIColor blackColor]];
	[preview setBackgroundColor:[UIColor whiteColor]];
	[preview setTextAlignment:UITextAlignmentCenter];
	[preview setVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[self.view addSubview:preview];
	
	sizer = [[UISlider alloc] initWithFrame:CGRectMake(40, CODEEDITOR_MAXFONTSIZE+60, self.view.frame.size.width-40, 20)];
	[sizer setMinimumValue:CODEEDITOR_MINFONTSIZE];
	[sizer setMaximumValue:CODEEDITOR_MAXFONTSIZE];
	[sizer setValue:GlobalPreferences_getCodeEditorFontSize()];
	[sizer addTarget:self action:@selector(sizerDidChangeValue) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:sizer];
	
	sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CODEEDITOR_MAXFONTSIZE+60, 40, 40)];
	NSNumber* sizeNum = [[NSNumber alloc] initWithUnsignedInt:GlobalPreferences_getCodeEditorFontSize()];
	[sizeLabel setText:[sizeNum stringValue]];
	[sizeNum release];
	[sizeLabel setTextAlignment:UITextAlignmentCenter];
	[sizeLabel setTextColor:[UIColor whiteColor]];
	[sizeLabel setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:sizeLabel];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[sizer setValue:GlobalPreferences_getCodeEditorFontSize()];
	
	NSString* fontName = [NSString stringWithUTF8String:GlobalPreferences_getCodeEditorFont()];
	[preview setFont:[UIFont fontWithName:fontName size:GlobalPreferences_getCodeEditorFontSize()]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[preview setFrame:CGRectMake(0, 0, self.view.bounds.size.width, preview.frame.size.height)];
	[sizer setFrame:CGRectMake(sizer.frame.origin.x, sizer.frame.origin.y, self.view.bounds.size.width-sizer.frame.origin.x, sizer.frame.size.height)];
}

- (void)sizerDidChangeValue
{
	unsigned int size = sizer.value;
	GlobalPreferences_setCodeEditorFontSize(size);
	[preview setFont:[preview.font fontWithSize:size]];
	
	NSNumber* sizeNum = [[NSNumber alloc] initWithUnsignedInt:size];
	[sizeLabel setText:[sizeNum stringValue]];
	[sizeNum release];
}

- (void)dealloc
{
	[preview release];
	[sizer release];
	[super dealloc];
}

@end
