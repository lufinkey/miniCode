
#include "ObjCBridge.h"
#include "../Util/ArrayList.h"
#include "../Util/String.h"
#include "../ProjectData/ProjectData.h"
#include "../ProjectData/ProjectSettings.h"
#include "../Util/StringTree.h"
#include "../Util/Console.h"
#include "../Util/FileTools.h"
#include "../Util/Thread.h"
#include "../ProjectLoad/ProjLoadTools.h"

static String executable_directory = "";

void init_ObjCBridge(int argc, char*argv[])
{
	executable_directory = argv[0];
	executable_directory = executable_directory.substring(0, executable_directory.lastIndexOf('/'));
	
	ProjLoad_createDefaultFolders();
}

void concatPath(char*dest, const char*path1, const char*path2, unsigned int size)
{
	String fullPath = (String)path1 + '/' + path2;
	dest[size-1] = '\0';
	if(fullPath.length()<(size-1))
	{
		dest[fullPath.length()] = '\0';
	}
	for(int i=0; (i<(size-1))&&(i<fullPath.length()); i++)
	{
		dest[i] = fullPath.charAt(i);
	}
}

void concatStrings(char*dest, const char*strs[], unsigned int sizeDest, unsigned int sizeStrs)
{
	String str = "";
	
	for(int i=0; i<sizeStrs; i++)
	{
		str += strs[i];
	}
	
	dest[sizeDest-1] = '\0';
	if(str.length()<(sizeDest-1))
	{
		dest[str.length()] = '\0';
	}
	for(int i=0; (i<(sizeDest-1))&&(i<str.length()); i++)
	{
		dest[i] = str.charAt(i);
	}
}

int compareStrings(const char* str, const char*cmp)
{
	if(str==NULL)
	{
		return -1;
	}
	if(cmp==NULL)
	{
		return 1;
	}
	
	String str1 = str;
	return str1.compare(cmp);
}

class ThreadCallbackCaller : public Thread
{
private:
	ThreadCallback callback;
	void*data;
	bool selfDestruct;
public:
	ThreadCallbackCaller(ThreadCallback callback, void*data, bool selfDestruct)
	{
		this->callback = callback;
		this->data = data;
		this->selfDestruct = selfDestruct;
	}
	
	virtual ~ThreadCallbackCaller()
	{
		//
	}
	
	virtual void run()
	{
		callback(data);
	}
	
	virtual void finish()
	{
		if(selfDestruct)
		{
			delete this;
		}
	}
};

void runCallbackInThread(ThreadCallback callback, void*data, bool wait)
{
	if(callback!=NULL)
	{
		if(wait)
		{
			ThreadCallbackCaller* caller = new ThreadCallbackCaller(callback, data, false);
			caller->start();
			caller->join();
			delete caller;
		}
		else
		{
			ThreadCallbackCaller* caller = new ThreadCallbackCaller(callback, data, true);
			caller->start();
		}
	}
}



void Console_Log(const char*text)
{
	Console::WriteLine(text);
}



//String conversions
bool StringToBool(const char* str)
{
	return String::asBool(str);
}
int StringToInt(const char* str)
{
	return String::asInt(str);
}
long StringToLong(const char* str)
{
	return String::asLong(str);
}
short StringToShort(const char* str)
{
	return String::asShort(str);
}
float StringToFloat(const char* str)
{
	return String::asFloat(str);
}
double StringToDouble(const char* str)
{
	return String::asDouble(str);
}
long long StringToLongLong(const char* str)
{
	return String::asLongLong(str);
}
unsigned int StringToUnsignedInt(const char* str)
{
	return String::asUInt(str);
}
unsigned char StringToUnsignedChar(const char* str)
{
	return String::asUChar(str);
}
unsigned long StringToUnsignedLong(const char* str)
{
	return String::asULong(str);
}
unsigned short StringToUnsignedShort(const char* str)
{
	return String::asUShort(str);
}
unsigned long long StringToUnsignedLongLong(const char* str)
{
	return String::asULongLong(str);
}



//StringList

StringList_struct StringList_create()
{
	StringList_struct sl;
	sl.data = new ArrayList<String>();
	return sl;
}

StringList_struct StringList_createWithData(void*data)
{
	StringList_struct sl;
	sl.data = data;
	return sl;
}

StringList_struct* StringList_createInstance()
{
	StringList_struct*sl = new StringList_struct();
	sl->data = new ArrayList<String>();
	return sl;
}

StringList_struct* StringList_createInstanceWithData(void*data)
{
	StringList_struct*sl = new StringList_struct();
	sl->data = new ArrayList<String>(*((ArrayList<String>*)data));
	return sl;
}

void StringList_destroy(StringList_struct list)
{
	if(list.data!=NULL)
	{
		delete ((ArrayList<String>*)list.data);
		list.data = NULL;
	}
}

void StringList_destroyInstance(StringList_struct*list)
{
	if(list!=NULL)
	{
		if(list->data!=NULL)
		{
			delete ((ArrayList<String>*)list->data);
		}
		delete list;
	}
}

void*StringList_getData(StringList_struct*list)
{
	if(list!=NULL)
	{
		return list->data;
	}
	return NULL;
}

int StringList_size(StringList_struct*list)
{
	if(list!=NULL && list->data!=NULL)
	{
		return ((ArrayList<String>*)list->data)->size();
	}
	return 0;
}

void StringList_add(StringList_struct*list, const char*str)
{
	if(list!=NULL && list->data!=NULL)
	{
		((ArrayList<String>*)list->data)->add(str);
	}
}

void StringList_add(StringList_struct*list, int index, const char*str)
{
	if(list!=NULL && list->data!=NULL)
	{
		((ArrayList<String>*)list->data)->add(index, str);
	}
}

void StringList_set(StringList_struct*list, int index, const char*str)
{
	if(list!=NULL && list->data!=NULL)
	{
		((ArrayList<String>*)list->data)->set(index, str);
	}
}

const char* StringList_get(StringList_struct*list, int index)
{
	if(list!=NULL && list->data!=NULL)
	{
		return (const char*)(((ArrayList<String>*)list->data)->get(index));
	}
	return NULL;
}

void StringList_remove(StringList_struct*list, int index)
{
	if(list!=NULL && list->data!=NULL)
	{
		((ArrayList<String>*)list->data)->remove(index);
	}
}

void StringList_clear(StringList_struct*list)
{
	if(list!=NULL && list->data!=NULL)
	{
		((ArrayList<String>*)list->data)->clear();
	}
}



//StringTree

StringTree_struct StringTree_create()
{
	StringTree_struct st;
	st.data = new StringTree();
	return st;
}

StringTree_struct StringTree_createWithData(void*data)
{
	StringTree_struct st;
	st.data = data;
	return st;
}

StringTree_struct*StringTree_createInstance()
{
	StringTree_struct*st = new StringTree_struct();
	st->data = new StringTree();
	return st;
}

StringTree_struct* StringTree_createInstanceWithData(void*data)
{
	StringTree_struct*st = new StringTree_struct();
	st->data = new StringTree(*((StringTree*)data));
	return st;
}

void StringTree_destroy(StringTree_struct tree)
{
	if(tree.data!=NULL)
	{
		delete ((StringTree*)tree.data);
	}
}

void StringTree_destroyInstance(StringTree_struct*tree)
{
	if(tree!=NULL)
	{
		if(tree->data!=NULL)
		{
			delete ((StringTree*)tree->data);
		}
		delete tree;
	}
}

void*StringTree_getData(StringTree_struct*tree)
{
	if(tree!=NULL)
	{
		return ((StringTree*)tree->data);
	}
	return NULL;
}

bool StringTree_addMember(StringTree_struct*tree, const char*member)
{
	if(tree!=NULL && tree->data!=NULL && member!=NULL)
	{
		return ((StringTree*)tree->data)->addMember(member);
	}
	return false;
}

bool StringTree_renameMember(StringTree_struct*tree, const char*oldName, const char*newName)
{
	if(tree!=NULL && tree->data!=NULL && oldName!=NULL && newName!=NULL)
	{
		return ((StringTree*)tree->data)->renameMember(oldName, newName);
	}
	return false;
}

bool StringTree_removeMember(StringTree_struct*tree, const char*member)
{
	if(tree!=NULL && tree->data!=NULL && member!=NULL)
	{
		return ((StringTree*)tree->data)->removeMember(member);
	}
	return false;
}

int StringTree_hasMember(StringTree_struct*tree, const char*member)
{
	if(tree!=NULL && tree->data!=NULL && member!=NULL)
	{
		return ((StringTree*)tree->data)->hasMember(member);
	}
	return -1;
}

StringList_struct StringTree_getMembers(StringTree_struct*tree)
{
	if(tree!=NULL && tree->data!=NULL)
	{
		return StringList_createWithData(&(((StringTree*)tree->data)->getMembers()));
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

bool StringTree_addBranch(StringTree_struct*tree, const char*branch)
{
	if(tree!=NULL && tree->data!=NULL && branch!=NULL)
	{
		return ((StringTree*)tree->data)->addBranch(branch);
	}
	return false;
}

bool StringTree_addBranch(StringTree_struct*tree, const char*branch, StringTree_struct*heirarchy)
{
	if(tree!=NULL && tree->data!=NULL && branch!=NULL)
	{
		if(heirarchy!=NULL && heirarchy->data!=NULL)
		{
			return ((StringTree*)tree->data)->addBranch(branch, *((StringTree*)heirarchy->data));
		}
		else
		{
			return ((StringTree*)tree->data)->addBranch(branch);
		}
	}
	return false;
}

bool StringTree_renameBranch(StringTree_struct*tree, const char*oldName, const char*newName)
{
	if(tree!=NULL && tree->data!=NULL && oldName!=NULL && newName!=NULL)
	{
		return ((StringTree*)tree->data)->renameBranch(oldName, newName);
	}
	return false;
}

bool StringTree_removeBranch(StringTree_struct*tree, const char*branch)
{
	if(tree!=NULL && tree->data!=NULL && branch!=NULL)
	{
		return ((StringTree*)tree->data)->removeBranch(branch);
	}
	return false;
}

int StringTree_hasBranch(StringTree_struct*tree, const char*branch)
{
	if(tree!=NULL && tree->data!=NULL && branch!=NULL)
	{
		return ((StringTree*)tree->data)->hasBranch(branch);
	}
	return -1;
}

StringTree_struct StringTree_getBranch(StringTree_struct*tree, const char*branch)
{
	if(tree!=NULL && tree->data!=NULL && branch!=NULL)
	{
		return StringTree_createWithData(((StringTree*)tree->data)->getBranch(branch));
	}
	StringTree_struct st;
	st.data = NULL;
	return st;
}

StringList_struct StringTree_getBranchNames(StringTree_struct*tree)
{
	if(tree!=NULL && tree->data!=NULL)
	{
		return StringList_createWithData(&(((StringTree*)tree->data)->getBranchNames()));
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

StringList_struct* StringTree_getPaths(StringTree_struct*tree)
{
	if(tree!=NULL && tree->data!=NULL)
	{
		ArrayList<String> paths = ((StringTree*)tree->data)->getPaths();
		return StringList_createInstanceWithData(&paths);
	}
	return NULL;
}

void StringTree_merge(StringTree_struct*tree, StringTree_struct*heirarchy)
{
	if(tree!=NULL && tree->data!=NULL)
	{
		if(heirarchy!=NULL && heirarchy->data!=NULL)
		{
			((StringTree*)tree->data)->merge(*((StringTree*)heirarchy->data));
		}
	}
}

void StringTree_clear(StringTree_struct*tree)
{
	if(tree!=NULL && tree->data!=NULL)
	{
		((StringTree*)tree->data)->clear();
	}
}



// ProjectSettings

ProjectSettings_struct ProjectSettings_create()
{
	ProjectSettings_struct projSettings;
	projSettings.data = new ProjectSettings();
	return projSettings;
}

ProjectSettings_struct ProjectSettings_createWithData(void*data)
{
	ProjectSettings_struct projSettings;
	projSettings.data = data;
	return projSettings;
}

ProjectSettings_struct* ProjectSettings_createInstance()
{
	ProjectSettings_struct* projSettings = new ProjectSettings_struct();
	projSettings->data = new ProjectSettings();
	return projSettings;
}

void ProjectSettings_destroy(ProjectSettings_struct projSettings)
{
	if(projSettings.data!=NULL)
	{
		delete ((ProjectSettings*)projSettings.data);
		projSettings.data = NULL;
	}
}

void ProjectSettings_destroyInstance(ProjectSettings_struct* projSettings)
{
	if(projSettings!=NULL)
	{
		if(projSettings->data!=NULL)
		{
			delete ((ProjectSettings*)projSettings->data);
			projSettings->data = NULL;
		}
		delete projSettings;
	}
}

void* ProjectSettings_getData(ProjectSettings_struct* projSettings)
{
	if(projSettings!=NULL && projSettings->data!=NULL)
	{
		return projSettings->data;
	}
	return NULL;
}

void ProjectSettings_setSDK(ProjectSettings_struct* projSettings, const char*sdk)
{
	if(projSettings!=NULL && projSettings->data!=NULL && sdk!=NULL)
	{
		((ProjectSettings*)projSettings->data)->setSDK(sdk);
	}
}

void ProjectSettings_addAssemblerFlag(ProjectSettings_struct* projSettings, const char*flag)
{
	if(projSettings!=NULL && projSettings->data!=NULL && flag!=NULL)
	{
		((ProjectSettings*)projSettings->data)->addAssemblerFlag(flag);
	}
}

void ProjectSettings_addCompilerFlag(ProjectSettings_struct* projSettings, const char*flag)
{
	if(projSettings!=NULL && projSettings->data!=NULL && flag!=NULL)
	{
		((ProjectSettings*)projSettings->data)->addCompilerFlag(flag);
	}
}

void ProjectSettings_addDisabledWarning(ProjectSettings_struct* projSettings, const char*warning)
{
	if(projSettings!=NULL && projSettings->data!=NULL && warning!=NULL)
	{
		((ProjectSettings*)projSettings->data)->addDisabledWarning(warning);
	}
}

const char* ProjectSettings_getSDK(ProjectSettings_struct* projSettings)
{
	if(projSettings!=NULL && projSettings->data!=NULL)
	{
		return ((ProjectSettings*)projSettings->data)->getSDK();
	}
	return NULL;
}

StringList_struct ProjectSettings_getAssemblerFlags(ProjectSettings_struct* projSettings)
{
	if(projSettings!=NULL && projSettings->data!=NULL)
	{
		return StringList_createWithData(&((ProjectSettings*)projSettings->data)->getAssemblerFlags());
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

StringList_struct ProjectSettings_getCompilerFlags(ProjectSettings_struct* projSettings)
{
	if(projSettings!=NULL && projSettings->data!=NULL)
	{
		return StringList_createWithData(&((ProjectSettings*)projSettings->data)->getCompilerFlags());
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

StringList_struct ProjectSettings_getDisabledWarnings(ProjectSettings_struct* projSettings)
{
	if(projSettings!=NULL && projSettings->data!=NULL)
	{
		return StringList_createWithData(&((ProjectSettings*)projSettings->data)->getDisabledWarnings());
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

bool ProjectSettings_saveSettingsPlist(ProjectSettings_struct*projSettings, ProjectData_struct*projData)
{
	String path = (String)ProjLoad_getSavedProjectsFolder() + '/' + ProjectData_getFolderName(projData) + "/settings.plist";
	return ProjLoad_savePlist(ProjectSettings_convertToNSMutableDictionary(projSettings), path);
}



//ProjectBuildInfo

ProjectBuildInfo_struct ProjectBuildInfo_create()
{
	ProjectBuildInfo_struct buildInfo;
	buildInfo.data = new ProjectBuildInfo();
	return buildInfo;
}

ProjectBuildInfo_struct ProjectBuildInfo_createWithData(void*data)
{
	ProjectBuildInfo_struct buildInfo;
	buildInfo.data = data;
	return buildInfo;
}

ProjectBuildInfo_struct* ProjectBuildInfo_createInstance()
{
	ProjectBuildInfo_struct* buildInfo = new ProjectBuildInfo_struct();
	buildInfo->data = new ProjectBuildInfo();
	return buildInfo;
}

void ProjectBuildInfo_destroy(ProjectBuildInfo_struct projBuildInfo)
{
	if(projBuildInfo.data!=NULL)
	{
		delete ((ProjectBuildInfo*)projBuildInfo.data);
	}
}

void ProjectBuildInfo_destroyInstance(ProjectBuildInfo_struct* projBuildInfo)
{
	if(projBuildInfo!=NULL)
	{
		if(projBuildInfo->data!=NULL)
		{
			delete ((ProjectBuildInfo*)projBuildInfo->data);
		}
		delete projBuildInfo;
	}
}

void* ProjectBuildInfo_getData(ProjectBuildInfo_struct* projBuildInfo)
{
	if(projBuildInfo!=NULL)
	{
		return projBuildInfo->data;
	}
	return NULL;
}

void ProjectBuildInfo_addEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* file)
{
	if(projBuildInfo!=NULL && projBuildInfo->data!=NULL && file!=NULL)
	{
		((ProjectBuildInfo*)projBuildInfo->data)->addEditedFile(file);
	}
}

void ProjectBuildInfo_renameEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* oldFile, const char* newFile)
{
	if(projBuildInfo!=NULL && projBuildInfo->data!=NULL && oldFile!=NULL && newFile!=NULL)
	{
		((ProjectBuildInfo*)projBuildInfo->data)->renameEditedFile(oldFile, newFile);
	}
}

void ProjectBuildInfo_removeEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* file)
{
	if(projBuildInfo!=NULL && projBuildInfo->data!=NULL && file!=NULL)
	{
		((ProjectBuildInfo*)projBuildInfo->data)->removeEditedFile(file);
	}
}

bool ProjectBuildInfo_hasEditedFile(ProjectBuildInfo_struct* projBuildInfo, const char* file)
{
	if(projBuildInfo!=NULL && projBuildInfo->data!=NULL && file!=NULL)
	{
		return ((ProjectBuildInfo*)projBuildInfo->data)->hasEditedFile(file);
	}
	return false;
}

StringList_struct ProjectBuildInfo_getEditedFiles(ProjectBuildInfo_struct* projBuildInfo)
{
	if(projBuildInfo!=NULL && projBuildInfo->data!=NULL)
	{
		ArrayList<String>& editedFiles = ((ProjectBuildInfo*)projBuildInfo->data)->getEditedFiles();
		return StringList_createWithData((void*)(&editedFiles));
	}
	return StringList_createWithData(NULL);
}

bool ProjectBuildInfo_saveBuildInfoPlist(ProjectBuildInfo_struct*projBuildInfo, ProjectData_struct*projData)
{
	String path = (String)ProjLoad_getSavedProjectsFolder() + '/' + ProjectData_getFolderName(projData) + "/bin";
	FileTools::createDirectory(path);
	path += "/build";
	FileTools::createDirectory(path);
	path += "/buildinfo.plist";
	return ProjLoad_savePlist(ProjectBuildInfo_convertToNSMutableDictionary(projBuildInfo), path);
}



//ProjectData

ProjectType ProjectType_convertFromString(const char* projType)
{
	String projectType = projType;
	if(projectType.equals("Application"))
	{
		return PROJECTTYPE_APPLICATION;
	}
	else if(projectType.equals("Console"))
	{
		return PROJECTTYPE_CONSOLE;
	}
	else if(projectType.equals("DynamicLibrary"))
	{
		return PROJECTTYPE_DYNAMICLIBRARY;
	}
	else if(projectType.equals("StaticLibrary"))
	{
		return PROJECTTYPE_STATICLIBRARY;
	}
	return PROJECTTYPE_UNKNOWN;
}

void* ProjectType_convertToNSString(ProjectType projType)
{
	switch(projType)
	{
		case PROJECTTYPE_UNKNOWN:
		case PROJECTTYPE_APPLICATION:
		return NSString_stringWithUTF8String("Application");
		
		case PROJECTTYPE_CONSOLE:
		return NSString_stringWithUTF8String("Console");
		
		case PROJECTTYPE_DYNAMICLIBRARY:
		return NSString_stringWithUTF8String("DynamicLibrary");
		
		case PROJECTTYPE_STATICLIBRARY:
		return NSString_stringWithUTF8String("StaticLibrary");
	}
	return NULL;
}

ProjectDevice ProjectDevice_convertFromString(const char* projDevice)
{
	String projectDevice = projDevice;
	if(projectDevice.equals("iPhone"))
	{
		return DEVICE_IPHONE;
	}
	else if(projectDevice.equals("iPad"))
	{
		return DEVICE_IPAD;
	}
	else if(projectDevice.equals("iPhone/iPad") || projectDevice.equals("iPad/iPhone"))
	{
		return DEVICE_ALL;
	}
	return DEVICE_UNKNOWN;
}

void* ProjectDevice_convertToNSString(ProjectDevice projDevice)
{
	switch(projDevice)
	{
		case DEVICE_UNKNOWN:
		case DEVICE_IPHONE:
		return NSString_stringWithUTF8String("iPhone");
			
		case DEVICE_IPAD:
		return NSString_stringWithUTF8String("iPad");
			
		case DEVICE_ALL:
		return NSString_stringWithUTF8String("iPhone/iPad");
	}
	return NULL;
}

bool ProjectData_checkValidString(const char*str)
{
	if(str!=NULL && strlen(str)>0)
	{
		return ProjectData::checkValidString(str);
	}
	return false;
}

ProjectData_struct ProjectData_create(const char*name, const char*author)
{
	ProjectData_struct projData;
	projData.data = new ProjectData(name, author);
	return projData;
}

ProjectData_struct ProjectData_createWithData(void*data)
{
	ProjectData_struct projData;
	projData.data = data;
	return projData;
}

ProjectData_struct*ProjectData_createInstance(const char*name, const char*author)
{
	ProjectData_struct*projData = new ProjectData_struct();
	projData->data = new ProjectData(name, author);
	return projData;
}

void ProjectData_destroy(ProjectData_struct projData)
{
	if(projData.data!=NULL)
	{
		delete ((ProjectData*)projData.data);
		projData.data = NULL;
	}
}

void ProjectData_destroyInstance(ProjectData_struct*projData)
{
	if(projData!=NULL)
	{
		if(projData->data!=NULL)
		{
			delete ((ProjectData*)projData->data);
		}
		delete projData;
	}
}

void*ProjectData_getData(ProjectData_struct*projData)
{
	if(projData!=NULL)
	{
		return ((ProjectData*)projData->data);
	}
	return NULL;
}

void ProjectData_setProjectType(ProjectData_struct*projData, ProjectType type)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		((ProjectData*)projData->data)->setProjectType(type);
	}
}

void ProjectData_setProjectDevice(ProjectData_struct*projData, ProjectDevice device)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		((ProjectData*)projData->data)->setProjectDevice(device);
	}
}

void ProjectData_setName(ProjectData_struct*projData, const char*name)
{
	if(projData!=NULL && projData->data!=NULL && name!=NULL)
	{
		((ProjectData*)projData->data)->setName(name);
	}
}

void ProjectData_setAuthor(ProjectData_struct*projData, const char*author)
{
	if(projData!=NULL && projData->data!=NULL && author!=NULL)
	{
		((ProjectData*)projData->data)->setAuthor(author);
	}
}

void ProjectData_setBundleIdentifier(ProjectData_struct*projData, const char*bundleID)
{
	if(projData!=NULL && projData->data!=NULL && bundleID!=NULL)
	{
		((ProjectData*)projData->data)->setBundleIdentifier(bundleID);
	}
}

void ProjectData_setExecutableName(ProjectData_struct*projData, const char*execName)
{
	if(projData!=NULL && projData->data!=NULL && execName!=NULL)
	{
		((ProjectData*)projData->data)->setExecutableName(execName);
	}
}

void ProjectData_setProductName(ProjectData_struct*projData, const char*product)
{
	if(projData!=NULL && projData->data!=NULL && product!=NULL)
	{
		((ProjectData*)projData->data)->setProductName(product);
	}
}

void ProjectData_setFolderName(ProjectData_struct*projData, const char*folder)
{
	if(projData!=NULL && projData->data!=NULL && folder!=NULL)
	{
		((ProjectData*)projData->data)->setFolderName(folder);
	}
}

void ProjectData_addFramework(ProjectData_struct*projData, const char*framework)
{
	if(projData!=NULL && projData->data!=NULL && framework!=NULL)
	{
		((ProjectData*)projData->data)->addFramework(framework);
	}
}

ProjectType ProjectData_getProjectType(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return ((ProjectData*)projData->data)->getProjectType();
	}
	return PROJECTTYPE_UNKNOWN;
}

ProjectDevice ProjectData_getProjectDevice(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return ((ProjectData*)projData->data)->getProjectDevice();
	}
	return DEVICE_UNKNOWN;
}

const char* ProjectData_getName(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return (const char*)(((ProjectData*)projData->data)->getName());
	}
	return NULL;
}

const char* ProjectData_getAuthor(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return (const char*)(((ProjectData*)projData->data)->getAuthor());
	}
	return NULL;
}

const char* ProjectData_getBundleIdentifier(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return (const char*)(((ProjectData*)projData->data)->getBundleIdentifier());
	}
	return NULL;
}

const char* ProjectData_getExecutableName(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return (const char*)(((ProjectData*)projData->data)->getExecutableName());
	}
	return NULL;
}

const char* ProjectData_getProductName(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return (const char*)(((ProjectData*)projData->data)->getProductName());
	}
	return NULL;
}

const char* ProjectData_getFolderName(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return (const char*)(((ProjectData*)projData->data)->getFolderName());
	}
	return NULL;
}

StringList_struct ProjectData_getFrameworkList(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return StringList_createWithData(&(((ProjectData*)projData->data)->getFrameworkList()));
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

StringTree_struct ProjectData_getSourceFiles(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return StringTree_createWithData(&(((ProjectData*)projData->data)->getSourceFiles()));
	}
	StringTree_struct st;
	st.data = NULL;
	return st;
}

StringTree_struct ProjectData_getResourceFiles(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return StringTree_createWithData(&(((ProjectData*)projData->data)->getResourceFiles()));
	}
	StringTree_struct st;
	st.data = NULL;
	return st;
}

StringList_struct ProjectData_getIncludeDirs(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return StringList_createWithData(&(((ProjectData*)projData->data)->getIncludeDirs()));
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

StringList_struct ProjectData_getLibDirs(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return StringList_createWithData(&(((ProjectData*)projData->data)->getLibDirs()));
	}
	StringList_struct sl;
	sl.data = NULL;
	return sl;
}

ProjectSettings_struct ProjectData_getProjectSettings(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return ProjectSettings_createWithData(&((ProjectData*)projData->data)->getProjectSettings());
	}
	return ProjectSettings_createWithData(NULL);
}

ProjectBuildInfo_struct ProjectData_getProjectBuildInfo(ProjectData_struct*projData)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		return ProjectBuildInfo_createWithData(&((ProjectData*)projData->data)->getProjectBuildInfo());
	}
	return ProjectBuildInfo_createWithData(NULL);
}

void ProjectData_removeFramework(ProjectData_struct*projData, int index)
{
	if(projData!=NULL && projData->data!=NULL)
	{
		((ProjectData*)projData->data)->removeFramework(index);
	}
}

bool ProjectData_saveProjectPlist(ProjectData_struct*projData)
{
	String path = (String)ProjLoad_getSavedProjectsFolder() + '/' + ProjectData_getFolderName(projData) + "/project.plist";
	return ProjLoad_savePlist(ProjectData_convertToNSMutableDictionary(projData), path);
}



//FileTools

const char*FileTools_getExecutableDirectory()
{
	return executable_directory;
}

StringList_struct* FileTools_getFilenamesWithExtension(const char*directory, StringList_struct*extensions)
{
	const ArrayList<String>&filenames = FileTools::getFilenamesWithExtension(directory, *((ArrayList<String>*)extensions->data));
	return StringList_createInstanceWithData((void*)(&filenames));
}

StringList_struct* FileTools_getFoldersInDirectory(const char*directory)
{
	const ArrayList<String>&folders = FileTools::getFoldersInDirectory(directory);
	return StringList_createInstanceWithData((void*)(&folders));
}

StringList_struct* FileTools_getFilesInDirectory(const char*directory)
{
	const ArrayList<String>&files = FileTools::getFilesInDirectory(directory);
	return StringList_createInstanceWithData((void*)(&files));
}

StringTree_struct* FileTools_getStringTreeFromDirectory(const char*directory)
{
	const StringTree&tree = FileTools::getStringTreeFromDirectory(directory);
	return StringTree_createInstanceWithData((void*)(&tree));
}

unsigned int FileTools_totalFilesInDirectory(const char* directory)
{
	return FileTools::totalFilesInDirectory(directory);
}

bool FileTools_directoryContainsFiles(const char *directory)
{
	return FileTools::directoryContainsFiles(directory);
}

bool FileTools_createFile(const char* path)
{
	return FileTools::createFile(path);
}

bool FileTools_createDirectory(const char*directory)
{
	return FileTools::createDirectory(directory);
}

bool FileTools_copyFile(const char*src, const char *dst)
{
	return FileTools::copyFile(src, dst);
}

bool FileTools_copyFolder(const char*src, const char*dst)
{
	return FileTools::copyFolder(src, dst);
}

bool FileTools_deleteFromFilesystem(const char*path)
{
	return FileTools::deleteFromFilesystem(path);
}

bool FileTools_rename(const char* oldFile, const char* newFile)
{
	return FileTools::rename(oldFile, newFile);
}

bool FileTools_writeStringToFile(const char*path, const char*content)
{
	return FileTools::writeStringToFile(path, content);
}

bool FileTools_folderExists(const char*path)
{
	return FileTools::folderExists(path);
}

