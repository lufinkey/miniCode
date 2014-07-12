
#import "CodeEditorViewController.h"
#import "../iCodeAppDelegate.h"
#import "../ProjectLoad/ProjLoadTools.h"
#import "../PreferencesView/GlobalPreferences.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../Util/UIImageManager.h"
#import "../Util/UIBarImageButtonItem.h"
#import "../IconManager/IconManager.h"
#import "ProjectTreeViewController.h"
#import "../CompilerView/BuildOptionsActionSheet.h"
#import "../UIFileBrowserViewController/NSFilePath.h"
#import "../RegexHighlightView/SyntaxDefinitionManager.h"

@interface CodeEditorViewController()
- (void)overwriteRange:(NSRange)range withText:(NSString*)text;
- (void)setText:(NSString*)text;
- (void)addReturnPoint:(NSUInteger)point;
- (NSUInteger)popReturnPoint;
- (void)pushReturnPointsAfter:(NSUInteger)point by:(NSInteger)amount;
- (void)removePointsBetweenPoint:(NSUInteger)startPoint andPoint:(NSUInteger)endPoint;
- (void)setFileEdited:(BOOL)edited;
- (void)setCurrentFilePath:(NSString*)path;
- (void)loadNormalToolbarItems;
- (void)loadLockedToolbarItems;
- (void)loadEmptyToolbarItems;
@end

void DismissCodeViewAlertHandler(void*data, int buttonIndex)
{
	CodeEditorViewController* viewCtrl = (CodeEditorViewController*)data;
	
	if(buttonIndex==0)
	{
		// save and pop view controller
		if([viewCtrl saveCurrentFile])
		{
			[viewCtrl.navigationController popViewControllerAnimated:YES];
		}
	}
	else if(buttonIndex==1)
	{
		// pop view controller
		
		[viewCtrl setFileEdited:NO];
		[viewCtrl.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		// do nothing
	}
}


@implementation CodeEditorViewController

@synthesize toolbar;
@synthesize fileEdited;
@synthesize locked;
@synthesize isOnScreen;
@synthesize currentFilePath;

- (id)init
{
	fileEdited = NO;
	locked = NO;
	isOnScreen = NO;
	codeEditing = NO;
	currentFilePath = nil;
	insertingText = NO;
	
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	returnPoints = [[NSMutableArray alloc] init];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	int height = self.view.frame.size.height;
	
	toolbar = [[UIScrollableToolbar alloc] initWithFrame:CGRectMake(0, height-32, self.view.frame.size.width, 32)];
	[toolbar setBarStyle:UIBarStyleBlack];
	[self.view addSubview:toolbar];
	
	codeArea = [[UICodeEditorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height-toolbar.frame.size.height)];
	[codeArea setDelegate:self];
	[codeArea setAutocorrectionType:UITextAutocorrectionTypeNo];
	[codeArea setEnablesReturnKeyAutomatically:YES];
	[self.view addSubview:codeArea];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	
	[self loadEmptyToolbarItems];
	
	[UIImageManager loadImage:@"Images/buttons_white/build.png"];
	UIBarImageButtonItem* buildButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/build.png"] target:self action:@selector(buildButtonSelected)];
	[buildButton setSize:32];
	[self.navigationItem setRightBarButtonItem:buildButton];
	[buildButton release];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(locked)
	{
		[codeArea setEditable:NO];
		[self loadLockedToolbarItems];
	}
	else
	{
		[codeArea setEditable:YES];
		[self loadNormalToolbarItems];
	}
	isOnScreen = YES;
	
	NSString*fontName = [[NSString alloc] initWithUTF8String:GlobalPreferences_getCodeEditorFont()];
	UIFont*font = [UIFont fontWithName:fontName size:GlobalPreferences_getCodeEditorFontSize()];
	if(font!=nil)
	{
		[codeArea setFont:font];
	}
	else
	{
		[codeArea setFont:[UIFont fontWithName:@"Helvetica" size:GlobalPreferences_getCodeEditorFontSize()]];
	}
	[fontName release];
	
	BOOL highlighting = GlobalPreferences_syntaxHighlightingEnabled();
	[codeArea setHighlightingEnabled:highlighting];
	
	[codeArea setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self setFileLocked:locked];
}

- (void)viewDidDisappear:(BOOL)animated
{
	isOnScreen = NO;
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	
	int toolbarHeight = 32;
	if(self.interfaceOrientation==UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation==UIInterfaceOrientationLandscapeRight)
	{
		toolbarHeight = 26;
	}
	
	[toolbar setFrame:CGRectMake(0, self.view.bounds.size.height-toolbarHeight, self.view.bounds.size.width, toolbarHeight)];
	if(locked)
	{
		[self loadLockedToolbarItems];
	}
	else
	{
		[self loadNormalToolbarItems];
	}
	[codeArea setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-toolbarHeight)];
}

- (void)loadNormalToolbarItems
{
	int buttonSize = toolbar.bounds.size.height-4;
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	
	[UIImageManager loadImage:@"Images/buttons_white/indent_less.png"];
	UIBarImageButtonItem* indentLessButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/indent_less.png"] target:self action:@selector(indentLeftButtonSelected)];
	[indentLessButton setSize:buttonSize];
	[toolbarItems addObject:indentLessButton];
	[indentLessButton release];
	
	UIBarButtonItem*flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/buttons_white/indent_more.png"];
	UIBarImageButtonItem* indentMoreButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/indent_more.png"] target:self action:@selector(indentRightButtonSelected)];
	[indentMoreButton setSize:buttonSize];
	[toolbarItems addObject:indentMoreButton];
	[indentMoreButton release];
	
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/buttons_white/save.png"];
	UIBarImageButtonItem* saveButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/save.png"] target:self action:@selector(saveCurrentFile)];
	[saveButton setSize:buttonSize];
	[toolbarItems addObject:saveButton];
	[saveButton release];
	
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/buttons_white/keyboard.png"];
	UIBarImageButtonItem* keyboardButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/keyboard.png"] target:self action:@selector(keyboardButtonSelected)];
	[keyboardButton setSize:buttonSize];
	[toolbarItems addObject:keyboardButton];
	[keyboardButton release];
	
	if(isOnScreen)
	{
		[toolbar setItems:toolbarItems animated:YES];
	}
	else
	{
		[toolbar setItems:toolbarItems animated:NO];
	}
	[toolbarItems release];
	
	[flexibleSpace release];
}

- (void)loadLockedToolbarItems
{
	int buttonSize = self.toolbar.bounds.size.height-4;
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem*flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/lock.png"];
	UIBarImageButtonItem* lockButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/lock.png"] target:self action:@selector(lockButtonSelected)];
	[lockButton setSize:buttonSize];
	[toolbarItems addObject:lockButton];
	[lockButton release];
	
	[toolbarItems addObject:flexibleSpace];
	
	if(isOnScreen)
	{
		[toolbar setItems:toolbarItems animated:YES];
	}
	else
	{
		[toolbar setItems:toolbarItems animated:NO];
	}
	[toolbarItems release];
	
	[flexibleSpace release];
}

- (void)loadEmptyToolbarItems
{
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	if(isOnScreen)
	{
		[toolbar setItems:toolbarItems animated:YES];
	}
	else
	{
		[toolbar setItems:toolbarItems animated:NO];
	}
	[toolbarItems release];
}

- (BOOL)loadWithFile:(NSString*)filePath
{
	if(currentFilePath!=nil)
	{
		return NO;
	}
	
	self.fileEdited = NO;
	[self setCurrentFilePath:nil];
	
	NSMutableString* fileContents = [[NSMutableString alloc] init];
	bool success = FileTools_loadFileIntoNSMutableString([filePath UTF8String], fileContents);
	if(success)
	{
		[self setCurrentFilePath:filePath];
		
		self.fileEdited = NO;
		
		[self setText:fileContents];
		[fileContents release];
		
		NSString* extension = [IconManager getExtensionForFilename:filePath];
		if(NSString_isEqualToObjectInArray(extension, EXTENSIONS_CODEEDITOR))
		{
			codeEditing = YES;
		}
		else
		{
			codeEditing = NO;
		}
		locked = NO;
		
		NSDictionary* syntaxDefinitions = [SyntaxDefinitionManager loadSyntaxDefinitionsForFile:filePath];
		[codeArea setHighlightDefinition:syntaxDefinitions];
		
		return YES;
	}
	else
	{
		[fileContents release];
		showSimpleMessageBox("Error", "Unable to load file");
		return NO;
	}
}

- (BOOL)saveCurrentFile
{
	bool success = FileTools_writeStringToFile([currentFilePath UTF8String], [codeArea.text UTF8String]);
	if(success && self.fileEdited)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		if(appDelegate.projData!=NULL)
		{
			ProjectBuildInfo_struct projBuildInfo = ProjectData_getProjectBuildInfo(appDelegate.projData);
			
			NSFilePath* fullPath = [[NSFilePath alloc] initWithString:currentFilePath];
			
			NSMutableString* srcRoot = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
			[srcRoot appendString:@"/"];
			NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
			[srcRoot appendString:saveFolder];
			[saveFolder release];
			[srcRoot appendString:@"/src"];
			
			NSFilePath* srcRootPath = [[NSFilePath alloc] initWithString:srcRoot];
			[srcRoot release];
			
			if([fullPath containsSubfoldersOf:srcRootPath])
			{
				NSFilePath* relPath = [fullPath pathRelativeTo:srcRootPath];
				
				NSMutableString* pathString = [[NSMutableString alloc] initWithString:[relPath pathAsString]];
				
				if([pathString UTF8String][0]=='/')
				{
					[pathString deleteCharactersInRange:NSMakeRange(0, 1)];
				}
				
				ProjectBuildInfo_addEditedFile(&projBuildInfo, [pathString UTF8String]);
				ProjectBuildInfo_saveBuildInfoPlist(&projBuildInfo, appDelegate.projData);
				
				[pathString release];
			}
			
			[fullPath release];
			[srcRootPath release];
		}
	}
	
	if(success)
	{
		self.fileEdited = NO;
		return YES;
	}
	else
	{
		showSimpleMessageBox("Error", "Unable to save file");
		return NO;
	}
}

- (void)setText:(NSString*)text
{
	BOOL wasInserting = insertingText;
	insertingText = NO;
	
	[codeArea setText:text];
	
	insertingText = wasInserting;
}

- (void)overwriteRange:(NSRange)range withText:(NSString*)text
{
	BOOL wasInserting = insertingText;
	insertingText = NO;
	
	[codeArea overwriteRange:range withText:text];
	
	insertingText = wasInserting;
}

- (void)addReturnPoint:(NSUInteger)point
{
	NSNumber* number = [[NSNumber alloc] initWithUnsignedInt:point];
	[returnPoints addObject:number];
	[number release];
}

- (NSUInteger)popReturnPoint
{
	NSUInteger number = [[returnPoints objectAtIndex:0] unsignedIntValue];
	[returnPoints removeObjectAtIndex:0];
	return number;
}

- (void)pushReturnPointsAfter:(NSUInteger)point by:(NSInteger)amount
{
	for(unsigned int i=0; i<[returnPoints count]; i++)
	{
		NSNumber* number = [returnPoints objectAtIndex:i];
		NSUInteger integer = [number unsignedIntValue];
		if(integer>point)
		{
			if(amount<0)
			{
				if((-amount)<integer)
				{
					integer += amount;
				}
				else
				{
					integer = 0;
				}
			}
			else
			{
				integer += amount;
			}
		}
		
		[returnPoints removeObjectAtIndex:i];
		
		number = [[NSNumber alloc] initWithUnsignedInt:integer];
		if([returnPoints count]==0)
		{
			[returnPoints addObject:number];
		}
		else
		{
			[returnPoints insertObject:number atIndex:i];
		}
		[number release];
	}
}

- (void)removePointsBetweenPoint:(NSUInteger)startPoint andPoint:(NSUInteger)endPoint
{
	for(int i=([returnPoints count]-1); i>=0; i--)
	{
		NSUInteger number = [[returnPoints objectAtIndex:i] unsignedIntValue];
		if(number>=startPoint && number<endPoint)
		{
			[returnPoints removeObjectAtIndex:i];
		}
	}
}

- (void)buildButtonSelected
{
	BuildOptionsActionSheet* buildOptions = [[BuildOptionsActionSheet alloc] initForViewController:self];
	[buildOptions showInView:self.view];
	[buildOptions release];
}

- (void)indentLeftButtonSelected
{
	if([codeArea isFirstResponder])
	{
		[codeArea tabLeft:codeArea.selectedRange];
	}
}

- (void)indentRightButtonSelected
{
	if([codeArea isFirstResponder])
	{
		[codeArea tabRight:codeArea.selectedRange];
	}
}

- (void)keyboardButtonSelected
{
	if(codeArea.isFirstResponder)
	{
		[codeArea resignFirstResponder];
	}
	else
	{
		[codeArea becomeFirstResponder];
		[self goToPoint:0];
	}
}

- (void)lockButtonSelected
{
	showSimpleMessageBox("Locked", "This file is locked to prevent editing");
}

- (NSInteger)goToLine:(NSUInteger)line offset:(NSUInteger)offset
{
	const char* text = [codeArea.text UTF8String];
	
	int currentLine = 0;
	int counter = 0;
	while(currentLine!=line)
	{
		char c = text[counter];
		if(c=='\0')
		{
			return -1;
		}
		else if(c=='\n')
		{
			currentLine++;
		}
		counter++;
	}
	
	for(int i=0; i<offset; i++)
	{
		char c = text[counter];
		if(c=='\0')
		{
			return -1;
		}
		counter++;
	}
	
	[self goToPoint:counter];
	return counter;
}

- (void)goToPoint:(NSUInteger)offset
{
	if(codeArea.editable)
	{
		[codeArea becomeFirstResponder];
		[codeArea setSelectedRange:NSMakeRange(offset, 0)];
	}
	else
	{
		[codeArea setSelectedRange:NSMakeRange(offset, 1)];
	}
}

- (BOOL)shouldNavigateBackward
{
	if(fileEdited)
	{
		const char*buttonLabels[3] = {"Yes", "No", "Cancel"};
		showSimpleMessageBox("Save", "Would you like to save changes made to this file?", buttonLabels, 3, self, &DismissCodeViewAlertHandler, NULL);
		return NO;
	}
	return YES;
}

- (void)didNavigateBackwardTo:(UIViewController*)viewController
{
	[self loadEmptyToolbarItems];
	locked = NO;
	[self  setCurrentFilePath:nil];
	codeEditing = NO;
	[self setText:@""];
	[codeArea resignFirstResponder];
}

- (void)textViewDidChange:(UITextView*)textView
{
	self.fileEdited = YES;
	while([returnPoints count]>0)
	{
		NSUInteger point = [self popReturnPoint]+1;
		if(codeArea.selectedRange.location>=2)
		{
			TabOffset tabOffset = [codeArea tabOffsetForLine:(point-2)];
			
			NSMutableString* tabText = [[NSMutableString alloc] init];
			NSString* tabString = [[NSString alloc] initWithUTF8String:"\t"];
			for(unsigned int i=0; i<tabOffset.tabs; i++)
			{
				[tabText appendString:tabString];
			}
			[tabString release];
			
			NSString* spaceString = [[NSString alloc] initWithUTF8String:" "];
			for(unsigned int i=0; i<tabOffset.spaces; i++)
			{
				[tabText appendString:spaceString];
			}
			[spaceString release];
			[codeArea insertText:tabText atPoint:codeArea.selectedRange.location];
			
			[self pushReturnPointsAfter:(point+1) by:[tabText length]];
			[tabText release];
		}
	}
	[textView setNeedsDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[scrollView setNeedsDisplay];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
	if([text isEqual:@"\n"])
	{
		[self addReturnPoint:range.location];
		return YES;
	}
	else
	{
		[self removePointsBetweenPoint:range.location andPoint:range.location+range.length];
		int offset = (int)[text length] - (int)range.length;
		if(offset!=0)
		{
			[self pushReturnPointsAfter:range.location by:offset];
		}
	}
	
	if(insertingText || [text length]<=1)
	{
		return YES;
	}
	else
	{
		[self overwriteRange:range withText:text];
		return NO;
	}
}

- (void)keyboardDidShow:(NSNotification*)notification
{
	if(self.navigationController.topViewController == self)
	{
		CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		
		int toolbarHeight = toolbar.bounds.size.height;
		
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
		{
			[codeArea setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-keyboardSize.height-toolbarHeight)];
			[toolbar setFrame:CGRectMake(0, self.view.bounds.size.height-keyboardSize.height-toolbarHeight, self.view.bounds.size.width, toolbarHeight)];
		}
		else
		{
			[codeArea setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-keyboardSize.width-toolbarHeight)];
			[toolbar setFrame:CGRectMake(0, self.view.bounds.size.height-keyboardSize.width-toolbarHeight, self.view.frame.size.width, toolbarHeight)];
		}
	}
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	int toolbarHeight = toolbar.bounds.size.height;
	
	[codeArea setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-toolbarHeight)];
	[toolbar setFrame:CGRectMake(0, self.view.bounds.size.height-toolbarHeight, self.view.bounds.size.width, toolbarHeight)];
}

- (void)setFileEdited:(BOOL)edited
{
	fileEdited = edited;
	if(currentFilePath!=nil)
	{
		NSFilePath* filePath = [[NSFilePath alloc] initWithString:currentFilePath];
		NSMutableString* header = [[NSMutableString alloc] initWithString:[filePath lastMember]];
		if(edited)
		{
			[header insertString:@"*" atIndex:0];
		}
		[filePath release];
		[self.navigationItem setTitle:header];
		[header release];
	}
}

- (void)setCurrentFilePath:(NSString*)path
{
	if(currentFilePath!=path)
	{
		[currentFilePath release];
		currentFilePath = path;
		[currentFilePath retain];
	}
}

- (void)setFileLocked:(BOOL)lock
{
	locked = lock;
	if(isOnScreen)
	{
		if(locked)
		{
			[codeArea setEditable:NO];
			[self loadLockedToolbarItems];
		}
		else
		{
			[codeArea setEditable:YES];
			[self loadNormalToolbarItems];
		}
	}
}

- (void)dealloc
{
	[codeArea release];
	[currentFilePath release];
	[toolbar release];
	[returnPoints release];
	[super dealloc];
}

@end
