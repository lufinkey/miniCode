
#import <Foundation/Foundation.h>
#import "FileEditorDelegate.h"
#import "../Navigation/NavigatedViewController.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../Util/UIDictionaryTableViewCell.h"

@class PlistViewController;
@class PlistStringViewController;
@class PlistDictionaryViewController;
@class PlistArrayViewController;
@class PlistViewerViewController;


@interface PlistViewController : NavigatedViewController <UITableViewDelegate, UITableViewDataSource>
{
	PlistViewerViewController*plistRoot;
}

+ (id)allocateViewControllerWithObject:(id)object;

- (id)getObject;
- (DictionaryPropertyType)getPropertyType;

@property (nonatomic, assign) PlistViewerViewController* plistRoot;

@end



@interface PlistStringViewController : PlistViewController <UITextViewDelegate>
{
	UITextView* stringBox;
}

- (id)initWithNSString:(NSString*)string;

- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;

@property (nonatomic, retain) UITextView* stringBox;

@end



@interface PlistDateViewController : PlistViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	Date_struct* date;
	
	UIPickerView* datePicker;
	UIPickerView* timePicker;
}

- (id)initWithNSDate:(NSDate*)date;

@property (nonatomic, retain) UIPickerView* datePicker;
@property (nonatomic, retain) UIPickerView* timePicker;

@end




@interface PlistDictionaryViewController : PlistViewController <UIDictionaryTableViewCellDelegate>
{
	UITableView* objects;
	
	NSArray* keys;
	NSMutableDictionary* dict;
	
	NSString* currentKey;
	
	UIBarButtonItem* editButton;
	UIBarButtonItem* doneButton;
	UIBarButtonItem* addButton;
}

- (id)initWithNSDictionary:(NSDictionary*)dictionary;
- (void)reloadWithNSDictionary:(NSDictionary*)dictionary;

- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;

- (void)editButtonSelected;
- (void)doneButtonSelected;
- (void)addButtonSelected;

@property (nonatomic, retain) UITableView* objects;
@property (nonatomic, retain) NSMutableDictionary* dict;
@property (nonatomic, retain) NSArray* keys;
@property (nonatomic, retain) NSString* currentKey;

@property (nonatomic, retain) UIBarButtonItem* editButton;
@property (nonatomic, retain) UIBarButtonItem* doneButton;
@property (nonatomic, retain) UIBarButtonItem* addButton;

@end



@interface PlistArrayViewController : PlistViewController <UIDictionaryTableViewCellDelegate>
{
	UITableView* objects;
	NSMutableArray* array;
	NSMutableArray* reuseIDs;
	NSMutableArray* availableIDs;
	NSInteger idCounter;
	NSInteger currentIndex;
	
	UIBarButtonItem* editButton;
	UIBarButtonItem* doneButton;
	UIBarButtonItem* addButton;
}

- (id)initWithNSArray:(NSArray*)array;

- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;

- (void)editButtonSelected;
- (void)doneButtonSelected;
- (void)addButtonSelected;

@property (nonatomic, retain) UITableView* objects;
@property (nonatomic, retain) NSMutableArray* array;
@property (nonatomic, retain) NSMutableArray* reuseIDs;
@property (nonatomic, retain) NSMutableArray* availableIDs;
@property (nonatomic) NSInteger currentIndex;

@property (nonatomic, retain) UIBarButtonItem* editButton;
@property (nonatomic, retain) UIBarButtonItem* doneButton;
@property (nonatomic, retain) UIBarButtonItem* addButton;

@end



@interface PlistBranchmakerViewController : PlistViewController <UITextFieldDelegate, UIActionSheetDelegate>
{
	PlistViewController* creator;
	
	id object;
	UITextField* keyField;
	UITableView* objectTypes;
	UITableViewCell* objectTypeButton;
	
	int selectedType;
}

- (id)initWithKeyfieldShown:(BOOL)showKeyfield isEditing:(BOOL)isEditing type:(int)type;

- (NSString*)stringForBranchtype:(int)type;
- (id)allocateObjectForBranchtype:(int)type;

- (void)cancelButtonSelected;
- (void)confirmButtonSelected;

@property (nonatomic, assign) PlistViewController* creator;
@property (nonatomic, retain) UITextField* keyField;
@property (nonatomic, retain) UITableView* objectTypes;
@property (nonatomic, retain) UITableViewCell* objectTypeButton;
@property (nonatomic) BOOL editing;
@property (nonatomic, readonly) int selectedType;

@end



@interface PlistViewerViewController : PlistDictionaryViewController <FileEditorDelegate>
{
	BOOL fileEdited;
	NSString* currentFilePath;
	
	@private
	BOOL fileLocked;
}

- (BOOL)saveCurrentFile;

@property (nonatomic) BOOL fileEdited;
@property (nonatomic, retain) NSString* currentFilePath;
@property (nonatomic, readonly) BOOL fileLocked;

@end


