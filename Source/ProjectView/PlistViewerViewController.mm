
#import "PlistViewerViewController.h"
#import "../ProjectLoad/ProjLoadTools.h"
#import <QuartzCore/QuartzCore.h>



//creation constants
static const int BRANCHTYPE_BOOLEAN = 0;
static const int BRANCHTYPE_INTEGER = 1;
static const int BRANCHTYPE_REAL = 2;
static const int BRANCHTYPE_STRING = 3;
static const int BRANCHTYPE_DATE = 4;
static const int BRANCHTYPE_DICTIONARY = 5;
static const int BRANCHTYPE_ARRAY = 6;

@interface UIView (PlistViewHelper)

- (id)findFirstResponder;
- (int)findHeightFromSuperview:(UIView*)superview;

@end

@implementation UIView (PlistViewerHelper)
- (id)findFirstResponder
{
    if (self.isFirstResponder)
	{
        return self;        
    }
    for (UIView *subView in self.subviews)
	{
        id responder = [subView findFirstResponder];
        if(responder!=nil)
		{
			return responder;
		}
    }
    return nil;
}

- (int)findHeightFromSuperview:(UIView*)superview
{
    if(self==superview)
	{
        return 0;        
    }
	else if(self.superview==superview)
	{
		return self.frame.origin.y;
	}
	else if(self.superview!=nil)
	{
		return self.frame.origin.y + [self.superview findHeightFromSuperview:superview];
	}
    return 0;
}
@end



#pragma mark -
#pragma mark PlistViewController



@implementation PlistViewController

@synthesize plistRoot;

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	return self;
}

+ (id)allocateViewControllerWithObject:(id)object
{
	DictionaryPropertyType type = getDictionaryPropertyTypeForObject(object);
	switch(type)
	{
		default:
		return nil;
		
		case PROPERTYTYPE_STRING:
		return [[PlistStringViewController alloc] initWithNSString:object];
		
		case PROPERTYTYPE_DATE:
		return [[PlistDateViewController alloc] initWithNSDate:object];
		
		case PROPERTYTYPE_DICTIONARY:
		return [[PlistDictionaryViewController alloc] initWithNSDictionary:object];
		
		case PROPERTYTYPE_ARRAY:
		return [[PlistArrayViewController alloc] initWithNSArray:object];
	}
}

- (id)getObject
{
	return nil;
}

- (DictionaryPropertyType)getPropertyType
{
	return PROPERTYTYPE_UNKNOWN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(plistRoot.fileLocked)
	{
		return NO;
	}
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	//
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end



#pragma mark -
#pragma mark PlistStringViewController



@implementation PlistStringViewController

@synthesize stringBox;

- (id)initWithNSString:(NSString*)string
{
	if([super init]==nil)
	{
		return nil;
	}
	
	stringBox = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[stringBox setText:string];
	[stringBox setEditable:YES];
	[stringBox setDelegate:self];
	[self.view addSubview:stringBox];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[stringBox setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	
	if(plistRoot.fileLocked)
	{
		[stringBox setEditable:NO];
	}
	else
	{
		[stringBox setEditable:YES];
		[stringBox becomeFirstResponder];
	}

}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[stringBox resignFirstResponder];
}

- (void)textViewDidChange:(UITextView*)textView
{
	[self.plistRoot setFileEdited:YES];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	[stringBox setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.height)];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	[stringBox setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (id)getObject
{
	return stringBox.text;
}

- (DictionaryPropertyType)getPropertyType
{
	return PROPERTYTYPE_STRING;
}

- (void)dealloc
{
	[stringBox release];
	[super dealloc];
}

@end



@implementation PlistDateViewController

@synthesize datePicker;
@synthesize timePicker;

- (id)initWithNSDate:(NSDate*)nsdate
{
	if([super init]==nil)
	{
		return nil;
	}
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	date = Date_createInstanceFromNSDate(nsdate);
	
	int height = ((self.view.frame.size.height)/2);
	datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
	[datePicker setDataSource:self];
	[datePicker setDelegate:self];
	[self.view addSubview:datePicker];
	[datePicker setShowsSelectionIndicator:YES];
	[datePicker selectRow:date->year inComponent:0 animated:NO];
	[datePicker selectRow:(date->month-1) inComponent:1 animated:NO];
	[datePicker selectRow:(date->day-1) inComponent:2 animated:NO];
	
	int hOffset = datePicker.frame.size.height;
	timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, hOffset, self.view.frame.size.width, self.view.frame.size.height - hOffset)];
	[timePicker setDataSource:self];
	[timePicker setDelegate:self];
	[self.view addSubview:timePicker];
	[timePicker setShowsSelectionIndicator:YES];
	[timePicker selectRow:date->hour inComponent:0 animated:NO];
	[timePicker selectRow:date->minute inComponent:1 animated:NO];
	[timePicker selectRow:date->second inComponent:2 animated:NO];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	int height = ((self.view.frame.size.height)/2);
	[datePicker setFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
	int hOffset = datePicker.frame.size.height;
	[timePicker setFrame:CGRectMake(0, hOffset, self.view.frame.size.width, self.view.frame.size.height - hOffset)];
	
	if(plistRoot.fileLocked)
	{
		[datePicker setUserInteractionEnabled:NO];
		[timePicker setUserInteractionEnabled:NO];
	}
	else
	{
		[datePicker setUserInteractionEnabled:YES];
		[timePicker setUserInteractionEnabled:YES];
	}
}

- (id)getObject
{
	NSDate*nsdate = (NSDate*)Date_allocateNSDate(date);
	return [nsdate autorelease];
}

- (DictionaryPropertyType)getPropertyType
{
	return PROPERTYTYPE_DATE;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	if(pickerView==datePicker)
	{
		return 3;
	}
	if(pickerView==timePicker)
	{
		return 3;
	}
	return 0;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if(pickerView==datePicker)
	{
		if(component==0)
		{
			return 3000;
		}
		else if(component==1)
		{
			return 12;
		}
		else if(component==2)
		{
			return 31;
		}
	}
	if(pickerView==timePicker)
	{
		if(component==0)
		{
			return 24;
		}
		else if(component==1)
		{
			return 60;
		}
		else if(component==2)
		{
			return 60;
		}
	}
	return 0;
}

- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component
{
	if(pickerView==datePicker)
	{
		if(component==0)
		{
			return pickerView.frame.size.width/5;
		}
		else if(component==1)
		{
			return pickerView.frame.size.width/5;
		}
		else if(component==2)
		{
			return pickerView.frame.size.width/6;
		}
	}
	else if(pickerView==timePicker)
	{
		return pickerView.frame.size.width/7;
	}
	return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if(pickerView==datePicker)
	{
		if(component==0)
		{
			NSNumber*num = [[NSNumber alloc] initWithInteger:row];
			NSString* str = [[NSString alloc] initWithString:[num stringValue]];
			[num release];
			return [str autorelease];
		}
		else if(component==1)
		{
			NSString* monthString = nil;
			
			switch(row)
			{
				case 0:
					monthString = @"Jan";
					break;
					
				case 1:
					monthString = @"Feb";
					break;
					
				case 2:
					monthString = @"Mar";
					break;
					
				case 3:
					monthString = @"Apr";
					break;
					
				case 4:
					monthString = @"May";
					break;
					
				case 5:
					monthString = @"June";
					break;
					
				case 6:
					monthString = @"July";
					break;
					
				case 7:
					monthString = @"Aug";
					break;
					
				case 8:
					monthString = @"Sept";
					break;
					
				case 9:
					monthString = @"Oct";
					break;
					
				case 10:
					monthString = @"Nov";
					break;
					
				case 11:
					monthString = @"Dec";
					break;
			}
			
			return [[[NSString alloc] initWithString:monthString] autorelease];
		}
		else if(component==2)
		{
			NSNumber*num = [[NSNumber alloc] initWithInteger:(row+1)];
			NSString* str = [[NSString alloc] initWithString:[num stringValue]];
			[num release];
			return [str autorelease];
		}
	}
	if(pickerView==timePicker)
	{
		if(component==0)
		{
			NSNumber*num = [[NSNumber alloc] initWithInteger:row];
			NSString* str = [[NSString alloc] initWithString:[num stringValue]];
			[num release];
			return [str autorelease];
		}
		else
		{
			NSNumber*num = [[NSNumber alloc] initWithInteger:row];
			NSMutableString* str = [[NSMutableString alloc] initWithString:[num stringValue]];
			[num release];
			[str insertString:@":" atIndex:0];
			return [str autorelease];
		}
	}
	return nil;
}

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[self.plistRoot setFileEdited:YES];
	
	if(pickerView==datePicker)
	{
		if(component==0)
		{
			date->year = row;
		}
		else if(component==1)
		{
			date->month = row+1;
		}
		else if(component==2)
		{
			date->day = row+1;
		}
	}
	else if(pickerView==timePicker)
	{
		if(component==0)
		{
			date->hour = row;
		}
		else if(component==1)
		{
			date->minute = row;
		}
		else if(component==2)
		{
			date->second = row;
		}
	}
}

- (void)dealloc
{
	Date_destroyInstance(date);
	[datePicker release];
	[timePicker release];
	[super dealloc];
}

@end




#pragma mark -
#pragma mark PlistDictionaryViewController



@implementation PlistDictionaryViewController

@synthesize dict;
@synthesize keys;
@synthesize objects;
@synthesize currentKey;

@synthesize editButton;
@synthesize doneButton;
@synthesize addButton;

- (id)initWithNSDictionary:(NSDictionary*)dictionary
{
	if([super init]==nil)
	{
		return nil;
	}
	
	if(dictionary!=nil)
	{
		dict = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
		self.keys = [dict allKeys];
	}
	else
	{
		dict = nil;
		keys = nil;
	}
	
	objects = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	[objects setDelegate:self];
	[objects setDataSource:self];
	[self.view addSubview:objects];
	
	editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonSelected)];
	[self.navigationItem setRightBarButtonItem:editButton];
	
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
	
	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonSelected)];
	
	self.currentKey = nil;
	[objects setAllowsSelectionDuringEditing:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[objects setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	
	if(plistRoot.fileLocked)
	{
		[self.navigationItem setRightBarButtonItem:nil animated:NO];
	}
	else
	{
		if(self.navigationItem.rightBarButtonItem==nil)
		{
			[self.navigationItem setRightBarButtonItem:editButton animated:NO];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)reloadWithNSDictionary:(NSDictionary*)dictionary
{
	[dict release];
	dict = nil;
	if(dictionary!=nil)
	{
		dict = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
		self.keys = [dict allKeys];
	}
	
	[objects reloadData];
}

- (void)editButtonSelected
{
	[objects setEditing:YES animated:YES];
	[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
	[self.navigationItem setLeftBarButtonItem:addButton animated:YES];
}

- (void)doneButtonSelected
{
	[objects setEditing:NO animated:YES];
	[self.navigationItem setRightBarButtonItem:editButton animated:YES];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)addButtonSelected
{
	PlistBranchmakerViewController* branchmakerViewController = [[PlistBranchmakerViewController alloc] initWithKeyfieldShown:YES isEditing:NO type:BRANCHTYPE_BOOLEAN];
	[branchmakerViewController setPlistRoot:self.plistRoot];
	[self.navigationController pushViewController:branchmakerViewController animated:YES];
	[branchmakerViewController release];
	[self doneButtonSelected];
}

- (void)willReturnFrom:(UIViewController*)viewController
{
	if([viewController isKindOfClass:[PlistBranchmakerViewController class]])
	{
		PlistBranchmakerViewController*viewCtrl = (PlistBranchmakerViewController*)viewController;
		if(viewCtrl.editing)
		{
			id object = [viewCtrl getObject];
			if(currentKey!=nil && object!=nil && !self.plistRoot.fileLocked)
			{
				[dict removeObjectForKey:currentKey];
				[dict setObject:object forKey:viewCtrl.keyField.text];
				self.keys = [dict allKeys];
				self.currentKey = nil;
				[objects reloadData];
				[self.plistRoot setFileEdited:YES];
			}
		}
		else
		{
			id object = [viewCtrl getObject];
			if(object!=nil && !self.plistRoot.fileLocked)
			{
				[dict setObject:object forKey:viewCtrl.keyField.text];
				self.keys = [dict allKeys];
				self.currentKey = nil;
				[objects reloadData];
				[self.plistRoot setFileEdited:YES];
			}
		}
	}
	else if([viewController isKindOfClass:[PlistViewController class]])
	{
		if(currentKey!=nil && !self.plistRoot.fileLocked)
		{
			PlistViewController*viewCtrl = (PlistViewController*)viewController;
			id object = [viewCtrl getObject];
			[dict setObject:object forKey:currentKey];
			self.keys = [dict allKeys];
			self.currentKey = nil;
			[objects reloadData];
		}
	}
}

- (id)getObject
{
	return dict;
}

- (DictionaryPropertyType)getPropertyType
{
	return PROPERTYTYPE_DICTIONARY;
}

- (void)dealloc
{
	[dict release];
	[objects release];
	[keys release];
	[currentKey release];
	[editButton release];
	[doneButton release];
	[addButton release];
	[super dealloc];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
	if(self.navigationController.topViewController==self)
	{
		CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		
		[objects setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.height)];
		
		UIView* firstResponder = [objects findFirstResponder];
		if(firstResponder!=nil)
		{
			int offset = [firstResponder findHeightFromSuperview:objects] + firstResponder.frame.size.height - keyboardSize.height;
			[objects setContentOffset:CGPointMake(0, offset) animated:YES];
		}
	}
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	[objects setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didFinishEditingLabel:(NSString*)label
{
	NSIndexPath* indexPath = [self.objects indexPathForCell:cell];
	const char*str = [label UTF8String];
	NSNumber* num = (NSNumber*)StringToAllocatedNSNumber(str, cell.numType);
	if(num==nil)
	{
		return;
	}
	NSString*key = [keys objectAtIndex:indexPath.row];
	[dict setObject:num forKey:key];
	[num release];
	[objects reloadData];
	
	[self.plistRoot setFileEdited:YES];
}

- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didToggleSwitch:(BOOL)toggle
{
	NSIndexPath* indexPath = [self.objects indexPathForCell:cell];
	NSNumber* num = [[NSNumber alloc] initWithBool:toggle];
	NSString* key = [keys objectAtIndex:indexPath.row];
	[dict setObject:num forKey:key];
	[num release];
	[objects reloadData];
	
	[self.plistRoot setFileEdited:YES];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if(dict==nil)
	{
		return 0;
	}
	return [dict count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* cellIdentifier = [keys objectAtIndex:indexPath.row];
	id object = [dict objectForKey:cellIdentifier];
	
	UIDictionaryTableViewCell* cell =(UIDictionaryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell==nil)
	{
		cell = [[[UIDictionaryTableViewCell alloc] initForObject:object label:cellIdentifier reuseIdentifier:cellIdentifier] autorelease];
	}
	else
	{
		[cell reloadForObject:object label:cellIdentifier];
	}
	
	[cell setDelegate:self];
	
	if(self.plistRoot.fileLocked)
	{
		[cell setValueLocked:YES];
	}
	else
	{
		[cell setValueLocked:NO];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		UIDictionaryTableViewCell*cell = (UIDictionaryTableViewCell*)[objects cellForRowAtIndexPath:indexPath];
		[cell.inputField resignFirstResponder];
		//[cell setCurrentState:UITableViewCellStateDefaultMask];
		
		[dict removeObjectForKey:[keys objectAtIndex:indexPath.row]];
		self.keys = [dict allKeys];
		
		NSArray*indexPaths = [NSArray arrayWithObject:indexPath];
		[objects deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
		[self.plistRoot setFileEdited:YES];
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[self.view endEditing:YES];
	
	NSString* key = [keys objectAtIndex:indexPath.row];
	if(tableView.editing)
	{
		self.currentKey = key;
		id object = [dict objectForKey:key];
		DictionaryPropertyType propertyType = getDictionaryPropertyTypeForObject(object);
		int type = 0;
		switch(propertyType)
		{
			case PROPERTYTYPE_UNKNOWN:
			case PROPERTYTYPE_NUMBER:
			{
				NumberType numberType = getNumberTypeForNSNumber(object);
				switch(numberType)
				{
					case NUMBERTYPE_UNKNOWN:
					case NUMBERTYPE_BOOL:
					type = BRANCHTYPE_BOOLEAN;
					break;
					
					case NUMBERTYPE_CHAR:
					case NUMBERTYPE_INT:
					case NUMBERTYPE_INTEGER:
					case NUMBERTYPE_LONG:
					case NUMBERTYPE_LONGLONG:
					case NUMBERTYPE_SHORT:
					case NUMBERTYPE_UNSIGNEDCHAR:
					case NUMBERTYPE_UNSIGNEDINT:
					case NUMBERTYPE_UNSIGNEDINTEGER:
					case NUMBERTYPE_UNSIGNEDLONG:
					case NUMBERTYPE_UNSIGNEDLONGLONG:
					case NUMBERTYPE_UNSIGNEDSHORT:
					type = BRANCHTYPE_INTEGER;
					break;
					
					case NUMBERTYPE_DOUBLE:
					case NUMBERTYPE_FLOAT:
					type = BRANCHTYPE_REAL;
					break;
				}
			}
			break;
			
			case PROPERTYTYPE_STRING:
			type = BRANCHTYPE_STRING;
			
			case PROPERTYTYPE_DATE:
			type = BRANCHTYPE_DATE;
			break;
			
			case PROPERTYTYPE_DICTIONARY:
			type = BRANCHTYPE_DICTIONARY;
			break;
			
			case PROPERTYTYPE_ARRAY:
			type = BRANCHTYPE_ARRAY;
			break;
		}
		PlistBranchmakerViewController* branchmaker = [[PlistBranchmakerViewController alloc] initWithKeyfieldShown:YES isEditing:YES type:type];
		[branchmaker setPlistRoot:self.plistRoot];
		[branchmaker.keyField setText:key];
		[self.navigationController pushViewController:branchmaker animated:YES];
		[branchmaker release];
	}
	else
	{
		id object = [dict objectForKey:key];
		PlistViewController* viewCtrl = [PlistViewController allocateViewControllerWithObject:object];
		if(viewCtrl!=nil)
		{
			self.currentKey = key;
			[self.navigationController pushViewController:viewCtrl animated:YES];
			[viewCtrl setPlistRoot:self.plistRoot];
			[viewCtrl release];
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end



#pragma mark -
#pragma mark PlistArrayViewController



@implementation PlistArrayViewController

@synthesize array;
@synthesize reuseIDs;
@synthesize availableIDs;
@synthesize objects;
@synthesize currentIndex;
@synthesize editButton;
@synthesize doneButton;
@synthesize addButton;

- (id)initWithNSArray:(NSArray*)arr
{
	if([super init]==nil)
	{
		return nil;
	}
	
	idCounter = 0;
	
	if(arr!=nil)
	{
		array = [[NSMutableArray alloc] initWithArray:arr];
		reuseIDs = [[NSMutableArray alloc] init];
		for(int i=0; i<[array count]; i++)
		{
			NSNumber*num = [[NSNumber alloc] initWithInt:i];
			[reuseIDs addObject:[num stringValue]];
			[num release];
		}
		idCounter = [array count];
	}
	else
	{
		array = [[NSMutableArray alloc] init];
		reuseIDs = [[NSMutableArray alloc] init];
	}
	
	availableIDs = [[NSMutableArray alloc] init];
	
	objects = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	[objects setDelegate:self];
	[objects setDataSource:self];
	[self.view addSubview:objects];
	
	editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonSelected)];
	[self.navigationItem setRightBarButtonItem:editButton];
	
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonSelected)];
	
	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonSelected)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	
	[objects setAllowsSelectionDuringEditing:NO];
	self.currentIndex = -1;
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[objects setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	
	if(self.plistRoot.fileLocked)
	{
		[self.navigationItem setRightBarButtonItem:nil animated:NO];
	}
	else
	{
		if(self.navigationItem.rightBarButtonItem==nil)
		{
			[self.navigationItem setRightBarButtonItem:editButton animated:NO];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)editButtonSelected
{
	[objects setEditing:YES animated:YES];
	[self.navigationItem setRightBarButtonItem:doneButton animated:YES];
	[self.navigationItem setLeftBarButtonItem:addButton animated:YES];
	
	for(int i=0; i<[array count]; i++)
	{
		UITableViewCell* cell = [objects cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		[cell setShowsReorderControl:YES];
	}
}

- (void)doneButtonSelected
{
	[objects setEditing:NO animated:YES];
	[self.navigationItem setRightBarButtonItem:editButton animated:YES];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	
	for(int i=0; i<[array count]; i++)
	{
		UITableViewCell* cell = [objects cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		[cell setShowsReorderControl:NO];
	}
}

- (void)addButtonSelected
{
	PlistBranchmakerViewController* branchmakerViewController = [[PlistBranchmakerViewController alloc] initWithKeyfieldShown:NO isEditing:NO type:BRANCHTYPE_BOOLEAN];
	[branchmakerViewController setPlistRoot:self.plistRoot];
	[self.navigationController pushViewController:branchmakerViewController animated:YES];
	[branchmakerViewController release];
	[self doneButtonSelected];
}

- (void)willReturnFrom:(UIViewController*)viewController
{
	if([viewController isKindOfClass:[PlistBranchmakerViewController class]])
	{
		PlistBranchmakerViewController*viewCtrl = (PlistBranchmakerViewController*)viewController;
		id object = [viewCtrl getObject];
		if(object!=nil && !self.plistRoot.fileLocked)
		{
			[array addObject:object];
			if([availableIDs count]>0)
			{
				[reuseIDs addObject:[availableIDs objectAtIndex:0]];
				[availableIDs removeObjectAtIndex:0];
			}
			else
			{
				NSNumber* reuseID = [[NSNumber alloc] initWithInt:idCounter];
				idCounter++;
				[reuseIDs addObject:[reuseID stringValue]];
				[reuseID release];
			}
			
			self.currentIndex = -1;
			[objects reloadData];
			[self.plistRoot setFileEdited:YES];
		}
	}
	else if([viewController isKindOfClass:[PlistViewController class]])
	{
		if(currentIndex!=-1 && !self.plistRoot.fileLocked)
		{
			PlistViewController*viewCtrl = (PlistViewController*)viewController;
			id object = [viewCtrl getObject];
			[array replaceObjectAtIndex:(NSUInteger)currentIndex withObject:object];
			currentIndex = -1;
			[objects reloadData];
		}
	}
}

- (id)getObject
{
	return array;
}

- (DictionaryPropertyType)getPropertyType
{
	return PROPERTYTYPE_ARRAY;
}

- (void)dealloc
{
	[array release];
	[reuseIDs release];
	[availableIDs release];
	[objects release];
	[editButton release];
	[addButton release];
	[doneButton release];
	[super dealloc];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
	if(self.navigationController.topViewController==self)
	{
		CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		
		[objects setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.height)];
		
		UIView* firstResponder = [objects findFirstResponder];
		if(firstResponder!=nil)
		{
			int offset = [firstResponder findHeightFromSuperview:objects] + firstResponder.frame.size.height - keyboardSize.height;
			[objects setContentOffset:CGPointMake(0, offset) animated:YES];
		}
	}
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	[objects setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didFinishEditingLabel:(NSString*)label
{
	NSIndexPath* indexPath = [self.objects indexPathForCell:cell];
	const char*str = [label UTF8String];
	NSNumber* num = (NSNumber*)StringToAllocatedNSNumber(str, cell.numType);
	if(num==nil)
	{
		return;
	}
	
	[array replaceObjectAtIndex:indexPath.row withObject:num];
	[num release];
	[objects reloadData];
	
	[self.plistRoot setFileEdited:YES];
}

- (void)dictionaryTableViewCell:(UIDictionaryTableViewCell*)cell didToggleSwitch:(BOOL)toggle
{
	NSIndexPath* indexPath = [self.objects indexPathForCell:cell];
	NSNumber* num = [[NSNumber alloc] initWithBool:toggle];
	
	[array replaceObjectAtIndex:indexPath.row withObject:num];
	[num release];
	[objects reloadData];
	
	[self.plistRoot setFileEdited:YES];
}

- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}

- (void)tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
	NSMutableArray*cells = [[NSMutableArray alloc] init];
	for(int i=0; i<[array count]; i++)
	{
		UITableViewCell* cell = [objects cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		[cells addObject:cell];
	}
	
	id moveObject = [array objectAtIndex:fromIndexPath.row];
	[moveObject retain];
	[array removeObjectAtIndex:fromIndexPath.row];
	[array insertObject:moveObject atIndex:toIndexPath.row];
	[moveObject release];
	
	UITableViewCell* moveCell = [cells objectAtIndex:fromIndexPath.row];
	[cells removeObjectAtIndex:fromIndexPath.row];
	[cells insertObject:moveCell atIndex:toIndexPath.row];
	
	NSString* moveID = [reuseIDs objectAtIndex:fromIndexPath.row];
	[moveID retain];
	[reuseIDs removeObjectAtIndex:fromIndexPath.row];
	[reuseIDs insertObject:moveID atIndex:toIndexPath.row];
	[moveID release];
	
	for(int i=0; i<[cells count]; i++)
	{
		NSMutableString* cellID = [[NSMutableString alloc] initWithString:@":"];
		NSNumber*num = [[NSNumber alloc] initWithInt:i];
		[cellID insertString:[num stringValue] atIndex:0];
		
		UIDictionaryTableViewCell*cell = [cells objectAtIndex:i];
		[cell reloadForObject:[array objectAtIndex:i] label:cellID];
		
		[num release];
		[cellID release];
	}
	
	[cells release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(array==nil)
	{
		return 0;
	}
	return [array count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSNumber*indexNumber = [[NSNumber alloc] initWithInt:indexPath.row];
	NSMutableString* cellID = [[NSMutableString alloc] initWithString:[indexNumber stringValue]];
	[indexNumber release];
	[cellID appendString:@":"];
	
	id object = [array objectAtIndex:indexPath.row];
	
	UIDictionaryTableViewCell* cell =(UIDictionaryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[reuseIDs objectAtIndex:indexPath.row]];
	if(cell==nil)
	{
		cell = [[[UIDictionaryTableViewCell alloc] initForObject:object label:cellID reuseIdentifier:[reuseIDs objectAtIndex:indexPath.row]] autorelease];
	}
	else
	{
		[cell reloadForObject:object label:cellID];
	}
	
	[cell setDelegate:self];
	[cellID release];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		UIDictionaryTableViewCell*deleteCell = (UIDictionaryTableViewCell*)[objects cellForRowAtIndexPath:indexPath];
		[deleteCell.inputField resignFirstResponder];
		//[deleteCell setCurrentState:UITableViewCellStateDefaultMask];
		
		[array removeObjectAtIndex:indexPath.row];
		NSString* reuseID = [reuseIDs objectAtIndex:indexPath.row];
		[availableIDs addObject:reuseID];
		[reuseIDs removeObjectAtIndex:indexPath.row];
		[objects deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		[self.plistRoot setFileEdited:YES];
		
		for(int i=0; i<[array count]; i++)
		{
			UIDictionaryTableViewCell* cell = (UIDictionaryTableViewCell*)[objects cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			
			NSNumber* num = [[NSNumber alloc] initWithInt:i];
			NSMutableString* str = [[NSMutableString alloc] initWithString:[num stringValue]];
			[str appendString:@":"];
			
			[cell.textLabel setText:str];
			
			[num release];
			[str release];
		}
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[self.view endEditing:YES];
	
	if(!tableView.editing)
	{
		id object = [array objectAtIndex:indexPath.row];
		PlistViewController* viewCtrl = [PlistViewController allocateViewControllerWithObject:object];
		if(viewCtrl!=nil)
		{
			self.currentIndex = indexPath.row;
			[self.navigationController pushViewController:viewCtrl animated:YES];
			[viewCtrl setPlistRoot:self.plistRoot];
			[viewCtrl release];
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end



#pragma mark -
#pragma mark PlistBranchmakerViewController



@implementation PlistBranchmakerViewController

@synthesize creator;
@synthesize keyField;
@synthesize objectTypes;
@synthesize objectTypeButton;
@synthesize editing;
@synthesize selectedType;

- (id)initWithKeyfieldShown:(BOOL)showKeyfield isEditing:(BOOL)isEditing type:(int)type
{
	if([super init]==nil)
	{
		return nil;
	}
	
	selectedType = type;
	editing = isEditing;
	object = nil;
	
	int textInputWidth = 256;
	int textInputHeight = 36;
	if(showKeyfield)
	{
		keyField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-(textInputWidth/2), 40, textInputWidth, textInputHeight)];
		[keyField setPlaceholder:@"Key"];
		[keyField setFont:[UIFont fontWithName: @"Helvetica" size: 26.0f]];
		[keyField setBorderStyle:UITextBorderStyleRoundedRect];
		[self.view addSubview:keyField];
		[keyField becomeFirstResponder];
	}
	else
	{
		keyField = nil;
	}
	
	objectTypes = [[UITableView alloc] initWithFrame:CGRectMake(0, textInputHeight+50, self.view.frame.size.width, 100) style:UITableViewStyleGrouped];
	[objectTypes setScrollEnabled:NO];
	[objectTypes setDelegate:self];
	[objectTypes setDataSource:self];
	[self.view addSubview:objectTypes];
	[objectTypes setBackgroundView:nil];
	
	objectTypeButton = nil;
	
	UIBarButtonItem*cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonSelected)];
	[self.navigationItem setLeftBarButtonItem:cancelButton];
	[cancelButton release];
	
	UIBarButtonItem*confirmButton = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonSelected)];
	[self.navigationItem setRightBarButtonItem:confirmButton];
	[confirmButton release];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	int textInputHeight = 0;
	if(keyField!=nil)
	{
		textInputHeight = keyField.frame.size.height;
		[keyField setFrame:CGRectMake((self.view.frame.size.width/2)-(keyField.frame.size.width/2), 40, keyField.frame.size.width, textInputHeight)];
	}
	else
	{
		textInputHeight = 36;
	}
	
	[objectTypes setFrame:CGRectMake(0, textInputHeight+50, self.view.frame.size.width, 100)];
}

- (void)cancelButtonSelected
{
	object = nil;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmButtonSelected
{
	if(keyField!=nil)
	{
		if([keyField.text isEqual:@""])
		{
			showSimpleMessageBox("Error", "Please input a key in the key field");
			return;
		}
		NSString*potentialKey = keyField.text;
		if(editing)
		{
			PlistDictionaryViewController*dictCreator = (PlistDictionaryViewController*)creator;
			if([potentialKey isEqual:dictCreator.currentKey])
			{
				[self.navigationController popViewControllerAnimated:YES];
			}
			else
			{
				NSArray*keys = [dictCreator.dict allKeys];
				for(unsigned int i=0; i<[keys count]; i++)
				{
					if([potentialKey isEqual:[keys objectAtIndex:i]])
					{
						NSMutableString* str = [[NSMutableString alloc] initWithUTF8String:"Cannot rename key to "];
						[str appendString:potentialKey];
						[str appendString:@". Duplicate key exists in Dictionary"];
						showSimpleMessageBox("Error", [str UTF8String]);
						[str release];
						return;
					}
				}
				dictCreator.currentKey = potentialKey;
				object = [self allocateObjectForBranchtype:selectedType];
				[self.navigationController popViewControllerAnimated:YES];
			}
		}
		else
		{
			PlistDictionaryViewController*dictCreator = (PlistDictionaryViewController*)creator;
			NSArray*keys = [dictCreator.dict allKeys];
			for(unsigned int i=0; i<[keys count]; i++)
			{
				if([potentialKey isEqual:[keys objectAtIndex:i]])
				{
					NSMutableString* str = [[NSMutableString alloc] initWithUTF8String:"Cannot create key named "];
					[str appendString:potentialKey];
					[str appendString:@". Duplicate key exists in Dictionary"];
					showSimpleMessageBox("Error", [str UTF8String]);
					[str release];
					return;
				}
			}
			dictCreator.currentKey = potentialKey;
			object = [self allocateObjectForBranchtype:selectedType];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	else
	{
		object = [self allocateObjectForBranchtype:selectedType];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (id)getObject
{
	return object;
}

- (DictionaryPropertyType)getPropertyType
{
	switch(selectedType)
	{
		case BRANCHTYPE_BOOLEAN:
		case BRANCHTYPE_INTEGER:
		case BRANCHTYPE_REAL:
		return PROPERTYTYPE_NUMBER;
		
		case BRANCHTYPE_STRING:
		return PROPERTYTYPE_STRING;
		
		case BRANCHTYPE_DATE:
		return PROPERTYTYPE_DATE;
		
		case BRANCHTYPE_DICTIONARY:
		return PROPERTYTYPE_DICTIONARY;
		
		case BRANCHTYPE_ARRAY:
		return PROPERTYTYPE_ARRAY;
	}
	return PROPERTYTYPE_UNKNOWN;
}

- (NSString*)stringForBranchtype:(int)type
{
	switch(type)
	{
		case BRANCHTYPE_BOOLEAN:
		return @"Boolean";
		
		case BRANCHTYPE_INTEGER:
		return @"Integer";
		
		case BRANCHTYPE_REAL:
		return @"Real";
		
		case BRANCHTYPE_STRING:
		return @"String";
		
		case BRANCHTYPE_DATE:
		return @"Date";
		
		case BRANCHTYPE_DICTIONARY:
		return @"Dictionary";
		
		case BRANCHTYPE_ARRAY:
		return @"Array";
	}
	return @"";
}

- (id)allocateObjectForBranchtype:(int)type
{
	switch(type)
	{
		case BRANCHTYPE_BOOLEAN:
		return [[NSNumber alloc] initWithBool:NO];
		
		case BRANCHTYPE_INTEGER:
		return [[NSNumber alloc] initWithInt:0];
		
		case BRANCHTYPE_REAL:
		return [[NSNumber alloc] initWithDouble:0];
		
		case BRANCHTYPE_STRING:
		return [[NSString alloc] initWithString:@""];
		
		case BRANCHTYPE_DATE:
		return [[NSDate alloc] init];
		
		case BRANCHTYPE_DICTIONARY:
		return [[NSDictionary alloc] init];
		
		case BRANCHTYPE_ARRAY:
		return [[NSArray alloc] initWithObjects:nil];
	}
	return nil;
}

- (void)dealloc
{
	[keyField release];
	[objectTypes release];
	[objectTypeButton release];
	[super dealloc];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[keyField resignFirstResponder];
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	[objectTypeButton release];
	objectTypeButton = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	[objectTypeButton.textLabel setText:[self stringForBranchtype:selectedType]];
	
	if(editing)
	{
		[objectTypeButton setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	return objectTypeButton;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(!editing)
	{
		UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Select Data Type" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		for(int i=0; i<=6; i++)
		{
			[sheet addButtonWithTitle:[self stringForBranchtype:i]];
		}
		[sheet setDelegate:self];
		[sheet showInView:tableView];
		[sheet release];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	selectedType = buttonIndex;
	[objectTypeButton.textLabel setText:[self stringForBranchtype:selectedType]];
}

@end



#pragma mark -
#pragma mark PlistViewerViewController



void DismissPlistViewAlertHandler(void*data, int buttonIndex)
{
	PlistViewerViewController* viewCtrl = (PlistViewerViewController*)data;
	
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
		
		viewCtrl.fileEdited = NO;
		[viewCtrl.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		// do nothing
	}
}

@implementation PlistViewerViewController

@synthesize fileEdited;
@synthesize fileLocked;
@synthesize currentFilePath;

- (id)init
{
	if([super initWithNSDictionary:nil]==nil)
	{
		return nil;
	}
	
	fileEdited = NO;
	currentFilePath = nil;
	[self setPlistRoot:self];
	
	return self;
}

- (BOOL)loadWithFile:(NSString*)filePath
{
	NSDictionary*properties = (NSDictionary*)ProjLoad_loadAllocatedPlist([filePath UTF8String]);
	
	self.fileLocked = NO;
	
	if(properties==nil)
	{
		return NO;
	}
	[self reloadWithNSDictionary:properties];
	[properties release];
	
	fileEdited = NO;
	self.currentFilePath = filePath;
	
	return YES;
}

- (void)setFileLocked:(BOOL)locked
{
	fileLocked = locked;
	if(locked)
	{
		if(self.navigationController!=nil && self.navigationController.visibleViewController==self)
		{
			[self.navigationItem setRightBarButtonItem:nil animated:YES];
		}
		else
		{
			[self.navigationItem setRightBarButtonItem:nil animated:NO];
		}
	}
}

- (BOOL)saveCurrentFile
{
	NSDictionary*plist = [self getObject];
	BOOL success = NO;
	if(plist!=nil)
	{
		success = [plist writeToFile:currentFilePath atomically:YES];
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

- (BOOL)shouldNavigateBackward
{
	if(fileEdited)
	{
		const char*buttonLabels[3] = {"Yes", "No", "Cancel"};
		showSimpleMessageBox("Save", "Would you like to save changes made to this file?", buttonLabels, 3, self, &DismissPlistViewAlertHandler, NULL);
		return NO;
	}
	return YES;
}

- (void)didNavigateBackwardTo:(UIViewController*)viewController
{
	[super didNavigateBackwardTo:viewController];
	
	self.currentFilePath = nil;
	[self reloadWithNSDictionary:nil];
}

- (void)dealloc
{
	[currentFilePath release];
	[super dealloc];
}

@end

