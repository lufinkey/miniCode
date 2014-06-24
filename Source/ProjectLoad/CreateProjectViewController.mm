
#import "CreateProjectViewController.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "ProjLoadTools.h"
#import "../iCodeAppDelegate.h"

@implementation CreateProjectViewController

@synthesize projectNameField;
@synthesize projectAuthorField;
@synthesize closingAndLoading;

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	[self setTitle:@"Create Project"];
	
	int centerX = self.view.frame.size.width/2;
	
	//create textinput boxes;
	int textInputWidth = 256;
	int textInputHeight = 36;
	projectNameField = [[UITextField alloc] initWithFrame:CGRectMake(centerX-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
	[projectNameField setPlaceholder:@"Name"];
	[projectNameField setFont:[UIFont fontWithName: @"Helvetica" size: 26.0f]];
	//[projectNameField setBackgroundColor:[UIColor whiteColor]];
	[projectNameField setBorderStyle:UITextBorderStyleRoundedRect];
	//[projectNameField becomeFirstResponder];
	[projectNameField setDelegate:self];
	[projectNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:projectNameField];
	
	projectAuthorField = [[UITextField alloc] initWithFrame:CGRectMake(centerX-(textInputWidth/2), 90, textInputWidth, textInputHeight)];
	[projectAuthorField setPlaceholder:@"Author"];
	[projectAuthorField setFont:[UIFont fontWithName: @"Helvetica" size: 26.0f]];
	//[projectNameField setBackgroundColor:[UIColor whiteColor]];
	[projectAuthorField setBorderStyle:UITextBorderStyleRoundedRect];
	[projectAuthorField setDelegate:self];
	[projectAuthorField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	[self.view addSubview:projectAuthorField];
	
	UIBarButtonItem*cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCreateProject)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
	[cancelButton release];
	
	UIBarButtonItem*nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonSelected)];
	[self.navigationItem setRightBarButtonItem:nextButton animated:YES];
	[nextButton release];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if(![projectAuthorField isFirstResponder] && UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
	{
		[projectNameField becomeFirstResponder];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if(![projectAuthorField isFirstResponder] && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		[projectNameField becomeFirstResponder];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		[projectNameField resignFirstResponder];
		[projectAuthorField resignFirstResponder];
		[self.view endEditing:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	if(orientation==UIInterfaceOrientationPortrait	|| orientation==UIInterfaceOrientationPortraitUpsideDown)
	{
		int textInputWidth = 256;
		int textInputHeight = 36;
		
		int centerX = (self.view.frame.size.width/2);
		[projectNameField setFrame:CGRectMake(centerX-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
		[projectAuthorField setFrame:CGRectMake(centerX-(textInputWidth/2), 90, textInputWidth, textInputHeight)];
	}
	else
	{
		int textInputWidth = 200;
		int textInputHeight = 36;
		
		int centerX = (self.view.frame.size.width/3) - 25;
		[projectNameField setFrame:CGRectMake(centerX-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
		centerX = ((self.view.frame.size.width/3)*2) + 25;
		[projectAuthorField setFrame:CGRectMake(centerX-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
	}
}

- (void)nextButtonSelected
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	const char*name = [projectNameField.text UTF8String];
	const char*author = [projectAuthorField.text UTF8String];
	
	bool nameValid = ProjectData_checkValidString(name);
	bool authorValid = ProjectData_checkValidString(author);
	
	if(nameValid && authorValid)
	{
		[self.navigationController pushViewController:appDelegate.selectTemplateCategoryController animated:YES];
	}
	else
	{
		NSString*message = nil;
		if(name==NULL || strlen(name)==0)
		{
			message = [[NSString alloc] initWithString:@"Please enter a valid name"];
		}
		else if(author==NULL || strlen(author)==0)
		{
			message = [[NSString alloc] initWithString:@"Please enter a valid author"];
		}
		else
		{
			message = [[NSString alloc] initWithString:@"Name and Author fields may only contain letters, numbers, underscores, periods, commas, or dashes"];
		}
		showSimpleMessageBox("", [message UTF8String]);
		[message release];
	}
}

- (void)cancelCreateProject
{
	[self clearTextFields];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)clearTextFields
{
	[projectNameField setText:@""];
	[projectAuthorField setText:@""];
}

- (void)closeAndLoadTemplate:(NSString*)templateName category:(NSString*)category
{
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	[projectNameField resignFirstResponder];
	[projectAuthorField resignFirstResponder];
	
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

- (void)willNavigateBackward:(UIViewController*)viewController;
{
	[self cancelCreateProject];
}

- (void)textFieldDidChange:(UITextField*)textField
{
	//
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
	if(textField == projectNameField)
	{
		[projectAuthorField becomeFirstResponder];
	}
	else if(textField == projectAuthorField)
	{
		//[projectNameField becomeFirstResponder];
		[projectAuthorField resignFirstResponder];
	}
	return YES;
}

- (void)dealloc
{
	[projectNameField release];
	[projectAuthorField release];
	[super dealloc];
}

@end
