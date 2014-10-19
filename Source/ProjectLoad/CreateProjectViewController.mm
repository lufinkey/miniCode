
#import "CreateProjectViewController.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "ProjLoadTools.h"
#import "../iCodeAppDelegate.h"

@implementation CreateProjectViewController
{
	UITextField* projectNameField,
             * projectAuthorField;
	BOOL closingAndLoading;
}

@synthesize projectNameField, projectAuthorField, closingAndLoading;

- init {

  if (!(self = super.init)) return nil;

	self.title = @"Create Project";
	
	int textInputHeight = 36,  //create textinput boxes;
       textInputWidth = 256,
              centerX = self.view.frame.size.width/2;

	projectNameField    = [UITextField.alloc initWithFrame:CGRectMake(centerX-(textInputWidth/2), 40,
                                                                    textInputWidth, textInputHeight)];
	[projectNameField setPlaceholder:@"Name"];
	[projectNameField setBorderStyle:UITextBorderStyleRoundedRect];
  [projectNameField becomeFirstResponder];
	[projectNameField addTarget:self action:@selector(textFieldDidChange:)
                         forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:projectNameField];
	
	projectAuthorField = [UITextField.alloc initWithFrame:CGRectMake(centerX-(textInputWidth/2), 90,
                                                                   textInputWidth, textInputHeight)];
	[projectAuthorField setPlaceholder:@"Author"];
  [projectAuthorField setText:UIDevice.currentDevice.name];
	[projectAuthorField setBorderStyle:UITextBorderStyleRoundedRect];
	[projectAuthorField addTarget:self action:@selector(textFieldDidChange:)
                           forControlEvents:UIControlEventEditingChanged];

  projectAuthorField .font    = projectNameField.font     = [UIFont fontWithName: @"Helvetica" size: 26.0f];
  projectAuthorField.delegate = projectNameField.delegate = self;

  [self.view addSubview:projectAuthorField];
	
	UIBarButtonItem*cancelButton, *nextButton;

	[self.navigationItem setLeftBarButtonItem:cancelButton =
      [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                             action:@selector(cancelCreateProject)]
                                  animated:YES];
	[cancelButton release];
	
	[self.navigationItem setRightBarButtonItem: nextButton =
        [UIBarButtonItem.alloc initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self
                                                           action:@selector(nextButtonSelected)]
                                    animated:YES];
	[nextButton release];
	return self;
}

- (void)    viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
	if(![projectAuthorField isFirstResponder] && UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
		[projectNameField becomeFirstResponder];
}

- (void)     viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
	if(![projectAuthorField isFirstResponder] && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
		[projectNameField becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {

  [super viewWillAppear:animated];
	if(UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad) return;
  [@[projectNameField, projectAuthorField ] makeObjectsPerformSelector:@selector(resignFirstResponder)];
  [self.view endEditing:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

  return YES;
}

- (void) resetLayout {

  [super resetLayout];
	UIInterfaceOrientation orientation = self.interfaceOrientation;
  int textInputWidth, textInputHeight, centerX;

	if(orientation==UIInterfaceOrientationPortrait	|| orientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		textInputWidth  = 256;
    textInputHeight = 36;
            centerX = (self.view.bounds.size.width/2);

		[projectNameField   setFrame:CGRectMake(centerX-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
		[projectAuthorField setFrame:CGRectMake(centerX-(textInputWidth/2), 90, textInputWidth, textInputHeight)];
	}
	else
	{
		 textInputWidth = 200;
    textInputHeight = 36;
            centerX = (self.view.bounds.size.width/3) - 25;
		[projectNameField setFrame:CGRectMake(centerX-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
            centerX = ((self.view.bounds.size.width/3)*2) + 25;
		[projectAuthorField setFrame:CGRectMake(centerX-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
	}
}

- (void) nextButtonSelected {

  iCodeAppDelegate*appDelegate = UIApplication.sharedApplication.delegate;
	const char*name = projectNameField.text.UTF8String,
          *author = projectAuthorField.text.UTF8String;
	
	bool  nameValid = ProjectData_checkValidString(name),
      authorValid = ProjectData_checkValidString(author);
	
	if(nameValid && authorValid)
		[self.navigationController pushViewController:appDelegate.selectTemplateCategoryController animated:YES];
	else
	{
		NSString*message = [NSString.alloc initWithString:
        name==NULL  || !strlen(name)    ? @"Please enter a valid name" :
      author==NULL  || !strlen(author)  ? @"Please enter a valid author" :
      @"Name and Author fields may only contain letters, numbers, underscores, periods, commas, or dashes"];

    	showSimpleMessageBox("", [message UTF8String]);
		[message release];
	}
}

- (void) cancelCreateProject {

  [self clearTextFields];
	[self dismissModalViewControllerAnimated:YES];
}

- (void) clearTextFields {

  [projectNameField   setText:@""];
	[projectAuthorField setText:@""];
}

- (void)  closeAndLoadTemplate:(NSString*)templateName category:(NSString*)category {

  iCodeAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
	[@[projectNameField,projectAuthorField] makeObjectsPerformSelector:@selector(resignFirstResponder)];
	
	appDelegate.projData = ProjLoad_prepareProjectFromTemplate([category UTF8String], [templateName UTF8String]);
	if(appDelegate.projData==NULL)
	{
		showSimpleMessageBox("Error", "Unable to load template");
		[self clearTextFields];
		[self dismissModalViewControllerAnimated:YES];
		[appDelegate.createProjectNavigator popToRootViewControllerAnimated:NO];
	}
	else
	{
		[appDelegate.projectTreeController loadWithProjectData:appDelegate.projData];
		
		[self clearTextFields];
		[self dismissModalViewControllerAnimated:YES];
		[appDelegate.createProjectNavigator popToRootViewControllerAnimated:NO];
		[appDelegate.rootNavigator pushViewController:appDelegate.projectTreeController animated:YES];
	}
}

- (void)  willNavigateBackward:(UIViewController*)viewController {

  [self cancelCreateProject];
}

- (void)    textFieldDidChange:(UITextField*)textField {

  //
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {

  textField == projectNameField   ? [projectAuthorField becomeFirstResponder] :
	textField == projectAuthorField ? [projectAuthorField resignFirstResponder] : nil;
                                  //[projectNameField becomeFirstResponder];
	return YES;
}

- (void) dealloc {

  [projectNameField release];
	[projectAuthorField release];
	[super dealloc];
}

@end
