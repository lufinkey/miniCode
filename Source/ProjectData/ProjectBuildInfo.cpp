
#include "ProjectBuildInfo.h"

ProjectBuildInfo::ProjectBuildInfo()
{
	//
}

ProjectBuildInfo::ProjectBuildInfo(const ProjectBuildInfo& buildInfo)
{
	editedFiles = buildInfo.editedFiles;
}

ProjectBuildInfo::~ProjectBuildInfo()
{
	//
}

ProjectBuildInfo& ProjectBuildInfo::operator=(const ProjectBuildInfo& buildInfo)
{
	editedFiles = buildInfo.editedFiles;
	return *this;
}

void ProjectBuildInfo::addEditedFile(const String& file)
{
	for(int i=0; i<editedFiles.size(); i++)
	{
		if(file.equals(editedFiles.get(i)))
		{
			return;
		}
	}
	editedFiles.add(file);
}

void ProjectBuildInfo::renameEditedFile(const String& oldFile, const String& newFile)
{
	for(int i=0; i<editedFiles.size(); i++)
	{
		if(oldFile.equals(editedFiles.get(i)))
		{
			editedFiles.set(i, newFile);
			return;
		}
	}
}

void ProjectBuildInfo::removeEditedFile(const String& file)
{
	for(int i=0; i<editedFiles.size(); i++)
	{
		if(file.equals(editedFiles.get(i)))
		{
			editedFiles.remove(i);
			return;
		}
	}
}

/*void ProjectBuildInfo::renameFolder(const String& oldFolder, const String& newFolder)
{
	for(int i=0; i<editedFiles.size(); i++)
	{
		String path = editedFiles.get(i);
		if(path.length()>=oldFolder.length())
		{
			bool equal = true;
			for(int j=0; j<oldFolder.length(); j++)
			{
				if(path.charAt(j)!=oldFolder.charAt(j))
				{
					equal = false;
					j=oldFolder.length();
				}
			}
			
			if(equal)
			{
				String newPath = newFolder + path.substring(oldFolder.length());
				editedFiles.set(i, newPath);
			}
		}
	}
}*/

bool ProjectBuildInfo::hasEditedFile(const String& file)
{
	for(int i=0; i<editedFiles.size(); i++)
	{
		if(file.equals(editedFiles.get(i)))
		{
			return true;
		}
	}
	return false;
}

ArrayList<String>& ProjectBuildInfo::getEditedFiles()
{
	return editedFiles;
}

const ArrayList<String>& ProjectBuildInfo::getEditedFiles() const
{
	return editedFiles;
}
