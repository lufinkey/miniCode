
#include "../Util/ArrayList.h"
#include "../Util/String.h"

#pragma once

class ProjectBuildInfo
{
private:
	ArrayList<String> editedFiles;
	
public:
	ProjectBuildInfo();
	ProjectBuildInfo(const ProjectBuildInfo& buildInfo);
	~ProjectBuildInfo();
	
	ProjectBuildInfo& operator=(const ProjectBuildInfo& buildInfo);
	
	void addEditedFile(const String& file);
	void renameEditedFile(const String& oldFile, const String& newFile);
	void removeEditedFile(const String& file);
	bool hasEditedFile(const String& file);
	
	ArrayList<String>& getEditedFiles();
	const ArrayList<String>& getEditedFiles() const;
};
