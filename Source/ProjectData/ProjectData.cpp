
#include "ProjectData.h"

bool ProjectData::checkValidString(const String&str)
{
	for(int i=0; i<str.length(); i++)
	{
		char c = str.charAt(i);
		if(!((c>='0' && c<='9') || (c>='a' && c<='z') || (c>='A' && c<='Z') || c=='_' || c=='-' || c=='.' || c==',' || c==' '))
		{
			return false;
		}
	}
	return true;
}

String ProjectData::createBundlenameFromName(const String&name)
{
	String bundleName = "";
	for(int i=0; i<name.length(); i++)
	{
		char c = name.charAt(i);
		if(!((c>='0' && c<='9') || (c>='a' && c<='z') || (c>='A' && c<='Z') || c=='_'))
		{
			if(bundleName.length()!=0)
			{
				if(bundleName.charAt(bundleName.length()-1)!='_')
				{
					bundleName += '_';
				}
			}
			else
			{
				bundleName += '_';
			}
		}
		else
		{
			bundleName += c;
		}
	}
	if(bundleName.equals("") || bundleName.equals("_"))
	{
		bundleName = "ProductName";
	}
	
	return bundleName;
}

ProjectData::ProjectData(const String&name, const String&author)
{
	this->name = name;
	this->author = author;
	
	projType = PROJECTTYPE_APPLICATION;
	device = DEVICE_IPHONE;
	
	String bundleName = createBundlenameFromName(name);
	
	String orgName = "yourcompany";
	
	bundleIdentifier = (String)"com." + orgName + '.' + bundleName;
	executable = bundleName;
	productName = bundleName;
	folderName = bundleName;
	
	settings = ProjectSettings();
}

ProjectData::ProjectData(const ProjectData&projData)
{
	projType = projData.projType;
	device = projData.device;
	
	name = projData.name;
	author = projData.author;
	bundleIdentifier = projData.bundleIdentifier;
	
	executable = projData.executable;
	productName = projData.productName;
	
	frameworks = projData.frameworks;
	
	srcFiles = projData.srcFiles;
	resFiles = projData.resFiles;
	includeDirs = projData.includeDirs;
	libDirs = projData.libDirs;
	
	settings = projData.settings;
	buildInfo = projData.buildInfo;
}

ProjectData::~ProjectData()
{
	//
}

ProjectData& ProjectData::operator=(const ProjectData&projData)
{
	projType = projData.projType;
	device = projData.device;
	
	name = projData.name;
	author = projData.author;
	bundleIdentifier = projData.bundleIdentifier;
	
	executable = projData.executable;
	productName = projData.productName;
	
	frameworks = projData.frameworks;
	
	srcFiles = projData.srcFiles;
	resFiles = projData.resFiles;
	includeDirs = projData.includeDirs;
	libDirs = projData.libDirs;
	
	settings = projData.settings;
	buildInfo = projData.buildInfo;
	
	return *this;
}

void ProjectData::setProjectType(const ProjectType&type)
{
	if(type==PROJECTTYPE_APPLICATION || type==PROJECTTYPE_CONSOLE || type==PROJECTTYPE_DYNAMICLIBRARY || type==PROJECTTYPE_STATICLIBRARY)
	{
		this->projType = type;
	}
}

void ProjectData::setProjectDevice(const ProjectDevice& device)
{
	if(device==DEVICE_IPHONE || device==DEVICE_IPAD || device==DEVICE_ALL)
	{
		this->device = device;
	}
}

void ProjectData::setName(const String&name)
{
	this->name = name;
}

void ProjectData::setAuthor(const String&author)
{
	this->author = author;
}

void ProjectData::setBundleIdentifier(const String&bundleID)
{
	this->bundleIdentifier = bundleID;
}

void ProjectData::setExecutableName(const String&execName)
{
	this->executable = execName;
}

void ProjectData::setProductName(const String&product)
{
	this->productName = product;
}

void ProjectData::setFolderName(const String&folder)
{
	this->folderName = folder;
}

void ProjectData::addFramework(const String&framework)
{
	for(int i=0; i<frameworks.size(); i++)
	{
		if(framework.equals(frameworks.get(i)))
		{
			return;
		}
	}
	frameworks.add(framework);
}

ProjectType ProjectData::getProjectType() const
{
	return projType;
}

ProjectDevice ProjectData::getProjectDevice() const
{
	return device;
}

String ProjectData::getBundleName()
{
	int dotIndex = bundleIdentifier.lastIndexOf('.');
	if(dotIndex==-1)
	{
	return bundleIdentifier;
	}
	return bundleIdentifier.substring(dotIndex+1, bundleIdentifier.length());
}

const String& ProjectData::getName() const
{
	return name;
}

const String& ProjectData::getAuthor() const
{
	return author;
}

const String& ProjectData::getBundleIdentifier() const
{
	return bundleIdentifier;
}

const String& ProjectData::getExecutableName() const
{
	return executable;
}

const String& ProjectData::getProductName() const
{
	return productName;
}

const String& ProjectData::getFolderName() const
{
	return folderName;
}

ArrayList<String>& ProjectData::getFrameworkList()
{
	return frameworks;
}

const ArrayList<String>& ProjectData::getFrameworkList() const
{
	return frameworks;
}

StringTree& ProjectData::getSourceFiles()
{
	return srcFiles;
}

const StringTree& ProjectData::getSourceFiles() const
{
	return srcFiles;
}

StringTree& ProjectData::getResourceFiles()
{
	return resFiles;
}

const StringTree& ProjectData::getResourceFiles() const
{
	return resFiles;
}

ArrayList<String>& ProjectData::getIncludeDirs()
{
	return includeDirs;
}

const ArrayList<String>& ProjectData::getIncludeDirs() const
{
	return includeDirs;
}

ArrayList<String>& ProjectData::getLibDirs()
{
	return libDirs;
}

const ArrayList<String>& ProjectData::getLibDirs() const
{
	return libDirs;
}

ProjectSettings& ProjectData::getProjectSettings()
{
	return settings;
}

const ProjectSettings& ProjectData::getProjectSettings() const
{
	return settings;
}

ProjectBuildInfo& ProjectData::getProjectBuildInfo()
{
	return buildInfo;
}

const ProjectBuildInfo& ProjectData::getProjectBuildInfo() const
{
	return buildInfo;
}

void ProjectData::removeFramework(int index)
{
	frameworks.remove(index);
}

