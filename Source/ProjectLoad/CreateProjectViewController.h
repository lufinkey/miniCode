
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"

@interface CreateProjectViewController : NavigatedViewController <UITextFieldDelegate>
{
	UITextField* projectNameField;
	UITextField* projectAuthorField;
	BOOL closingAndLoading;
}

- (void)nextButtonSelected;
- (void)cancelCreateProject;
- (void)clearTextFields;
- (void)closeAndLoadTemplate:(NSString*)templateName category:(NSString*)category templatesRoot:(NSString*)templatesRoot;
- (void)textFieldDidChange:(UITextField*)textField;

@property (nonatomic, retain) UITextField* projectNameField;
@property (nonatomic, retain) UITextField* projectAuthorField;
@property (nonatomic) BOOL closingAndLoading;

@end
