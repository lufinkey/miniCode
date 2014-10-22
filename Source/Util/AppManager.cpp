
#include "AppManager.h"
#include "String.h"
#include "ArrayList.h"
#include "Console.h"
#include "FileTools.h"
#include "Thread.h"
#include "../ObjCBridge/ObjCBridge.h"
#include <stdlib.h>

static const String AppManager_resultFile = "/tmp/miniCodeInstaller.result";

bool AppManager_runCommand(const String& srcFile, const ArrayList<String>& args)
{
	String resultFile = AppManager_resultFile;
	AppManager_clean();
	
	String execPath = FileTools_getExecutableDirectory();
	int slashIndex = execPath.lastIndexOf('/');
	String appFolder;
	if(slashIndex==-1)
	{
		appFolder = execPath.substring(0, slashIndex);
	}
	else
	{
		appFolder = execPath;
	}
	
	String miniCodeInstallerPath = appFolder + "/installer";
	String commandString = miniCodeInstallerPath + ' ';
	for(int i=0; i<args.size(); i++)
	{
		commandString += args.get(i) + ' ';
	}
	commandString += (String)"\"" + srcFile + "\"";
	system(commandString);
	
	while(!FileTools_fileExists(resultFile))
	{
		Thread::sleep(3);
	}
	
	String contents;
	bool success = FileTools::loadFileIntoString(resultFile, contents);
	AppManager_clean();
	if(!success)
	{
		showSimpleMessageBox("Error", "Error reading results from result file. Assuming failure.");
		return false;
	}
	
	for(int i=0; i<contents.length(); i++)
	{
		char c = contents.charAt(i);
		if(!(c>='0' && c<='9'))
		{
			showSimpleMessageBox("Error", "Invalid result string");
			return false;
		}
	}
	
	int result = String::asInt(contents);
	if(result==0)
	{
		return true;
	}
	Console::WriteLine((String)"Installer failed with exit code " + result);
	return false;
}

bool AppManager_install(const char* src, const char* appName)
{
	ArrayList<String> args;
	args.add("-i");
	args.add("-n");
	args.add(appName);
	return AppManager_runCommand(src, args);
}

bool AppManager_uninstall(const char* src)
{
	ArrayList<String> args;
	args.add("-u");
	return AppManager_runCommand(src, args);
}

bool AppManager_clean()
{
	String execPath = FileTools_getExecutableDirectory();
	int slashIndex = execPath.lastIndexOf('/');
	String appFolder;
	if(slashIndex==-1)
	{
		appFolder = execPath.substring(0, slashIndex);
	}
	else
	{
		appFolder = execPath;
	}
	
	String miniCodeInstallerPath = appFolder + "/installer";
	
	system(miniCodeInstallerPath + " -c");
	
	bool continuing = false;
	
	int counter = 0;
	while(FileTools_fileExists(AppManager_resultFile) && !continuing)
	{
		Thread::sleep(3);
		if(counter>=3000)
		{
			continuing = true;
		}
	}
	
	return true;
}

bool AppManager_createDefaultFolders()
{
	String execPath = FileTools_getExecutableDirectory();
	int slashIndex = execPath.lastIndexOf('/');
	String appFolder;
	if(slashIndex==-1)
	{
		appFolder = execPath.substring(0, slashIndex);
	}
	else
	{
		appFolder = execPath;
	}
	
	String miniCodeInstallerPath = appFolder + "/installer";
	
	system(miniCodeInstallerPath + " -f");
	
	return true;
}
