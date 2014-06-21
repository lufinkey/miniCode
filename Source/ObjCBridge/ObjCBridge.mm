
#include "ObjCBridge.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <stdlib.h>
#import "../Util/NumberCodes.h"

@interface SimpleMessageBoxDelegate : NSObject <UIAlertViewDelegate>
{
	void*data;
	SimpleMessageBoxDismissHandler willDismiss;
	SimpleMessageBoxDismissHandler didDismiss;
}

- (id)initWithData:(void*)dataPtr willDismissHandler:(SimpleMessageBoxDismissHandler)willDismissHandler didDismissHandler:(SimpleMessageBoxDismissHandler)didDismissHandler;

@end

@implementation SimpleMessageBoxDelegate

- (id)initWithData:(void*)dataPtr willDismissHandler:(SimpleMessageBoxDismissHandler)willDismissHandler didDismissHandler:(SimpleMessageBoxDismissHandler)didDismissHandler
{
	if([super init]==nil)
	{
		return nil;
	}
	
	data = dataPtr;
	willDismiss = willDismissHandler;
	didDismiss = didDismissHandler;
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(willDismiss!=NULL)
	{
		willDismiss(data, buttonIndex);
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(didDismiss!=NULL)
	{
		didDismiss(data, buttonIndex);
	}
	
	[self release];
}

@end



void NS_LogOutput(const char*text)
{
	NSLog(@"%@", [NSString stringWithUTF8String:text]);
}

void Console_Log(const int num)
{
	char buffer[20];
	snprintf(buffer, 20,"%i",num);
	Console_Log(buffer);
}

void showSimpleMessageBox(const char*title, const char*message, const char*buttonLabels[], int buttons, void*data,
						  SimpleMessageBoxDismissHandler willDismissHandler, SimpleMessageBoxDismissHandler didDismissHandler)
{
	SimpleMessageBoxDelegate* alertDelegate = [[SimpleMessageBoxDelegate alloc] initWithData:data
																				willDismissHandler:willDismissHandler
																				didDismissHandler:didDismissHandler];
	NSString* titleString = nil;
	if(title!=NULL)
	{
		titleString = [NSString stringWithUTF8String:title];
	}
	NSString* messageString = nil;
	if(message!=NULL)
	{
		messageString = [NSString stringWithUTF8String:message];
	}
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:titleString
													message:messageString
												   delegate:alertDelegate
										  cancelButtonTitle:nil
										  otherButtonTitles:nil];
	
	for(unsigned int i=0; i<buttons; i++)
	{
		[alert addButtonWithTitle:[NSString stringWithUTF8String:buttonLabels[i]]];
	}
	
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
	[alert autorelease];
	//Console_Log(title);
	//Console_Log(message);
}

void showSimpleMessageBox(const char*title, const char*message)
{
	NSString* titleString = nil;
	if(title!=NULL)
	{
		titleString = [NSString stringWithUTF8String:title];
	}
	NSString* messageString = nil;
	if(message!=NULL)
	{
		messageString = [NSString stringWithUTF8String:message];
	}
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:titleString
													message:messageString
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
	[alert autorelease];
	//Console_Log(title);
	//Console_Log(message);
}

@interface ThreadCallbackCaller : NSObject
{
	ThreadCallback callback;
	void*data;
}
- (id)initWithCallback:(ThreadCallback)callback data:(void*)data;
- (void)threadSelector;
@end

@implementation ThreadCallbackCaller
- (id)initWithCallback:(ThreadCallback)callbackFunc data:(void *)dat
{
	if([super init]==nil)
	{
		return nil;
	}
	callback = callbackFunc;
	data = dat;
	return self;
}

- (void)threadSelector
{
	callback(data);
	[self release];
}
@end


void runCallbackInMainThread(ThreadCallback callback, void*data, bool wait)
{
	ThreadCallbackCaller* caller = [[ThreadCallbackCaller alloc] initWithCallback:callback data:data];
	[caller performSelectorOnMainThread:@selector(threadSelector) withObject:nil waitUntilDone:wait];
}

void openURL(const char*url)
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithUTF8String:url]]];
}



// String conversions
void* StringToAllocatedNSNumber(const char*str, NumberType type)
{
	NSNumber* num = nil;
	switch(type)
	{
		default:
		case NUMBERTYPE_UNKNOWN:
		Console_Log("Unknown error occured in StringToAllocatedNSNumber(const char*)");
		return nil;
		
		case NUMBERTYPE_CHAR:
		num = [[NSNumber alloc] initWithChar:(char)StringToInt(str)];
		break;
		
		case NUMBERTYPE_DOUBLE:
		num = [[NSNumber alloc] initWithDouble:StringToDouble(str)];
		break;
		
		case NUMBERTYPE_FLOAT:
		num = [[NSNumber alloc] initWithFloat:StringToFloat(str)];
		break;
		
		case NUMBERTYPE_INT:
		num = [[NSNumber alloc] initWithInt:StringToInt(str)];
		break;
		
		case NUMBERTYPE_INTEGER:
		num = [[NSNumber alloc] initWithInteger:(NSInteger)StringToInt(str)];
		break;
		
		case NUMBERTYPE_LONG:
		num = [[NSNumber alloc] initWithLong:StringToLong(str)];
		break;
		
		case NUMBERTYPE_LONGLONG:
		num = [[NSNumber alloc] initWithLongLong:StringToLongLong(str)];
		break;
		
		case NUMBERTYPE_SHORT:
		num = [[NSNumber alloc] initWithShort:StringToShort(str)];
		break;
		
		case NUMBERTYPE_UNSIGNEDCHAR:
		num = [[NSNumber alloc] initWithUnsignedChar:StringToUnsignedChar(str)];
		break;
		
		case NUMBERTYPE_UNSIGNEDINT:
		num = [[NSNumber alloc] initWithUnsignedInt:StringToUnsignedInt(str)];
		break;
		
		case NUMBERTYPE_UNSIGNEDINTEGER:
		num = [[NSNumber alloc] initWithUnsignedInteger:(NSUInteger)StringToUnsignedInt(str)];
		break;
		
		case NUMBERTYPE_UNSIGNEDLONG:
		num = [[NSNumber alloc] initWithUnsignedLong:StringToUnsignedLong(str)];
		break;
		
		case NUMBERTYPE_UNSIGNEDLONGLONG:
		num = [[NSNumber alloc] initWithUnsignedLongLong:StringToUnsignedLongLong(str)];
		break;
		
		case NUMBERTYPE_UNSIGNEDSHORT:
		num = [[NSNumber alloc] initWithUnsignedShort:StringToUnsignedShort(str)];
		break;
	}
	
	return (void*)num;
}

void* StringToNSNumber(const char*str, NumberType type)
{
	return (void*)[((NSNumber*)StringToAllocatedNSNumber(str,type)) autorelease];
}



// Date
Date_struct*Date_createInstance()
{
	Date_struct*date = (Date_struct*)malloc(sizeof(Date_struct));
	
	date->year = 2000;
	date->month = 01;
	date->day = 01;
	
	date->hour = 00;
	date->minute = 00;
	date->second = 00;
	
	date->gmtSecOffset = 0;
	
	return date;
	
}

Date_struct*Date_createInstanceFromNSDate(void*nsdate)
{
	//string is 25 long
	Date_struct*date = (Date_struct*)malloc(sizeof(Date_struct));

	NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit |
																			 NSMonthCalendarUnit |
																			 NSDayCalendarUnit |
																			 NSHourCalendarUnit |
																			 NSMinuteCalendarUnit |
																			 NSSecondCalendarUnit)
																   fromDate:((NSDate*)nsdate)];
	
	date->year = (unsigned short)[components year];
	date->month = (unsigned char)[components month];
	date->day = (unsigned char)[components day];
	
	date->hour = (unsigned char)[components hour];
	date->minute = (unsigned char)[components minute];
	date->second = (unsigned char)[components second];
	
	date->gmtSecOffset = (int)[[NSTimeZone systemTimeZone] secondsFromGMT];
	
	return date;
}

void Date_destroyInstance(Date_struct*date)
{
	if(date!=NULL)
	{
		free(date);
	}
}

void Date_getString(Date_struct*date, char dateStr[26])
{
	if(date==NULL || dateStr==NULL)
	{
		return;
	}
	
	dateStr[25] = '\0';
	for(int i=0; i<25; i++)
	{
		dateStr[i] = '0';
	}
	int counter = 0;
	const char*cmpnt;
	
	NSNumber* num = nil;
	
	//year
	num = [[NSNumber alloc] initWithUnsignedShort:date->year];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=3; i>=0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
	dateStr[4] = '-';
	
	//month
	num = [[NSNumber alloc] initWithUnsignedChar:date->month];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=6; i>=5 && counter>0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
	dateStr[7]='-';
	
	//day
	num = [[NSNumber alloc] initWithUnsignedChar:date->day];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=9; i>=8 && counter>0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
	dateStr[10]=' ';
	
	//hour
	num = [[NSNumber alloc] initWithUnsignedChar:date->hour];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=12; i>=11 && counter>0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
	dateStr[13]=':';
	
	//minute
	num = [[NSNumber alloc] initWithUnsignedChar:date->minute];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=15; i>=14 && counter>0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
	dateStr[16]=':';
	
	//second
	num = [[NSNumber alloc] initWithUnsignedChar:date->second];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=18; i>=17 && counter>0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
	dateStr[19]=' ';
	
	//timezone
	if(date->gmtSecOffset<0)
	{
		dateStr[20]='-';
	}
	else
	{
		dateStr[20]='+';
	}
	
	//timezone hour
	unsigned char gmtHour = (unsigned char)abs((int)(date->gmtSecOffset/3600));
	num = [[NSNumber alloc] initWithUnsignedChar:gmtHour];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=22; i>=21 && counter>0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
	
	//timezone minute
	unsigned char gmtMinute = (unsigned char)(abs((int)(date->gmtSecOffset%3600))/60);
	num = [[NSNumber alloc] initWithUnsignedChar:gmtMinute];
	cmpnt = [[num stringValue] UTF8String];
	counter = strlen(cmpnt);
	for(int i=24; i>=23 && counter>0; i--)
	{
		counter--;
		dateStr[i] = cmpnt[counter];
	}
	[num release];
}

void* Date_allocateNSDate(Date_struct *date)
{
	if(date==NULL)
	{
		return NULL;
	}
	
	char dateStr[26];
	Date_getString(date, dateStr);
	NSString* str = [[NSString alloc] initWithUTF8String:dateStr];
	
	NSDate*nsdate = [[NSDate alloc] initWithString:str];
	
	[str release];
	return nsdate;
}



// id
void id_release(void*obj)
{
	[((NSObject*)obj) release];
}



// NSAutoReleasePool
void* NSAutoReleasePool_alloc_init()
{
	return (void*)[[NSAutoreleasePool alloc] init];
}



// NSString
const char* NSString_UTF8String(void*nsstring)
{
	NSString*str = (NSString*)nsstring;
	return [str UTF8String];
}

void* NSString_stringWithUTF8String(const char*string)
{
	return [NSString stringWithUTF8String:string];
}

bool NSString_isEqualToObjectInArray(void*nsstring, void*nsarray)
{
	NSString*str = (NSString*)nsstring;
	NSArray*arr = (NSArray*)nsarray;
	
	for(unsigned int i=0; i<[arr count]; i++)
	{
		if([str isEqual:[arr objectAtIndex:i]])
		{
			return true;
		}
	}
	return false;
}



// NSNumber
int NSNumber_intValue(void*nsnumber)
{
	return [((NSNumber*)nsnumber) intValue];
}

bool NSNumber_boolValue(void*nsnumber)
{
	return [((NSNumber*)nsnumber) boolValue];
}

float NSNumber_floatValue(void*nsnumber)
{
	return [((NSNumber*)nsnumber) floatValue];
}

double NSNumber_doubleValue(void*nsnumber)
{
	return [((NSNumber*)nsnumber) doubleValue];
}

void* NSNumber_numberWithInt(int num)
{
	return [NSNumber numberWithInt:num];
}

void*NSNumber_numberWithBool(bool val)
{
	return [NSNumber numberWithBool:val];
}

void* NSNumber_numberWithFloat(float num)
{
	return [NSNumber numberWithFloat:num];
}

void* NSNumber_numberWithDouble(double num)
{
	return [NSNumber numberWithDouble:num];
}



// NSArray
unsigned int NSArray_count(void*array)
{
	return [((NSArray*)array) count];
}

void* NSArray_objectAtIndex(void*array, unsigned int index)
{
	return [((NSArray*)array) objectAtIndex:index];
}

int NSArray_indexOfObject(void*array, void*object)
{
	return [((NSArray*)array) indexOfObject:((NSObject*)object)];
}



// NSMutableArray
void* NSMutableArray_alloc_init()
{
	return (void*)[[NSMutableArray alloc] init];
}

void NSMutableArray_addObject(void*array, void*object)
{
	[((NSMutableArray*)array) addObject:((NSObject*)object)];
}

void NSMutableArray_removeObject(void*array, void*object)
{
	[((NSMutableArray*)array) removeObject:((NSObject*)object)];
}

void NSMutableArray_removeObjectAtIndex(void*array,unsigned int index)
{
	[((NSMutableArray*)array) removeObjectAtIndex:index];
}



// NSDictionary
void* NSDictionary_objectForKey(void*dict, const char*key)
{
	return [((NSDictionary*)dict) objectForKey:[NSString stringWithUTF8String:key]];
}



// NSMutableDictionary
void*NSMutableDictionary_alloc_init()
{
	return (void*)[[NSMutableDictionary alloc] init];
}

void NSMutableDictionary_setObjectForKey(void*dict, void*object, const char*key)
{
	[((NSMutableDictionary*)dict) setObject:((NSObject*)object) forKey:[NSString stringWithUTF8String:key]];
}



// NSFileManager
void*NSFileManager_defaultManager()
{
	return (void*)[NSFileManager defaultManager];
}

bool NSFileManager_removeItemAtPath(void*fileManager, void* path, void**error)
{
	return [((NSFileManager*)fileManager) removeItemAtPath:(NSString*)path error:(NSError**)error];
}



// StringTree
void* StringTree_convertFileTreeToNSMutableArray(StringTree_struct*tree)
{
	NSMutableArray*array = [[NSMutableArray alloc] init];
	StringList_struct fileNames = StringTree_getMembers(tree);
	for(int i=0; i<StringList_size(&fileNames); i++)
	{
		NSMutableDictionary*dict = [[NSMutableDictionary alloc] init];
		NSString*fileName = [NSString stringWithUTF8String:StringList_get(&fileNames, i)];
		[dict setObject:fileName forKey:@"name"];
		NSNumber*isFolder = [NSNumber numberWithBool:NO];
		[dict setObject:isFolder forKey:@"folder"];
		[array addObject:dict];
		[dict release];
	}
	
	StringList_struct branchNames = StringTree_getBranchNames(tree);
	for(int i=0; i<StringList_size(&branchNames); i++)
	{
		NSMutableDictionary*dict = [[NSMutableDictionary alloc] init];
		NSString*folderName = [NSString stringWithUTF8String:StringList_get(&branchNames, i)];
		[dict setObject:folderName forKey:@"name"];
		NSNumber*isFolder = [NSNumber numberWithBool:YES];
		[dict setObject:isFolder forKey:@"folder"];
		StringTree_struct branch = StringTree_getBranch(tree, StringList_get(&branchNames, i));
		NSMutableArray*contents = (NSMutableArray*)StringTree_convertFileTreeToNSMutableArray(&branch);
		[dict setObject:contents forKey:@"contents"];
		[array addObject:dict];
		[dict release];
	}
	
	return [array autorelease];
}

StringTree_struct* StringTree_convertNSArrayToFileTree(void*array)
{
	NSArray* fileArray = (NSArray*)array;
	StringTree_struct* tree = StringTree_createInstance();
	for(int i=0; i<[fileArray count]; i++)
	{
		NSDictionary*dict = [fileArray objectAtIndex:i];
		const char*name = [(NSString*)[dict objectForKey:@"name"] UTF8String];
		NSNumber*isFolder = [dict objectForKey:@"folder"];
		if([isFolder boolValue]==YES)
		{
			NSArray*contents = [dict objectForKey:@"contents"];
			StringTree_struct*branch = StringTree_convertNSArrayToFileTree(contents);
			StringTree_addBranch(tree, name, branch);
			StringTree_destroyInstance(branch);
		}
		else
		{
			StringTree_addMember(tree, name);
		}
	}
	return tree;
}



// ProjectSettings
void*ProjectSettings_convertToNSMutableDictionary(ProjectSettings_struct*projSettings)
{
	if(projSettings==NULL)
	{
		return NULL;
	}
	
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	if(dict==nil)
	{
		return NULL;
	}
	
	[dict setObject:[NSString stringWithUTF8String:ProjectSettings_getSDK(projSettings)] forKey:@"SDK"];
	
	NSMutableArray* compilerFlagsArray = [[NSMutableArray alloc] init];
	StringList_struct compilerFlags = ProjectSettings_getCompilerFlags(projSettings);
	for(int i=0; i<StringList_size(&compilerFlags); i++)
	{
		[compilerFlagsArray addObject:[NSString stringWithUTF8String:StringList_get(&compilerFlags, i)]];
	}
	[dict setObject:compilerFlagsArray forKey:@"CompilerFlags"];
	[compilerFlagsArray release];
	
	NSMutableArray* disabledWarningsArray = [[NSMutableArray alloc] init];
	StringList_struct disabledWarnings = ProjectSettings_getCompilerFlags(projSettings);
	for(int i=0; i<StringList_size(&disabledWarnings); i++)
	{
		[disabledWarningsArray addObject:[NSString stringWithUTF8String:StringList_get(&disabledWarnings, i)]];
	}
	[dict setObject:disabledWarningsArray forKey:@"DisabledWarnings"];
	[disabledWarningsArray release];
	
	return (void*)[dict autorelease];
}



// ProjectBuildInfo
void* ProjectBuildInfo_convertToNSMutableDictionary(ProjectBuildInfo_struct*projBuildInfo)
{
	if(projBuildInfo==NULL)
	{
		return NULL;
	}
	
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	if(dict==nil)
	{
		return NULL;
	}
	
	StringList_struct editedFiles = ProjectBuildInfo_getEditedFiles(projBuildInfo);
	
	NSMutableArray* files = [[NSMutableArray alloc] init];
	for(int i=0; i<StringList_size(&editedFiles); i++)
	{
		NSString* file = [[NSString alloc] initWithUTF8String:StringList_get(&editedFiles, i)];
		[files addObject:file];
		[file release];
	}
	
	[dict setObject:files forKey:@"EditedFiles"];
	[files release];
	
	return (void*)[dict autorelease];
}



// ProjectData
void*ProjectData_convertToNSMutableDictionary(ProjectData_struct*projData)
{
	if(projData==NULL)
	{
		return nil;
	}
	
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	if(dict==nil)
	{
		return nil;
	}
	
	[dict setObject:[NSString stringWithUTF8String:ProjectData_getName(projData)] forKey:@"name"];
	[dict setObject:[NSString stringWithUTF8String:ProjectData_getAuthor(projData)] forKey:@"author"];
	[dict setObject:[NSString stringWithUTF8String:ProjectData_getBundleIdentifier(projData)] forKey:@"bundleIdentifier"];
	[dict setObject:[NSString stringWithUTF8String:ProjectData_getExecutableName(projData)] forKey:@"executable"];
	[dict setObject:[NSString stringWithUTF8String:ProjectData_getProductName(projData)] forKey:@"product"];
	
	NSDate*currentDate = [NSDate date];
	
	[dict setObject:currentDate forKey:@"LastAccess"];
	
	StringList_struct frameworks = ProjectData_getFrameworkList(projData);
	
	NSMutableArray*frameworkArray = [[NSMutableArray alloc] init];
	if(frameworkArray==nil)
	{
		[dict release];
		return nil;
	}
	
	for(unsigned int i=0; i<StringList_size(&frameworks); i++)
	{
		[frameworkArray addObject:[NSString stringWithUTF8String:StringList_get(&frameworks, i)]];
	}
	
	[dict setObject:frameworkArray forKey:@"frameworks"];
	[frameworkArray release];
	
	StringTree_struct sourceTree = ProjectData_getSourceFiles(projData);
	NSMutableArray*sourceArray = (NSMutableArray*)StringTree_convertFileTreeToNSMutableArray(&sourceTree);
	[dict setObject:sourceArray forKey:@"sourceFiles"];
	
	StringTree_struct resourceTree = ProjectData_getResourceFiles(projData);
	NSMutableArray*resourceArray = (NSMutableArray*)StringTree_convertFileTreeToNSMutableArray(&resourceTree);
	[dict setObject:resourceArray forKey:@"resources"];
	
	NSMutableDictionary*extDict = [[NSMutableDictionary alloc] init];
	if(extDict==nil)
	{
		[dict release];
		return nil;
	}
	
	NSMutableArray* includeArray = [[NSMutableArray alloc] init];
	if(includeArray==nil)
	{
		[dict release];
		[extDict release];
		return nil;
	}
	
	StringList_struct includes = ProjectData_getIncludeDirs(projData);
	for(unsigned int i=0; i<StringList_size(&includes); i++)
	{
		[includeArray addObject:[NSString stringWithUTF8String:StringList_get(&includes, i)]];
	}
	
	[extDict setObject:includeArray forKey:@"include"];
	[includeArray release];
	
	NSMutableArray* libArray = [[NSMutableArray alloc] init];
	if(libArray==nil)
	{
		[dict release];
		[extDict release];
		return nil;
	}
	
	StringList_struct libs = ProjectData_getLibDirs(projData);
	for(unsigned int i=0; i<StringList_size(&libs); i++)
	{
		[libArray addObject:[NSString stringWithUTF8String:StringList_get(&libs, i)]];
	}
	
	[extDict setObject:libArray forKey:@"lib"];
	[libArray release];
	
	[dict setObject:extDict forKey:@"external"];
	[extDict release];
	
	return (void*)[dict autorelease];
}



// FileTools
bool FileTools_loadFileIntoNSMutableString(const char*path, void*nsmutablestring)
{
	NSMutableString*str = (NSMutableString*)nsmutablestring;
	
	FILE*file = fopen(path, "r");
	if(file==NULL)
	{
		return false;
	}
	fseek(file, 0, SEEK_END);
	int total = ftell(file);
	fseek(file, 0, SEEK_SET);
	
	char*fileText = (char*)malloc(total+1);
	fileText[total] = '\0';
	
	fread(fileText, 1, total+1, file);
	NSString*nsstring = [[NSString alloc] initWithUTF8String:fileText];
	[str setString:nsstring];
	[nsstring release];
	
	fclose(file);
	free(fileText);
	return true;
}

bool FileTools_fileExists(const char*path)
{
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:path]];
	if(exists)
	{
		return true;
	}
	return false;
}

unsigned long long int FileTools_fileSize(const char*path)
{
	NSString* filePath = [[NSString alloc] initWithUTF8String:path];
	unsigned long long int fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
	[filePath release];
	return fileSize;
}

unsigned long long int FileTools_folderSize(const char*path)
{
	NSString* folderPath = [[NSString alloc] initWithUTF8String:path];
	NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
	NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
	NSString *fileName;
	unsigned long long int fileSize = 0;

	while (fileName = [filesEnumerator nextObject])
	{
		NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
		fileSize += [fileDictionary fileSize];
	}
	
	[folderPath release];
	return fileSize;
}



