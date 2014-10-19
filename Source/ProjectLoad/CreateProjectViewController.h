
#import <UIKit/UIKit.h>
#import "../Navigation/NavigatedViewController.h"

@interface CreateProjectViewController : NavigatedViewController
                                          <UITextFieldDelegate>

- (void) nextButtonSelected;
- (void) cancelCreateProject;
- (void) clearTextFields;
- (void) closeAndLoadTemplate:(NSString*)templateName
                     category:(NSString*)category;
- (void)   textFieldDidChange:(UITextField*)textField;

@property (nonatomic, retain) UITextField* projectNameField,
                                         * projectAuthorField;
@property (nonatomic) BOOL closingAndLoading;

@end
