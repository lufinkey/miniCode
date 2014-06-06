
#include "ProjectSettings.h"
#include "../PreferencesView/GlobalPreferences.h"

ProjectSettings::ProjectSettings()
{
	sdk = GlobalPreferences_getDefaultSDK();
	compilerFlags = ArrayList<String>();
}

ProjectSettings::ProjectSettings(const ProjectSettings&projSettings)
{
	sdk = projSettings.sdk;
	compilerFlags = projSettings.compilerFlags;
}

ProjectSettings::~ProjectSettings()
{
	//
}

ProjectSettings& ProjectSettings::operator=(const ProjectSettings&projSettings)
{
	sdk = projSettings.sdk;
	compilerFlags = projSettings.compilerFlags;
	return *this;
}

void ProjectSettings::setSDK(const String&folder)
{
	sdk = folder;
}

void ProjectSettings::addCompilerFlag(const String&flag)
{
	compilerFlags.add(flag.trim());
}

const String& ProjectSettings::getSDK() const
{
	return sdk;
}

ArrayList<String>& ProjectSettings::getCompilerFlags()
{
	return compilerFlags;
}

const ArrayList<String>& ProjectSettings::getCompilerFlags() const
{
	return compilerFlags;
}


