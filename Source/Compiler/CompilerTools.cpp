
#include "CompilerTools.h"
#include "CompilerOrganizer.h"
#include "CopyResourcesThread.h"
#include "InstallThread.h"
#include "../Util/FileTools.h"
#include "../Util/String.h"
#include "../Util/ArrayList.h"
#include "../ProjectLoad/ProjLoadTools.h"

CompilerOutputLine_struct CompilerOutputLine_createWithData(void*data)
{
	CompilerOutputLine_struct outputLine;
	outputLine.data = data;
	return outputLine;
}

CompilerOutputType CompilerOutputLine_getType(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getType();
	}
	return COMPILER_UNKNOWN;
}

const char* CompilerOutputLine_getOutput(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getOutput();
	}
	return NULL;
}

StringList_struct CompilerOutputLine_getSupplementaryOutput(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return StringList_createWithData(&((CompilerOutputLine*)outputLine->data)->getSupplementaryOutput());
	}
	return StringList_createWithData(NULL);
}

int CompilerOutputLine_getResult(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getResult();
	}
	return NULL;
}

const char* CompilerOutputLine_getFileName(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getFileName();
	}
	return NULL;
}

unsigned int CompilerOutputLine_getLine(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getLine();
	}
	return 0;
}

unsigned int CompilerOutputLine_getOffset(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getOffset();
	}
	return 0;
}

const char* CompilerOutputLine_getErrorType(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getErrorType();
	}
	return NULL;
}

const char* CompilerOutputLine_getMessage(CompilerOutputLine_struct*outputLine)
{
	if(outputLine!=NULL && outputLine->data!=NULL)
	{
		return ((CompilerOutputLine*)outputLine->data)->getMessage();
	}
	return NULL;
}



//CompilerOrganizer

CompilerOrganizer_struct* CompilerOrganizer_createInstance(ProjectData_struct*projData)
{
	if(projData!=NULL)
	{
		CompilerOrganizer_struct* organizer = new CompilerOrganizer_struct();
		organizer->data = new CompilerOrganizer((ProjectData*)projData->data);
		return organizer;
	}
	return NULL;
}

void CompilerOrganizer_destroyInstance(CompilerOrganizer_struct*organizer)
{
	if(organizer!=NULL)
	{
		if(organizer->data!=NULL)
		{
			delete ((CompilerOrganizer*)organizer->data);
		}
		delete organizer;
	}
}

bool CompilerOrganizer_isRunning(CompilerOrganizer_struct*organizer)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		return ((CompilerOrganizer*)organizer->data)->isRunning();
	}
	return false;
}

void CompilerOrganizer_runCompiler(CompilerOrganizer_struct*organizer)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		((CompilerOrganizer*)organizer->data)->runCompiler();
	}
}

const char* CompilerOrganizer_getCurrentStatus(CompilerOrganizer_struct*organizer)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		return ((CompilerOrganizer*)organizer->data)->getCurrentStatus();
	}
	return NULL;
}

void CompilerOrganizer_setCallbacks(CompilerOrganizer_struct*organizer,
									CompilerOrganizer_OutputRecievedCallback outputRecievedCallback,
									CompilerOrganizer_FinishCallback finishCallback,
									CompilerOrganizer_StatusCallback statusCallback, void*data)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		((CompilerOrganizer*)organizer->data)->setCallbacks(outputRecievedCallback, finishCallback, statusCallback, data);
	}
}

unsigned int CompilerOrganizer_totalFiles(CompilerOrganizer_struct*organizer)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		return ((CompilerOrganizer*)organizer->data)->totalFiles();
	}
	return 0;
}

unsigned int CompilerOrganizer_totalErrors(CompilerOrganizer_struct*organizer, const char* fileName)
{
	if(organizer!=NULL && organizer->data!=NULL && fileName!=NULL)
	{
		return ((CompilerOrganizer*)organizer->data)->totalErrors(fileName);
	}
	return 0;
}

unsigned int CompilerOrganizer_totalErrors(CompilerOrganizer_struct*organizer, unsigned int index)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		return ((CompilerOrganizer*)organizer->data)->totalErrors(index);
	}
	return 0;
}

const char* CompilerOrganizer_getFile(CompilerOrganizer_struct*organizer, unsigned int index)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		return ((CompilerOrganizer*)organizer->data)->getFile(index);
	}
	return NULL;
}

CompilerOutputLine_struct CompilerOrganizer_getError(CompilerOrganizer_struct*organizer, const char* fileName, unsigned int index)
{
	if(organizer!=NULL && organizer->data!=NULL && fileName!=NULL)
	{
		return CompilerOutputLine_createWithData(&(((CompilerOrganizer*)organizer->data)->getError(fileName, index)));
	}
	return CompilerOutputLine_createWithData(NULL);
}

CompilerOutputLine_struct CompilerOrganizer_getError(CompilerOrganizer_struct*organizer, unsigned int fileIndex, unsigned int errorIndex)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		return CompilerOutputLine_createWithData(&(((CompilerOrganizer*)organizer->data)->getError(fileIndex, errorIndex)));
	}
	return CompilerOutputLine_createWithData(NULL);
}

void CompilerOrganizer_clear(CompilerOrganizer_struct*organizer)
{
	if(organizer!=NULL && organizer->data!=NULL)
	{
		((CompilerOrganizer*)organizer->data)->clear();
	}
}



//CompileTools

void CompilerTools_fillProjectVarsInString(String& str, const ProjectData& projData)
{
	str.replace("${PRODUCT_NAME}", projData.getProductName());
	str.replace("${EXECUTABLE_NAME}", projData.getExecutableName());
	str.replace("${BUNDLE_IDENTIFIER}", projData.getBundleIdentifier());
}

void CompilerTools_cleanOutput(ProjectData_struct*project)
{
	String binFolder = (String)ProjLoad_getSavedProjectsFolder() + '/' + ProjectData_getFolderName(project) + "/bin";
	FileTools::deleteFromFilesystem(binFolder+"/build");
	FileTools::deleteFromFilesystem(binFolder+"/release");
}

void CompilerTools_clearInfoPlist(ProjectData_struct*project)
{
	ProjectData& projData = *((ProjectData*)project->data);
	String path = ProjLoad_getSavedProjectsFolder();
	path += (String)'/' + projData.getFolderName() + "/bin/release/";
	ProjectType projType = projData.getProjectType();
	if(projType==PROJECTTYPE_APPLICATION)
	{
		 path += projData.getProductName() + ".app/Info.plist";
	}
	else
	{
		return;
	}
	FileTools::deleteFromFilesystem(path);
}

void CompilerTools_fillInfoPlist(ProjectData_struct*project)
{
	ProjectData& projData = *((ProjectData*)project->data);
	String path = ProjLoad_getSavedProjectsFolder();
	path += (String)'/' + projData.getFolderName() + "/bin/release/";
	ProjectType projType = projData.getProjectType();
	if(projType == PROJECTTYPE_APPLICATION)
	{
		path += projData.getProductName() + ".app/Info.plist";
	}
	else
	{
		return;
	}
	
	String fileContents;
	
	if(FileTools_fileExists(path))
	{
		bool success = FileTools::loadFileIntoString(path, fileContents);
		if(!success)
		{
			return;
		}
		
		CompilerTools_fillProjectVarsInString(fileContents, projData);
		FileTools::writeStringToFile(path, fileContents);
	}
	
	void* infoPlist = ProjLoad_loadAllocatedPlist(path);
	if(infoPlist!=NULL)
	{
		//UIDeviceFamily
		void* uidevicefamily = NSMutableArray_alloc_init();
		ProjectDevice projDevice = projData.getProjectDevice();
		if(projDevice==DEVICE_IPHONE)
		{
			void* num = NSNumber_numberWithInt(1);
			NSMutableArray_addObject(uidevicefamily, num);
		}
		else if(projDevice==DEVICE_IPAD)
		{
			void* num = NSNumber_numberWithInt(2);
			NSMutableArray_addObject(uidevicefamily, num);
		}
		else if(projDevice==DEVICE_ALL)
		{
			void* num = NSNumber_numberWithInt(1);
			NSMutableArray_addObject(uidevicefamily, num);
			num = NSNumber_numberWithInt(2);
			NSMutableArray_addObject(uidevicefamily, num);
		}
		
		if(projDevice!=DEVICE_UNKNOWN)
		{
			NSMutableDictionary_setObjectForKey(infoPlist, uidevicefamily, "UIDeviceFamily");
		}
		id_release(uidevicefamily);
		
		id_release(infoPlist);
	}
}

void CompilerTools_copyResources(ProjectData_struct*project, CopyResourcesThreadFinishCallback callback, void*data)
{
	CopyResourcesThread*thread = new CopyResourcesThread((ProjectData*)project->data);
	thread->setCallback(callback, data);
	thread->start();
}

void CompilerTools_installApplication(ProjectData_struct*project, InstallThreadFinishCallback callback, void*data)
{
	InstallThread*thread = new InstallThread((ProjectData*)project->data);
	thread->setCallback(callback, data);
	thread->start();
}

void CompilerTools_runApplication(const char* bundleID)
{
	String command = (String)"open " + bundleID;
	system(command);
}

StringList_struct* CompilerTools_loadWarningList()
{
	String fileContents;
	String filePath = (String)FileTools_getExecutableDirectory() + "/CompilerWarnings.txt";
	
	if(!FileTools::loadFileIntoString(filePath, fileContents))
	{
		return NULL;
	}
	
	String currentLine;
	ArrayList<String>* lines = new ArrayList<String>();
	
	for(int i=0; i<fileContents.length(); i++)
	{
		char c = fileContents.charAt(i);
		if(c<' ')
		{
			if(currentLine.length()>0)
			{
				lines->add(currentLine);
				currentLine.clear();
			}
		}
		else
		{
			currentLine += c;
		}
	}
	
	fileContents.clear();
	
	StringList_struct* list = new StringList_struct();
	list->data = (void*)lines;
	return list;
}



