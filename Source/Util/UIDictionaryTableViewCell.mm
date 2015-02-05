
#import "UIDictionaryTableViewCell.h"
#import "../DeprecationFix/DeprecationDefines.h"

DictionaryPropertyType getDictionaryPropertyTypeForObject(id object)
{
	if(object==nil)
	{
		return PROPERTYTYPE_UNKNOWN;
	}
	
	if([object isKindOfClass:[NSNumber class]])
	{
		return PROPERTYTYPE_NUMBER;
	}
	else if([object isKindOfClass:[NSString class]])
	{
		return PROPERTYTYPE_STRING;
	}
	else if([object isKindOfClass:[NSDate class]])
	{
		return PROPERTYTYPE_DATE;
	}
	else if([object isKindOfClass:[NSDictionary class]])
	{
		return PROPERTYTYPE_DICTIONARY;
	}
	else if([object isKindOfClass:[NSArray class]])
	{
		return PROPERTYTYPE_ARRAY;
	}
	return PROPERTYTYPE_UNKNOWN;
}

@interface UIDictionaryTableViewCell()
- (void)loadInputFieldFrameForState:(UITableViewCellStateMask)state;
- (void)loadBoolSwitchFrameForState:(UITableViewCellStateMask)state;
@property (nonatomic) UITableViewCellStateMask currentState;
@end


@implementation UIDictionaryTableViewCell

@synthesize delegate;
@synthesize type;
@synthesize valueLocked;
@synthesize numType;
@synthesize boolSwitch;
@synthesize inputField;
@synthesize currentState;

- (id)initForObject:(id)object label:(NSString*)label reuseIdentifier:(NSString*)reuseID
{
	currentState = UITableViewCellStateDefaultMask;
	valueLocked = NO;
	
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
	if(self==nil)
	{
		return nil;
	}
	
	delegate = nil;
	[self reloadForObject:object label:label];
	
	return self;
}

- (BOOL)reloadForObject:(id)object label:(NSString *)label
{
	[boolSwitch removeFromSuperview];
	[inputField removeFromSuperview];
	[boolSwitch release];
	[inputField release];
	boolSwitch = nil;
	inputField = nil;
	
	valueLocked = NO;
	
	type = getDictionaryPropertyTypeForObject(object);
	numType = NUMBERTYPE_UNKNOWN;
	
	[self.detailTextLabel setText:@""];
	
	switch(type)
	{
		default:
		case PROPERTYTYPE_UNKNOWN:
		break;
			
		case PROPERTYTYPE_NUMBER:
		{
			numType = getNumberTypeForNSNumber(object);
			
			if(numType==NUMBERTYPE_UNKNOWN)
			{
				[self release];
				return false;
			}
			else if(numType==NUMBERTYPE_BOOL)
			{
				boolSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
				[self loadBoolSwitchFrameForState:currentState];
				BOOL boolVal = [object boolValue];
				[boolSwitch setOn:boolVal animated:NO];
				[boolSwitch addTarget:self action:@selector(switchDidToggle) forControlEvents:UIControlEventValueChanged];
				[self addSubview:boolSwitch];
			}
			else
			{
				inputField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,0,0)];
				[self loadInputFieldFrameForState:currentState];
				[inputField setText:[object stringValue]];
				[inputField setTextAlignment:NSTextAlignmentRight];
				[inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
				[inputField setBorderStyle:UITextBorderStyleNone];
				[inputField setDelegate:self];
				[inputField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
				[self addSubview:inputField];
			}
		}
		break;
			
		case PROPERTYTYPE_STRING:
		{
			[self.detailTextLabel setTextColor:[UIColor blackColor]];
			[self.detailTextLabel setText:object];
		}
		break;
			
		case PROPERTYTYPE_DATE:
		{
			[self.detailTextLabel setTextColor:[UIColor blackColor]];
			[self.detailTextLabel setText:[object descriptionWithLocale:[NSLocale currentLocale]]];
		}
		break;
			
		case PROPERTYTYPE_DICTIONARY:
		{
			[self.detailTextLabel setTextColor:[UIColor blackColor]];
			[self.detailTextLabel setText:@"Dictionary"];
		}
		break;
			
		case PROPERTYTYPE_ARRAY:
		{
			[self.detailTextLabel setTextColor:[UIColor blackColor]];
			[self.detailTextLabel setText:@"Array"];
		}
		break;
	}
	
	[self.textLabel setText:label];
	
	return YES;
}

- (void)prepareForReuse
{
	currentState = UITableViewCellStateDefaultMask;
}

- (void)setValueLocked:(BOOL)locked
{
	if(locked)
	{
		if(boolSwitch!=nil)
		{
			[boolSwitch setUserInteractionEnabled:NO];
		}
		if(inputField!=nil)
		{
			[inputField setUserInteractionEnabled:NO];
		}
	}
	else
	{
		if(boolSwitch!=nil)
		{
			[boolSwitch setUserInteractionEnabled:YES];
		}
		if(inputField!=nil)
		{
			[inputField setUserInteractionEnabled:YES];
		}
	}
}

- (void)loadInputFieldFrameForState:(UITableViewCellStateMask)state
{
	if((state&UITableViewCellStateShowingDeleteConfirmationMask)!=0)
	{
		int height = self.frame.size.height;
		int width = self.frame.size.width/2;
		int offsetRight = 64;
		CGRect frame = CGRectMake(width-offsetRight,(self.frame.size.height/2)-(height/2), width-10,height);
		[inputField setFrame:frame];
	}
	else if((state&UITableViewCellStateShowingEditControlMask)!=0 && self.showsReorderControl)
	{
		int height = self.frame.size.height;
		int width = self.frame.size.width/2;
		int offsetRight = 30;
		CGRect frame = CGRectMake(width-offsetRight,(self.frame.size.height/2)-(height/2), width-10,height);
		[inputField setFrame:frame];
	}
	else
	{
		int height = self.frame.size.height;
		int width = self.frame.size.width/2;
		[inputField setFrame:CGRectMake(width,(self.frame.size.height/2)-(height/2), width-10,height)];
	}
}

- (void)loadBoolSwitchFrameForState:(UITableViewCellStateMask)state
{
	if((state&UITableViewCellStateShowingDeleteConfirmationMask)!=0)
	{
		int offsetRight = 64;
		CGRect frame = CGRectMake(self.frame.size.width-10-boolSwitch.frame.size.width-offsetRight, (self.frame.size.height/2)-(boolSwitch.frame.size.height/2), 0,0);
		[boolSwitch setFrame:frame];
	}
	else if((state&UITableViewCellStateShowingEditControlMask)!=0 && self.showsReorderControl)
	{
		int offsetRight = 30;
		CGRect frame = CGRectMake(self.frame.size.width-10-boolSwitch.frame.size.width-offsetRight, (self.frame.size.height/2)-(boolSwitch.frame.size.height/2), 0,0);
		[boolSwitch setFrame:frame];
	}
	else
	{
		[boolSwitch setFrame:CGRectMake(self.frame.size.width-10-boolSwitch.frame.size.width, (self.frame.size.height/2)-(boolSwitch.frame.size.height/2), 0,0)];
	}
}

- (void)switchDidToggle
{
	BOOL boolVal = boolSwitch.on;
	[delegate dictionaryTableViewCell:self didToggleSwitch:boolVal];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
	[super willTransitionToState:state];
	
	if(inputField!=nil)
	{
		[self loadInputFieldFrameForState:state];
	}
	else if(boolSwitch!=nil)
	{
		[self loadBoolSwitchFrameForState:state];
	}
	
	currentState = state;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
	BOOL hasDecimal = YES;
	if(numType==NUMBERTYPE_DOUBLE || numType==NUMBERTYPE_FLOAT)
	{
		hasDecimal = NO;
	}
	BOOL hasNegative = NO;
	if(numType==NUMBERTYPE_UNSIGNEDCHAR || numType==NUMBERTYPE_UNSIGNEDINT || numType==NUMBERTYPE_UNSIGNEDINTEGER ||
	   numType==NUMBERTYPE_UNSIGNEDLONG || numType==NUMBERTYPE_UNSIGNEDLONGLONG || numType==NUMBERTYPE_UNSIGNEDSHORT)
	{
		hasNegative = YES;
	}
	NSMutableString* txt = [[NSMutableString alloc] initWithString:textField.text];
	for(int i=0; i<[txt length]; i++)
	{
		char c = [txt UTF8String][i];
		if(!(c>='0' && c<='9'))
		{
			if(c=='.' && !hasDecimal)
			{
				hasDecimal = YES;
			}
			else if(c=='-' && !hasNegative && i==0)
			{
				hasNegative = YES;
			}
			else
			{
				NSRange range;
				range.location = i;
				range.length = 1;
				[txt deleteCharactersInRange:range];
				i--;
			}
		}
	}
	
	for(int i=0; i<[txt length]; i++)
	{
		char c = [txt UTF8String][i];
		if(c=='.')
		{
			if(i==0 && [txt length]>1)
			{
				[txt insertString:@"0" atIndex:0];
			}
			else if([txt length]==1)
			{
				[txt setString:@"0"];
			}
		}
		else if(c=='0')
		{
			if(i!=[txt length]-1)
			{
				if([txt UTF8String][i+1]!='.')
				{
					NSRange range;
					range.location = i;
					range.length = 1;
					[txt deleteCharactersInRange:range];
					i--;
				}
			}
		}
	}
	
	if([txt isEqual:@""])
	{
		[txt setString:@"0"];
	}
	
	[textField setText:txt];
	[txt release];
	
	[delegate dictionaryTableViewCell:self didFinishEditingLabel:textField.text];
}

- (void)dealloc
{
	[boolSwitch release];
	[inputField release];
	[super dealloc];
}

@end