
#include "ProjLoadTools.h"
#include "../ProjectData/ProjectData.h"
#include "../Util/String.h"
#include "../Util/StringTree.h"
#include "../Util/FileTools.h"
#include "../Util/Console.h"
#include "../PreferencesView/GlobalPreferences.h"
#include <stdlib.h>

#include "TargetConditionals.h"

static const char* TEMPLATEFIELD_NAME       = "___PROJECT_NAME___";
static const char* TEMPLATEFIELD_AUTHOR     = "___AUTHOR_NAME___";
static const char* TEMPLATEFIELD_BUNDLENAME = "___PROJECTNAMEASIDENTIFIER___";
static const char* TEMPLATEFIELD_EXECUTABLE = "___EXECUTABLE_NAME___";
static const char* TEMPLATEFIELD_PRODUCT    = "___PRODUCT_NAME___";

static const char* TEMPLATEFIELDS[5] = {TEMPLATEFIELD_NAME, TEMPLATEFIELD_AUTHOR, TEMPLATEFIELD_BUNDLENAME, TEMPLATEFIELD_EXECUTABLE, TEMPLATEFIELD_PRODUCT};

static const char*savedProjectsSubfolder = "Library/miniCode/projects";
static const String savedProjectsFolder = (String)getenv("HOME")+ '/' + savedProjectsSubfolder;

void ProjLoad_createDefaultFolders()
{
	String homeFolder = getenv("HOME");
	FileTools::createDirectory(homeFolder + "/Library/miniCode");
	FileTools::createDirectory(homeFolder + "/Library/miniCode/projects");
#if !(TARGET_IPHONE_SIMULATOR)
	FileTools::createDirectory("/var/stash/Developer");
	FileTools::createDirectory("/var/stash/Developer/SDKs");
#endif
}

void ProjLoad_fillProjectVarsInString(String&str, const String&projectName, const String&authorName, const String&projectNameAsIdentifier,
									  const String&executableName, const String& productName);

void ProjLoad_fillProjectVarsInSourceFiles(StringTree&sourceTree, const String&templateSrcRoot, const String&projectSrcRoot, const String&subFolder,
										   const String&projectName, const String&authorName, const String&projectNameAsIdentifier,
										   const String&executableName, const String& productName);

void ProjLoad_fillProjectVarsInResourceFiles(StringTree&resourceTree, const String&templateResRoot, const String&projectResRoot, const String&subFolder,
										   const String&projectName, const String&authorName, const String&projectNameAsIdentifier,
										   const String&executableName, const String& productName);


StringList_struct*ProjLoad_loadCategoryList()
{
	String execDir = FileTools_getExecutableDirectory();
	StringList_struct*catList = FileTools_getFoldersInDirectory(execDir+"/Project Templates");
	return catList;
}

StringList_struct*ProjLoad_loadTemplateList(const char*category)
{
	String execDir = FileTools_getExecutableDirectory();
	StringList_struct*temList = FileTools_getFoldersInDirectory(execDir+"/Project Templates/" + category);
	return temList;
}

void*ProjLoad_loadCategoryIcon(const char*category)
{
	String path = (String)"Project Templates/" + category + "/CategoryIcon.png";
	return ProjLoad_loadUIImage(path);
}

void*ProjLoad_loadTemplateIcon(const char*category, const char*templateName)
{
	String path = (String)"Project Templates/" + category + '/' + templateName + "/TemplateIcon.png";
	return ProjLoad_loadUIImage(path);
}

void*ProjLoad_loadTemplateInfo(const char*category, const char*templateName)
{
	String path = (String)"Project Templates/" + category + '/' + templateName + "/TemplateInfo.plist";
	return ProjLoad_loadPlist(path);
}

void ProjLoad_getPathWithExecutablePath(char*dest, const char*relPath, unsigned int size)
{
	String fullPath = FileTools_getExecutableDirectory();
	fullPath += (String)"/" + relPath;
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

void ProjLoad_getPathWithHomePath(char*dest, const char*relPath, unsigned int size)
{
	String fullPath = getenv("HOME");
	fullPath += (String)"/" + relPath;
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

void ProjLoad_getPathWithSavedProjectsPath(char*dest, const char*relPath, unsigned int size)
{
	String fullPath = savedProjectsFolder + '/' + relPath;
	dest[size-1] = '\0';
	if(fullPath.length()<(size-1))
	{
		dest[fullPath.length()] = '\0';
	}
	for(int i=0; (i<(size-1))&&(i<fullPath.length()); i++)
	{
		dest[0] = fullPath.charAt(i);
	}
	
}

ProjectData_struct*ProjLoad_loadProjectDataFromNSDictionary(void*dict)
{
	if(dict==NULL)
	{
		return NULL;
	}
	
	const char*name = NSString_UTF8String(NSDictionary_objectForKey(dict,"name"));
	const char*author = NSString_UTF8String(NSDictionary_objectForKey(dict,"author"));
	if(name==NULL || author==NULL || strlen(name)==0 || strlen(author)==0)
	{
		showSimpleMessageBox("Error loading ProjectData", "name or author field in project.plist is empty or not available");
		return NULL;
	}
	
	ProjectData_struct*projDataStruct = ProjectData_createInstance(name, author);
	ProjectData&projData = *((ProjectData*)ProjectData_getData(projDataStruct));
	
	const char*bundleID = NSString_UTF8String(NSDictionary_objectForKey(dict,"bundleIdentifier"));
	if(bundleID!=NULL && strlen(bundleID)!=0)
	{
		projData.setBundleIdentifier(bundleID);
	}
	
	const char*executable = NSString_UTF8String(NSDictionary_objectForKey(dict,"executable"));
	if(executable!=NULL && strlen(executable)!=0)
	{
		projData.setExecutableName(executable);
	}
	
	const char*product = NSString_UTF8String(NSDictionary_objectForKey(dict,"product"));
	if(product!=NULL && strlen(product)!=0)
	{
		projData.setProductName(product);
	}
	
	void*frameworks = NSDictionary_objectForKey(dict,"frameworks");
	if(frameworks!=NULL)
	{
		for(unsigned int i=0; i<NSArray_count(frameworks); i++)
		{
			const char*framework = NSString_UTF8String(NSArray_objectAtIndex(frameworks, i));
			projData.addFramework(framework);
		}
	}
	
	void*sourceFiles = NSDictionary_objectForKey(dict,"sourceFiles");
	if(sourceFiles!=NULL)
	{
		StringTree_struct*sourceTree = StringTree_convertNSArrayToFileTree(sourceFiles);
		projData.getSourceFiles() = *((StringTree*)StringTree_getData(sourceTree));
		StringTree_destroyInstance(sourceTree);
	}
	
	void*resources = NSDictionary_objectForKey(dict, "resources");
	if(resources!=NULL)
	{
		StringTree_struct*resourceTree = StringTree_convertNSArrayToFileTree(resources);
		projData.getResourceFiles() = *((StringTree*)StringTree_getData(resourceTree));
		StringTree_destroyInstance(resourceTree);
	}
	
	void*external = NSDictionary_objectForKey(dict, "external");
	if(external!=NULL)
	{
		void*includeArray = NSDictionary_objectForKey(external, "include");
		for(unsigned int i=0; i<NSArray_count(includeArray); i++)
		{
			const char* includePath = NSString_UTF8String(NSArray_objectAtIndex(includeArray, i));
			if(includePath!=NULL && strlen(includePath)!=0)
			{
				projData.getIncludeDirs().add(includePath);
			}
		}
		
		void*libArray = NSDictionary_objectForKey(external, "lib");
		for(unsigned int i=0; i<NSArray_count(libArray); i++)
		{
			const char* libPath = NSString_UTF8String(NSArray_objectAtIndex(libArray, i));
			if(libPath!=NULL && strlen(libPath)!=0)
			{
				projData.getLibDirs().add(libPath);
			}
		}
	}
	
	return projDataStruct;
}

ProjectData_struct*ProjLoad_loadProjectDataFromTemplate(const char*category, const char*templateName)
{
	String execPath = FileTools_getExecutableDirectory();
	String templatePlistPath = execPath + "/Project Templates/" + category + '/' + templateName + "/project.plist";
	void* plistDict = ProjLoad_loadAllocatedPlist(templatePlistPath);
	if(plistDict==NULL)
	{
		showSimpleMessageBox("Error loading ProjectData", (String)"Problem occured loading project.plist in template " + templateName + " in category " + category);
		return NULL;
	}
	ProjectData_struct*projData = ProjLoad_loadProjectDataFromNSDictionary(plistDict);
	if(projData==NULL)
	{
		id_release(plistDict);
		return NULL;
	}
	ProjectData_setFolderName(projData, templateName);
	id_release(plistDict);
	return projData;
}

ProjectData_struct*ProjLoad_loadProjectDataFromSavedProject(const char* projectName)
{
	String plistPath = savedProjectsFolder + '/' + projectName + "/project.plist";
	void* plistDict = ProjLoad_loadAllocatedPlist(plistPath);
	if(plistDict==NULL)
	{
		showSimpleMessageBox("Error loading ProjectData", (String)"Problem occured loading project.plist from saved project " + projectName);
		return NULL;
	}
	ProjectData_struct*projData = ProjLoad_loadProjectDataFromNSDictionary(plistDict);
	if(projData==NULL)
	{
		id_release(plistDict);
		return NULL;
	}
	String settingsPath = savedProjectsFolder + '/' + projectName + "/settings.plist";
	void* settingsPlist = ProjLoad_loadAllocatedPlist(settingsPath);
	if(settingsPlist!=NULL)
	{
		ProjectSettings_struct* projSettings = ProjLoad_loadProjectSettingsFromNSDictionary(settingsPlist);
		if(projSettings!=NULL)
		{
			((ProjectData*)projData->data)->getProjectSettings() = *((ProjectSettings*)projSettings->data);
			String sdk = ProjectSettings_getSDK(projSettings);
			if(!Global_checkSDKFolderValid(sdk))
			{
				((ProjectData*)projData->data)->getProjectSettings().setSDK(GlobalPreferences_getDefaultSDK());
			}
		}
		ProjectSettings_destroyInstance(projSettings);
		id_release(settingsPlist);
	}
	
	ProjectData_setFolderName(projData, projectName);
	
	FileTools::createDirectory(savedProjectsFolder+'/'+projectName+"/src");
	FileTools::createDirectory(savedProjectsFolder+'/'+projectName+"/res");
	FileTools::createDirectory(savedProjectsFolder+'/'+projectName+"/ext");
	FileTools::createDirectory(savedProjectsFolder+'/'+projectName+"/bin");
	FileTools::createDirectory(savedProjectsFolder+'/'+projectName+"/bin/build");
	FileTools::createDirectory(savedProjectsFolder+'/'+projectName+"/bin/release");
	
	String buildInfoPath = savedProjectsFolder + '/' + projectName + "/bin/build/buildinfo.plist";
	void* buildInfoPlist = ProjLoad_loadAllocatedPlist(buildInfoPath);
	if(buildInfoPlist!=NULL)
	{
		ProjectBuildInfo_struct* projBuildInfo = ProjLoad_loadProjectBuildInfoFromNSDictionary(buildInfoPlist);
		if(projBuildInfo!=NULL)
		{
			((ProjectData*)projData->data)->getProjectBuildInfo() = *((ProjectBuildInfo*)projBuildInfo->data);
		}
		ProjectBuildInfo_destroyInstance(projBuildInfo);
		id_release(buildInfoPlist);
	}
	
	id_release(plistDict);
	return projData;
}

ProjectSettings_struct*ProjLoad_loadProjectSettingsFromNSDictionary(void*dict)
{
	if(dict==NULL)
	{
		return NULL;
	}
	
	ProjectSettings_struct* projSettingsStruct = ProjectSettings_createInstance();
	ProjectSettings&projSettings = *((ProjectSettings*)ProjectSettings_getData(projSettingsStruct));
	
	void* sdk = NSDictionary_objectForKey(dict, "SDK");
	if(sdk!=NULL)
	{
		projSettings.setSDK(NSString_UTF8String(sdk));
	}
	
	void* compilerFlags = NSDictionary_objectForKey(dict, "CompilerFlags");
	if(compilerFlags!=NULL)
	{
		for(unsigned int i=0; i<NSArray_count(compilerFlags); i++)
		{
			void*flag = NSArray_objectAtIndex(compilerFlags, i);
			if(flag!=NULL)
			{
				projSettings.addCompilerFlag(NSString_UTF8String(flag));
			}
		}
	}
	
	return projSettingsStruct;
}

ProjectBuildInfo_struct*ProjLoad_loadProjectBuildInfoFromNSDictionary(void*dict)
{
	if(dict==NULL)
	{
		return NULL;
	}
	
	ProjectBuildInfo_struct* projBuildInfoStruct = ProjectBuildInfo_createInstance();
	ProjectBuildInfo& projBuildInfo = *((ProjectBuildInfo*)ProjectBuildInfo_getData(projBuildInfoStruct));
	
	void* editedFiles = NSDictionary_objectForKey(dict, "EditedFiles");
	if(editedFiles!=NULL)
	{
		for(unsigned int i=0; i<NSArray_count(editedFiles); i++)
		{
			void* file = NSArray_objectAtIndex(editedFiles, i);
			if(file!=NULL)
			{
				projBuildInfo.addEditedFile(NSString_UTF8String(file));
			}
		}
	}
	
	return projBuildInfoStruct;
}

void ProjLoad_fillProjectVarsInString(String&str, const String&projectName, const String&authorName, const String&projectNameAsIdentifier,
									  const String&executableName, const String& productName)
{
	const String*fields[5] = {&projectName, &authorName, &projectNameAsIdentifier, &executableName, &productName};
	for(int i=0; i<5; i++)
	{
		str.replace(TEMPLATEFIELDS[i], *fields[i]);
	}
}

void ProjLoad_fillProjectVarsInSourceFiles(StringTree&sourceTree, const String&templateSrcRoot, const String&projectSrcRoot, const String&subFolder,
										   const String&projectName, const String&authorName, const String&projectNameAsIdentifier,
										   const String&executableName, const String& productName)
{
	ArrayList<String> members = sourceTree.getMembers();
	
	String templateSrcCurrentFolder = templateSrcRoot;
	String projectSrcCurrentFolder = projectSrcRoot;
	if(!subFolder.equals(""))
	{
		templateSrcCurrentFolder += (String)"/" + subFolder;
		projectSrcCurrentFolder += (String)"/" + subFolder;
	}
	
	for(int i=0; i<members.size(); i++)
	{
		String filename = members.get(i);
		String filepath = templateSrcCurrentFolder + '/' + filename;
		
		String fileContents;
		bool loadedFile = FileTools::loadFileIntoString(filepath, fileContents);
		
		if(!loadedFile)
		{
			showSimpleMessageBox("Error loading ProjectData", (String)"Error loading file " + filepath);
		}
		else
		{
			ProjLoad_fillProjectVarsInString(fileContents, projectName, authorName, projectNameAsIdentifier, executableName, productName);
			
			String newFilename = filename;
			ProjLoad_fillProjectVarsInString(newFilename, projectName, authorName, projectNameAsIdentifier, executableName, productName);
			
			String saveFile = newFilename;
			
			//rename file if necessary
			bool couldRename = false;
			int matchChecks = 0;
			do
			{
				couldRename = sourceTree.renameMember(filename, saveFile);
				if(!couldRename)
				{
					matchChecks++;
					saveFile = newFilename + " (" + matchChecks + ')';
				}
			}
			while (!couldRename);
			
			bool success = FileTools::writeStringToFile(projectSrcCurrentFolder + '/' + saveFile, fileContents);
			if(!success)
			{
				
				showSimpleMessageBox("Error creating new project", (String)"Error creating file " + projectSrcCurrentFolder + '/' + saveFile);
			}
		}
	}
	
	ArrayList<String> branchNames = sourceTree.getBranchNames();
	
	for(int i=0; i<branchNames.size(); i++)
	{
		String branchname = branchNames.get(i);
		String branchpath = templateSrcCurrentFolder + '/' + branchname;
		
		String newBranchname = branchname;
		ProjLoad_fillProjectVarsInString(newBranchname, projectName, authorName, projectNameAsIdentifier, executableName, productName);
		
		String saveFolder = newBranchname;
		
		//rename file if necessary
		bool couldRename = false;
		int matchChecks = 0;
		do
		{
			couldRename = sourceTree.renameBranch(branchname, saveFolder);
			if(!couldRename)
			{
				matchChecks++;
				saveFolder = newBranchname + " (" + matchChecks + ')';
			}
		}
		while (!couldRename);
		
		bool success = FileTools::createDirectory(projectSrcCurrentFolder + '/' + saveFolder);
		if(success)
		{
			StringTree*tree = sourceTree.getBranch(saveFolder);
			ProjLoad_fillProjectVarsInSourceFiles(*tree, templateSrcRoot, projectSrcRoot, subFolder + '/' + saveFolder,
												  projectName, authorName, projectNameAsIdentifier, executableName, productName);
		}
		else
		{
			showSimpleMessageBox("Error creating new project", (String)"Error creating folder " + projectSrcCurrentFolder + '/' + saveFolder);
		}
	}
}

void ProjLoad_fillProjectVarsInResourceFiles(StringTree&resourceTree, const String&templateResRoot, const String&projectResRoot, const String&subFolder,
											 const String&projectName, const String&authorName, const String&projectNameAsIdentifier,
											 const String&executableName, const String& productName)
{
	ArrayList<String> members = resourceTree.getMembers();
	
	String templateResCurrentFolder = templateResRoot + '/' + subFolder;
	String projectResCurrentFolder = projectResRoot + '/' + subFolder;
	
	for(int i=0; i<members.size(); i++)
	{
		String filename = members.get(i);
		String filepath = templateResCurrentFolder + '/' + filename;
		
		String newFilename = filename;
		ProjLoad_fillProjectVarsInString(newFilename, projectName, authorName, projectNameAsIdentifier, executableName, productName);
		
		String saveFile = newFilename;
		
		//rename file if necessary
		bool couldRename = false;
		int matchChecks = 0;
		do
		{
			couldRename = resourceTree.renameMember(filename, saveFile);
			if(!couldRename)
			{
				matchChecks++;
				saveFile = newFilename + " (" + matchChecks + ')';
			}
		}
		while (!couldRename);
		
		bool success = FileTools::copyFile(filepath, projectResCurrentFolder + '/' + saveFile);
		if(!success)
		{
			
			showSimpleMessageBox("Error creating new project", (String)"Error copying file " + filepath + " to destination " + projectResCurrentFolder + '/' + saveFile);
		}
	}
	
	ArrayList<String> branchNames = resourceTree.getBranchNames();
	
	for(int i=0; i<branchNames.size(); i++)
	{
		String branchname = branchNames.get(i);
		String branchpath = templateResCurrentFolder + '/' + branchname;
		
		String newBranchname = branchname;
		ProjLoad_fillProjectVarsInString(newBranchname, projectName, authorName, projectNameAsIdentifier, executableName, productName);
		
		String saveFolder = newBranchname;
		
		//rename file if necessary
		bool couldRename = false;
		int matchChecks = 0;
		do
		{
			couldRename = resourceTree.renameBranch(branchname, saveFolder);
			if(!couldRename)
			{
				matchChecks++;
				saveFolder = newBranchname + " (" + matchChecks + ')';
			}
		}
		while (!couldRename);
		
		bool success = FileTools::createDirectory(projectResCurrentFolder + '/' + saveFolder);
		if(success)
		{
			StringTree*tree = resourceTree.getBranch(saveFolder);
			ProjLoad_fillProjectVarsInResourceFiles(*tree, templateResRoot, projectResRoot, subFolder + '/' + saveFolder,
												  projectName, authorName, projectNameAsIdentifier, executableName, productName);
		}
		else
		{
			showSimpleMessageBox("Error creating new project", (String)"Error creating folder " + projectResCurrentFolder + '/' + saveFolder);
		}
	}
}

ProjectData_struct*ProjLoad_prepareProjectFromTemplate(const char*category, const char*templateName)
{
	ProjectData_struct*projDataStruct = ProjLoad_loadProjectDataFromTemplate(category, templateName);
	if(projDataStruct==NULL)
	{
		return NULL;
	}
	ProjectData&projData = *((ProjectData*)ProjectData_getData(projDataStruct));
	
	//path variables
	String execDir = FileTools_getExecutableDirectory();
	String homeDir = getenv("HOME");
	String templateRoot = execDir + "/Project Templates/" + category + '/' + templateName;
	const String&savedProjectsRoot = savedProjectsFolder;
	
	//create the project info fields
	String var_projectName = ProjLoad_getIntendedProjectNameField();
	String var_authorName = ProjLoad_getIntendedProjectAuthorField();
	String var_projectNameAsIdentifier = ProjectData::createBundlenameFromName(var_projectName);
	String var_executableName = var_projectNameAsIdentifier;
	String var_productName = var_projectNameAsIdentifier;
	
	//finds and replaces instances of project variables withing the ProjectData object
	
	String field = projData.getName();
	ProjLoad_fillProjectVarsInString(field, var_projectName,var_authorName,var_projectNameAsIdentifier,var_executableName,var_productName);
	projData.setName(field);
	
	field = projData.getAuthor();
	ProjLoad_fillProjectVarsInString(field, var_projectName,var_authorName,var_projectNameAsIdentifier,var_executableName,var_productName);
	projData.setAuthor(field);
	
	field = projData.getBundleIdentifier();
	ProjLoad_fillProjectVarsInString(field, var_projectName,var_authorName,var_projectNameAsIdentifier,var_executableName,var_productName);
	projData.setBundleIdentifier(field);
	
	field = projData.getExecutableName();
	ProjLoad_fillProjectVarsInString(field, var_projectName,var_authorName,var_projectNameAsIdentifier,var_executableName,var_productName);
	projData.setExecutableName(field);
	
	field = projData.getProductName();
	ProjLoad_fillProjectVarsInString(field, var_projectName,var_authorName,var_projectNameAsIdentifier,var_executableName,var_productName);
	projData.setProductName(field);
	
	//set save folder name
	String saveFolder = projData.getName();
	String projectName = projData.getName();
	
	ArrayList<String> currentProjects = FileTools::getFoldersInDirectory(savedProjectsRoot, false);
	
	int matchChecks = 0;
	//make sure there aren't any project folders with the same folder name
	//rename save folder if necessary (ex: "miniCode" becomes "miniCode (1)" or "miniCode (2)" etc.)
	bool matchedName = false;
	do
	{
		matchedName = false;
		for(int i=0; i<currentProjects.size(); i++)
		{
			if(saveFolder.equals(currentProjects.get(i)))
			{
				matchedName = true;
				i = currentProjects.size();
			}
		}
		
		if(matchedName)
		{
			matchChecks++;
			saveFolder = projectName + " (" + matchChecks + ')';
		}
	}
	while(matchedName);
	
	projData.setFolderName(saveFolder);
	String projectRoot = savedProjectsRoot + '/' + saveFolder;
	
	//create the project folder
	bool didMakeDirectory = FileTools::createDirectory(projectRoot);
	//checks for errors making the save folder
	if(!didMakeDirectory)
	{
		showSimpleMessageBox("", (String)"Error creating project folder " + projectRoot);
		ProjectData_destroyInstance(projDataStruct);
		return NULL;
	}
	
	//loop to create the subfolders inside the project folder
	const char*projFolders[4] = {"src", "res", "ext", "bin"};
	for(int i=0; i<4; i++)
	{
		//create the subfolder
		didMakeDirectory = FileTools::createDirectory(projectRoot + '/' + projFolders[i]);
		//checks for errors making the subfolder
		if(!didMakeDirectory)
		{
			showSimpleMessageBox("", (String)"Error creating " + projFolders[i] + " folder in project folder " + projectRoot);
			ProjectData_destroyInstance(projDataStruct);
			return NULL;
		}
	}
	
	//go through source files, load the files, replace instances within the files, save the files (or attempt to)
	ProjLoad_fillProjectVarsInSourceFiles(projData.getSourceFiles(), templateRoot+"/src", projectRoot+"/src", "",
										  var_projectName,var_authorName,var_projectNameAsIdentifier,var_executableName,var_productName);
	
	//go through resource files, save the files with renamed file name (or attempt to)
	ProjLoad_fillProjectVarsInResourceFiles(projData.getResourceFiles(), templateRoot+"/res", projectRoot+"/res", "",
											var_projectName,var_authorName,var_projectNameAsIdentifier,var_executableName,var_productName);
	
	//copy include and lib dirs
	bool success = FileTools::copyFolder(templateRoot + "/ext", projectRoot + "/ext");
	if(!success)
	{
		showSimpleMessageBox("Error creating project", "Problem occured copying \"ext\" folder");
	}
	
	FileTools::copyFile(templateRoot + "/project.plist", projectRoot + "/project.plist");
	success = ProjectData_saveProjectPlist(projDataStruct);
	if(!success)
	{
		showSimpleMessageBox("Error creating project", "Problem occurred saving project.plist");
	}
	
	ProjectSettings_struct projSettings = ProjectData_getProjectSettings(projDataStruct);
	success = ProjectSettings_saveSettingsPlist(&projSettings, projDataStruct);
	if(!success)
	{
		showSimpleMessageBox("Error", (String)"Unable to save settings.plist for project " + projData.getFolderName());
	}
	
	return projDataStruct;
}

const char* ProjLoad_getSavedProjectsFolder()
{
	return savedProjectsFolder;
}

const char* ProjLoad_getSavedProjectsSubfolder()
{
	return savedProjectsSubfolder;
}

