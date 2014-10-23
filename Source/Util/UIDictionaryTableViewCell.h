
#import <UIKit/UIKit.h>
#import "NumberCodes.h"

typedef enum
{
	PROPERTYTYPE_UNKNOWN,
	PROPERTYTYPE_NUMBER,
	PROPERTYTYPE_STRING,
	PROPERTYTYPE_DATE,
	PROPERTYTYPE_DICTIONARY,
	PROPERTYTYPE_ARRAY
} DictionaryPropertyType;

DictionaryPropertyType getDictionaryPropertyTypeForObject(id object);

@class UIDictionaryTableViewCell;

@protocol UIDictionaryTableViewCellDelegate <NSObject>

@optional
- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didFinishEditingLabel:(NSString*)label;
- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didToggleSwitch:(BOOL)toggle;

@end

@interface UIDictionaryTableViewCell : UITableViewCell <UITextFieldDelegate>
{
	id delegate;
	
	BOOL valueLocked;
	
	@private
	DictionaryPropertyType type;
	NumberType numType;
	
	UISwitch* boolSwitch;
	UITextField* inputField;
	
	UITableViewCellStateMask currentState;
}

- (id)initForObject:(id)object label:(NSString*)label reuseIdentifier:(NSString*)reuseID;
- (BOOL)reloadForObject:(id)object label:(NSString*)label;

- (void)switchDidToggle;

@property (nonatomic, assign) id<UIDictionaryTableViewCellDelegate > delegate;
@property (nonatomic) BOOL valueLocked;
@property (nonatomic, readonly) DictionaryPropertyType type;
@property (nonatomic, readonly) NumberType numType;
@property (nonatomic, retain, readonly) UISwitch* boolSwitch;
@property (nonatomic, retain, readonly) UITextField* inputField;

@end