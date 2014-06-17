
#include "../Util/NumberCodes.h"

#pragma once

void init_ObjCBridge(int argc, char*argv[]);

void Console_Log(const char*text);
void Console_Log(const int num);

typedef void (*SimpleMessageBoxDismissHandler)(void*,int);
void showSimpleMessageBox(const char*title, const char*message);
void showSimpleMessageBox(const char*title, const char*message, const char*buttonLabels[], int buttons, void*data,
						  SimpleMessageBoxDismissHandler willDismissHandler, SimpleMessageBoxDismissHandler didDismissHandler);

void concatPath(char*dest, const char*path1, const char*path2, unsigned int size);
void concatStrings(char*dest, const char*strs[], unsigned int sizeDest, unsigned int sizeStrs);
int compareStrings(const char* str, const char*cmp);


typedef void (*ThreadCallback)(void*);
void runCallbackInMainThread(ThreadCallback callback, void*data, bool wait);
void runCallbackInThread(ThreadCallback callback, void*data, bool wait);



//String conversions
void* StringToNSNumber(const char*str, NumberType type);
void* StringToAllocatedNSNumber(const char*str, NumberType type);
bool StringToBool(const char* str);
int StringToInt(const char* str);
long StringToLong(const char* str);
short StringToShort(const char* str);
float StringToFloat(const char* str);
double StringToDouble(const char* str);
long long StringToLongLong(const char* str);
unsigned int StringToUnsignedInt(const char* str);
unsigned char StringToUnsignedChar(const char* str);
unsigned long StringToUnsignedLong(const char* str);
unsigned short StringToUnsignedShort(const char* str);
unsigned long long StringToUnsignedLongLong(const char* str);


//NSLog
void NS_LogOutput(const char* output);


//id
void id_release(void*obj);



//NSAutoReleasePool
void* NSAutoReleasePool_alloc_init();



//NSString
const char* NSString_UTF8String(void*nsstring);
void* NSString_stringWithUTF8String(const char*string);
bool NSString_isEqualToObjectInArray(void*nsstring, void*nsarray);



//NSNumber
int NSNumber_intValue(void*nsnumber);
float NSNumber_floatValue(void*nsnumber);
double NSNumber_doubleValue(void*nsnumber);
bool NSNumber_boolValue(void*nsnumber);
void* NSNumber_numberWithInt(int num);
void* NSNumber_numberWithBool(bool val);
void* NSNumber_numberWithFloat(float num);
void* NSNumber_numberWithDouble(double num);



//NSArray
unsigned int NSArray_count(void*array);
void* NSArray_objectAtIndex(void*array, unsigned int index);
int NSArray_indexOfObject(void*array, void*object);



//NSMutableArray
void* NSMutableArray_alloc_init();
void NSMutableArray_addObject(void*array, void*object);
void NSMutableArray_removeObject(void*array, void*object);
void NSMutableArray_removeObjectAtIndex(void*array,unsigned int index);



//NSDictionary
void*NSDictionary_objectForKey(void*dict, const char*key);



//NSMutableDictionary
void*NSMutableDictionary_alloc_init();
void NSMutableDictionary_setObjectForKey(void*dict, void*object, const char*key);



//NSFileManager
void*NSFileManager_defaultManager();
bool NSFileManager_removeItemAtPath(void*fileManager, void* path, void**error);



//Date
typedef struct
{
	unsigned short year;
	unsigned char month;
	unsigned char day;
	
	unsigned char hour;
	unsigned char minute;
	unsigned char second;
	
	int gmtSecOffset;
} Date_struct;

Date_struct*Date_createInstance();
Date_struct*Date_createInstanceFromNSDate(void*nsdate);
void Date_destroyInstance(Date_struct*date);
void Date_getString(Date_struct*date, char str[26]);
void* Date_allocateNSDate(Date_struct*date);



// StringList
typedef struct
{
	void*data;
} StringList_struct;

StringList_struct StringList_create(); //must be destroyed
StringList_struct StringList_createWithData(void*data); //Data does not get copied. Only pointer gets copied (ie, don't call destroy)
StringList_struct*StringList_createInstance();
StringList_struct*StringList_createInstanceWithData(void*data); //Data gets copied (must be destroyed)
void StringList_destroy(StringList_struct list);
void StringList_destroyInstance(StringList_struct*list);

void*StringList_getData(StringList_struct*list);

int StringList_size(StringList_struct*list);
void StringList_add(StringList_struct*list, const char*str);
void StringList_add(StringList_struct*list, int index, const char*str);
void StringList_set(StringList_struct*list, int index, const char*str);
const char* StringList_get(StringList_struct*list, int index);
void StringList_remove(StringList_struct*list, int index);
void StringList_clear(StringList_struct*list, const char*str);



// StringTree
typedef struct
{
	void*data;
} StringTree_struct;

StringTree_struct StringTree_create();
StringTree_struct StringTree_createWithData(void*data); //Data does not get copied. Only pointer gets copied
StringTree_struct*StringTree_createInstance();
StringTree_struct*StringTree_createInstanceWithData(void*data); //Data gets copied (must be destroyed)
void StringTree_destroy(StringTree_struct tree);
void StringTree_destroyInstance(StringTree_struct*tree);

void*StringTree_getData(StringTree_struct*tree);

bool StringTree_addMember(StringTree_struct*tree, const char*member);
bool StringTree_renameMember(StringTree_struct*tree, const char*oldName, const char*newName);
bool StringTree_removeMember(StringTree_struct*tree, const char*member);
int StringTree_hasMember(StringTree_struct*tree, const char*member);
StringList_struct StringTree_getMembers(StringTree_struct*tree);

bool StringTree_addBranch(StringTree_struct*tree, const char*branch);
bool StringTree_addBranch(StringTree_struct*tree, const char*branch, StringTree_struct*heirarchy);
bool StringTree_renameBranch(StringTree_struct*tree, const char*oldName, const char*newName);
bool StringTree_removeBranch(StringTree_struct*tree, const char*branch);
int StringTree_hasBranch(StringTree_struct*tree, const char*branch);
StringTree_struct StringTree_getBranch(StringTree_struct*tree, const char*branch);
StringList_struct StringTree_getBranchNames(StringTree_struct*tree);

StringList_struct* StringTree_getPaths(StringTree_struct*tree);

void StringTree_merge(StringTree_struct *tree, StringTree_struct *heirarchy);
void StringTree_clear(StringTree_struct*tree);

//array of NSMutableDictionary
void*StringTree_convertFileTreeToNSMutableArray(StringTree_struct*tree);
StringTree_struct*StringTree_convertNSArrayToFileTree(void*array);



// ProjectData
typedef struct
{
	void*data;
} ProjectData_struct;



// ProjectSettings
typedef struct
{
	void*data;
} ProjectSettings_struct;

ProjectSettings_struct ProjectSettings_create();
ProjectSettings_struct ProjectSettings_createWithData(void*data);
ProjectSettings_struct* ProjectSettings_createInstance();
void ProjectSettings_destroy(ProjectSettings_struct projSettings);
void ProjectSettings_destroyInstance(ProjectSettings_struct* projSettings);

void* ProjectSettings_getData(ProjectSettings_struct* projSettings);

void ProjectSettings_setSDK(ProjectSettings_struct* projSettings, const char*sdk);
void ProjectSettings_addCompilerFlag(ProjectSettings_struct* projSettings, const char*flag);

const char* ProjectSettings_getSDK(ProjectSettings_struct* projSettings);
StringList_struct ProjectSettings_getCompilerFlags(ProjectSettings_struct* projSettings);

void* ProjectSettings_convertToNSMutableDictionary(ProjectSettings_struct*projSettings);
bool ProjectSettings_saveSettingsPlist(ProjectSettings_struct*projSettings, ProjectData_struct*projData);


// ProjectBuildInfo

typedef struct
{
	void*data;
} ProjectBuildInfo_struct;

ProjectBuildInfo_struct ProjectBuildInfo_create();
ProjectBuildInfo_struct ProjectBuildInfo_createWithData(void*data);
ProjectBuildInfo_struct* ProjectBuildInfo_createInstance();
void ProjectBuildInfo_destroy(ProjectBuildInfo_struct projBuildInfo);
void ProjectBuildInfo_destroyInstance(ProjectBuildInfo_struct* projBuildInfo);

void* ProjectBuildInfo_getData(ProjectBuildInfo_struct* projBuildInfo);

void ProjectBuildInfo_addEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* file);
void ProjectBuildInfo_renameEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* oldFile, const char* newFile);
void ProjectBuildInfo_removeEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* file);
bool ProjectBuildInfo_hasEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* file);

StringList_struct ProjectBuildInfo_getEditedFiles(ProjectBuildInfo_struct* projBuildInfo);

void* ProjectBuildInfo_convertToNSMutableDictionary(ProjectBuildInfo_struct*projBuildInfo);
bool ProjectBuildInfo_saveBuildInfoPlist(ProjectBuildInfo_struct*projBuildInfo, ProjectData_struct*projData);



// ProjectData

typedef enum
{
	PROJECTTYPE_APPLICATION,
	PROJECTTYPE_CONSOLE,
	PROJECTTYPE_DYNAMICLIBRARY,
	PROJECTTYPE_STATICLIBRARY
} ProjectType;

bool ProjectData_checkValidString(const char*str);

ProjectData_struct ProjectData_create(const char*name, const char*author);
ProjectData_struct ProjectData_createWithData(void*data); //Data does not get copied. Only pointer gets copied
ProjectData_struct*ProjectData_createInstance(const char*name, const char*author);
void ProjectData_destroy(ProjectData_struct projData);
void ProjectData_destroyInstance(ProjectData_struct*projData);

void*ProjectData_getData(ProjectData_struct*projData);

void ProjectData_setProjectType(ProjectData_struct*projData, ProjectType type);
void ProjectData_setName(ProjectData_struct*projData, const char*name);
void ProjectData_setAuthor(ProjectData_struct*projData, const char*author);
void ProjectData_setBundleIdentifier(ProjectData_struct*projData, const char*bundleID);
void ProjectData_setExecutableName(ProjectData_struct*projData, const char*execName);
void ProjectData_setProductName(ProjectData_struct*projData, const char*product);
void ProjectData_setFolderName(ProjectData_struct*projData, const char*folder);

void ProjectData_addFramework(ProjectData_struct*projData, const char*framework);

ProjectType ProjectData_getProjectType(ProjectData_struct*projData);
const char* ProjectData_getName(ProjectData_struct*projData);
const char* ProjectData_getAuthor(ProjectData_struct*projData);
const char* ProjectData_getBundleIdentifier(ProjectData_struct*projData);
const char* ProjectData_getExecutableName(ProjectData_struct*projData);
const char* ProjectData_getProductName(ProjectData_struct*projData);
const char* ProjectData_getFolderName(ProjectData_struct*projData);

StringList_struct ProjectData_getFrameworkList(ProjectData_struct*projData);
StringTree_struct ProjectData_getSourceFiles(ProjectData_struct*projData);
StringTree_struct ProjectData_getResourceFiles(ProjectData_struct*projData);
StringList_struct ProjectData_getIncludeDirs(ProjectData_struct*projData);
StringList_struct ProjectData_getLibDirs(ProjectData_struct*projData);

ProjectSettings_struct ProjectData_getProjectSettings(ProjectData_struct*projData);
ProjectBuildInfo_struct ProjectData_getProjectBuildInfo(ProjectData_struct*projData);

void ProjectData_removeFramework(ProjectData_struct*projData, int index);

void*ProjectData_convertToNSMutableDictionary(ProjectData_struct*projData);
bool ProjectData_saveProjectPlist(ProjectData_struct*projData);



// FileTools
const char*FileTools_getExecutableDirectory();
StringList_struct*FileTools_getFilenamesWithExtension(const char*directory, StringList_struct*extensions);
StringList_struct*FileTools_getFoldersInDirectory(const char*directory);
StringList_struct*FileTools_getFilesInDirectory(const char*directory);
StringTree_struct*FileTools_getStringTreeFromDirectory(const char*directory);
unsigned int FileTools_totalFilesInDirectory(const char*directory);
bool FileTools_directoryContainsFiles(const char*directory);
bool FileTools_loadFileIntoNSMutableString(const char*path, void*nsmutablestring);
bool FileTools_writeStringToFile(const char*path, const char*content);
bool FileTools_createFile(const char* path);
bool FileTools_createDirectory(const char*directory);
bool FileTools_copyFile(const char*src, const char*dst);
bool FileTools_copyFolder(const char*src, const char*dst);
bool FileTools_deleteFromFilesystem(const char*path);
bool FileTools_rename(const char*oldFile, const char*newFile);
bool FileTools_fileExists(const char*path);
bool FileTools_folderExists(const char*path);
unsigned long long int FileTools_fileSize(const char*path);
unsigned long long int FileTools_folderSize(const char*path);

