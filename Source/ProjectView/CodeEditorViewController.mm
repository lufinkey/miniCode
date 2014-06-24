
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

@interface CodeEditorViewController()
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
@synthesize codeArea;
@synthesize currentFilePath;

- (id)init
{
	fileEdited = NO;
	locked = NO;
	isOnScreen = NO;
	returning = NO;
	codeEditing = NO;
	currentFilePath = nil;
	
	if([super init]==nil)
	{
		return nil;
	}
	
	int height = self.view.frame.size.height;
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, height-32, self.view.frame.size.width, 32)];
	[toolbar setBarStyle:UIBarStyleBlack];
	[self.view addSubview:toolbar];
	
	codeArea = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height-toolbar.frame.size.height)];
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
	[toolbar setFrame:CGRectMake(0, self.view.frame.size.height-toolbar.frame.size.height, self.view.frame.size.width, toolbar.frame.size.height)];
	[codeArea setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-toolbar.frame.size.height)];
}

- (void)loadNormalToolbarItems
{
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	
	[UIImageManager loadImage:@"Images/buttons_white/indent_less.png"];
	UIBarImageButtonItem* indentLessButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/indent_less.png"] target:self action:@selector(indentLeftButtonSelected)];
	[indentLessButton setSize:28];
	[toolbarItems addObject:indentLessButton];
	[indentLessButton release];
	
	UIBarButtonItem*flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/buttons_white/indent_more.png"];
	UIBarImageButtonItem* indentMoreButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/indent_more.png"] target:self action:@selector(indentRightButtonSelected)];
	[indentMoreButton setSize:28];
	[toolbarItems addObject:indentMoreButton];
	[indentMoreButton release];
	
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/buttons_white/save.png"];
	UIBarImageButtonItem* saveButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/save.png"] target:self action:@selector(saveCurrentFile)];
	[saveButton setSize:28];
	[toolbarItems addObject:saveButton];
	[saveButton release];
	
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/buttons_white/keyboard.png"];
	UIBarImageButtonItem* keyboardButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/keyboard.png"] target:self action:@selector(keyboardButtonSelected)];
	[keyboardButton setSize:28];
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
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];
	
	UIBarButtonItem*flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[toolbarItems addObject:flexibleSpace];
	
	[UIImageManager loadImage:@"Images/lock.png"];
	UIBarImageButtonItem* lockButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/lock.png"] target:self action:@selector(lockButtonSelected)];
	[lockButton setSize:28];
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
		
		[codeArea setText:fileContents];
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

- (void)buildButtonSelected
{
	BuildOptionsActionSheet* buildOptions = [[BuildOptionsActionSheet alloc] initForViewController:self];
	[buildOptions showInView:self.view];
	[buildOptions release];
}

- (void)indentLeftButtonSelected
{
	if(codeArea.isFirstResponder)
	{
		NSMutableArray* linePoints = [[NSMutableArray alloc] init];
		int counter = 0;
		int lastLinePoint = 0;
		
		NSRange selectedRange = codeArea.selectedRange;
		
		for(int i=0; i<selectedRange.location; i++)
		{
			char c = [codeArea.text UTF8String][i];
			if(c=='\n')
			{
				lastLinePoint = i+1;
			}
			counter++;
		}
		
		NSNumber*currentLine = [[NSNumber alloc] initWithInt:lastLinePoint];
		[linePoints addObject:currentLine];
		[currentLine release];
		
		int highlightOffset = 0;
		if(counter==lastLinePoint && selectedRange.length>0)
		{
			highlightOffset++;
		}
		
		for(int i=0; i<selectedRange.length; i++)
		{
			char c = [codeArea.text UTF8String][counter];
			if(c=='\n')
			{
				highlightOffset++;
				currentLine = [[NSNumber alloc] initWithInt:counter+1];
				[linePoints addObject:currentLine];
				[currentLine release];
			}
			counter++;
		}
		
		NSMutableString* newText = [[NSMutableString alloc] initWithString:codeArea.text];
		
		for(int i=([linePoints count]-1); i>=0; i--)
		{
			int linePoint = [[linePoints objectAtIndex:i] intValue];
			int j = linePoint;
			BOOL parsedSpacing = NO;
			int spaces = 0;
			int tabs = 0;
			int lastSize = 0;
			while(!parsedSpacing && j<[newText length])
			{
				char c = [codeArea.text UTF8String][j];
				if(c==' ')
				{
					spaces++;
					if(spaces>=8)
					{
						spaces=0;
						tabs++;
					}
				}
				else if(c=='\t')
				{
					lastSize = spaces+1;
					spaces = 0;
					tabs++;
				}
				else
				{
					parsedSpacing = YES;
				}
				j++;
			}
			
			j--;
			
			unsigned int deleteLength = 0;
			unsigned int deletePoint = 0;
			if(spaces>0)
			{
				deleteLength = spaces;
				deletePoint = j-deleteLength;
			}
			else if(tabs>0)
			{
				deleteLength = lastSize;
				deletePoint = j-deleteLength;
			}
			else
			{
				deleteLength = 0;
				deletePoint = j;
			}
			
			if(deletePoint<selectedRange.location)
			{
				if(selectedRange.location>=deleteLength)
				{
					selectedRange.location-=deleteLength;
				}
				else
				{
					selectedRange.location = 0;
				}
			}
			else
			{
				if(selectedRange.length>=deleteLength)
				{
					selectedRange.length-=deleteLength;
				}
				else
				{
					selectedRange.length = 0;
				}
			}
			
			[newText deleteCharactersInRange:NSMakeRange(deletePoint, deleteLength)];
		}
		
		[codeArea setScrollEnabled:NO];
		[codeArea setText:newText];
		[newText release];
		[linePoints release];
		[codeArea setSelectedRange:NSMakeRange(selectedRange.location, selectedRange.length)];
		[codeArea setScrollEnabled:YES];
	}
}

- (void)indentRightButtonSelected
{
	if(codeArea.isFirstResponder)
	{
		NSRange selectedRange = codeArea.selectedRange;
		
		if(selectedRange.length==0)
		{
			NSMutableString* newText = [[NSMutableString alloc] initWithString:codeArea.text];
			NSString* tabEscape = [[NSString alloc] initWithUTF8String:"\t"];
			[newText insertString:tabEscape atIndex:selectedRange.location];
			
			[codeArea setScrollEnabled:NO];
			[codeArea setText:newText];
			[newText release];
			[codeArea setSelectedRange:NSMakeRange(selectedRange.location+1, 0)];
			[codeArea setScrollEnabled:YES];
			[tabEscape release];
		}
		else
		{
			NSMutableArray* linePoints = [[NSMutableArray alloc] init];
			int lastLinePoint = 0;
			
			if(selectedRange.location == 0)
			{
				lastLinePoint = 0;
			}
			else
			{
				for(int i=((selectedRange.location)-1); i>=0; i--)
				{
					char c = [codeArea.text UTF8String][i];
					if(c=='\n')
					{
						lastLinePoint = i+1;
						i=0;
					}
					else
					{
						if(i==0)
						{
							lastLinePoint = 0;
						}
					}
				}
			}
			
			int counter = lastLinePoint;
			
			NSNumber*currentLine = [[NSNumber alloc] initWithInt:lastLinePoint];
			[linePoints addObject:currentLine];
			[currentLine release];
			
			int highlightOffset = 0;
			if(lastLinePoint==selectedRange.location && selectedRange.length>0)
			{
				highlightOffset++;
			}
			
			for(int i=0; i<selectedRange.length; i++)
			{
				char c = [codeArea.text UTF8String][counter];
				if(c=='\n')
				{
					highlightOffset++;
					currentLine = [[NSNumber alloc] initWithInt:counter+1];
					[linePoints addObject:currentLine];
					[currentLine release];
				}
				counter++;
			}
			
			NSMutableString* newText = [[NSMutableString alloc] initWithString:codeArea.text];
			NSString* tabEscape = [[NSString alloc] initWithUTF8String:"\t"];
			
			for(int i=([linePoints count]-1); i>=0; i--)
			{
				int linePoint = [[linePoints objectAtIndex:i] intValue];
				[newText insertString:tabEscape atIndex:linePoint];
			}
			
			[codeArea setScrollEnabled:NO];
			[codeArea setText:newText];
			[newText release];
			[linePoints release];
			[codeArea setSelectedRange:NSMakeRange(selectedRange.location+1, selectedRange.length+highlightOffset)];
			[codeArea setScrollEnabled:YES];
			[tabEscape release];
		}
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
	[codeArea setText:@""];
	[codeArea resignFirstResponder];
}

- (void)textViewDidChange:(UITextView*)textView
{
	self.fileEdited = YES;
	if(returning)
	{
		int lastLine = 0;
		
		BOOL foundLastLine = NO;
		
		int currentNewline = codeArea.selectedRange.location-1;
		
		int i=currentNewline-1;
		while(i>=0 && !foundLastLine)
		{
			if(i==0)
			{
				foundLastLine = YES;
				lastLine = 0;
			}
			else
			{
				char c = [codeArea.text UTF8String][i];
				if(c=='\n')
				{
					lastLine = i+1;
					foundLastLine = YES;
				}
			}
			i--;
		}
		
		BOOL parsedSpacing = NO;
		int spaces = 0;
		int tabs = 0;
		i=lastLine;
		while(i<currentNewline && !parsedSpacing)
		{
			char c = [codeArea.text UTF8String][i];
			if(c==' ')
			{
				spaces++;
				if(spaces>=8)
				{
					spaces=0;
					tabs++;
				}
			}
			else if(c=='\t')
			{
				spaces = 0;
				tabs++;
			}
			else
			{
				parsedSpacing = YES;
			}
			i++;
		}
		
		NSMutableString* newText = [[NSMutableString alloc] initWithString:codeArea.text];
		int insertionPoint = currentNewline+1;
		for(int j=0; j<tabs; j++)
		{
			NSString* tabEscape = [[NSString alloc] initWithUTF8String:"\t"];
			[newText insertString:tabEscape atIndex:insertionPoint];
			[tabEscape release];
			insertionPoint++;
		}
		
		for(int j=0; j<spaces; j++)
		{
			NSString* space = [[NSString alloc] initWithUTF8String:" "];
			[newText insertString:space atIndex:insertionPoint];
			[space release];
			insertionPoint++;
		}
		
		[codeArea setScrollEnabled:NO];
		[codeArea setText:newText];
		[newText release];
		[codeArea setSelectedRange:NSMakeRange(insertionPoint, 0)];
		[codeArea setScrollEnabled:YES];
	}
	returning = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{  
	if([text isEqual:@"\n"])
	{
		returning = YES;
	}
	return YES;
}

- (void)keyboardDidShow:(NSNotification*)notification
{
	if(self.navigationController.topViewController == self)
	{
		CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		
		if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
		{
			[codeArea setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.height-toolbar.frame.size.height)];
			[toolbar setFrame:CGRectMake(0, self.view.frame.size.height-keyboardSize.height-32, self.view.frame.size.width, 32)];
		}
		else
		{
			[codeArea setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.width-toolbar.frame.size.height)];
			[toolbar setFrame:CGRectMake(0, self.view.frame.size.height-keyboardSize.width-32, self.view.frame.size.width, 32)];
		}
	}
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	[codeArea setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-toolbar.frame.size.height)];
	[toolbar setFrame:CGRectMake(0, self.view.frame.size.height-32, self.view.frame.size.width, 32)];
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
	[super dealloc];
}

@end
