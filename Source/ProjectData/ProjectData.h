
#include "../Util/StringTree.h"
#include "../ObjCBridge/ObjCBridge.h"
#include "ProjectSettings.h"
#include "ProjectBuildInfo.h"

#pragma once

class ProjectData
{
private:
	ProjectType projType;
	
	String folderName;
	
	String name;
	String author;
	String bundleIdentifier;
	
	String executable;
	String productName;
	
	ArrayList<String> frameworks;
	
	StringTree srcFiles;
	StringTree resFiles;
	ArrayList<String> includeDirs;
	ArrayList<String> libDirs;
	
	ProjectSettings settings;
	ProjectBuildInfo buildInfo;
	
public:
	static bool checkValidString(const String&str);
	static String createBundlenameFromName(const String&name);
	
	ProjectData(const String&name, const String&author);
	ProjectData(const ProjectData&projData);
	~ProjectData();
	
	ProjectData& operator=(const ProjectData&projData);
	
	void setProjectType(const ProjectType&type);
	void setName(const String&name);
	void setAuthor(const String&author);
	void setBundleIdentifier(const String&bundleID);
	void setExecutableName(const String&execName);
	void setProductName(const String&product);
	void setFolderName(const String&folder);
	
	void addFramework(const String&framework);
	
	String getBundleName();
	
	ProjectType getProjectType() const;
	const String& getName() const;
	const String& getAuthor() const;
	const String& getBundleIdentifier() const;
	const String& getExecutableName() const;
	const String& getProductName() const;
	const String& getFolderName() const;
	
	ArrayList<String>& getFrameworkList();
	const ArrayList<String>& getFrameworkList() const;
	StringTree& getSourceFiles();
	const StringTree& getSourceFiles() const;
	StringTree& getResourceFiles();
	const StringTree& getResourceFiles() const;
	ArrayList<String>& getIncludeDirs();
	const ArrayList<String>& getIncludeDirs() const;
	ArrayList<String>& getLibDirs();
	const ArrayList<String>& getLibDirs() const;
	
	ProjectSettings& getProjectSettings();
	const ProjectSettings& getProjectSettings() const;
	
	ProjectBuildInfo& getProjectBuildInfo();
	const ProjectBuildInfo& getProjectBuildInfo() const;
	
	void removeFramework(int index);
};