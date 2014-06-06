
#include "../Util/String.h"
#include "../Util/ArrayList.h"

#pragma once

class ProjectSettings
{
private:
	String sdk;
	ArrayList<String> compilerFlags;
	
public:
	ProjectSettings();
	ProjectSettings(const ProjectSettings&projSettings);
	~ProjectSettings();
	
	ProjectSettings& operator=(const ProjectSettings&projSettings);
	
	void setSDK(const String&sdk);
	
	void addCompilerFlag(const String&flag);
	
	const String& getSDK() const;
	
	ArrayList<String>& getCompilerFlags();
	const ArrayList<String>& getCompilerFlags() const;
};