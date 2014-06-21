
#include "../Util/String.h"
#include "../Util/ArrayList.h"

#pragma once

class ProjectSettings
{
private:
	String sdk;
	ArrayList<String> assemblerFlags;
	ArrayList<String> compilerFlags;
	ArrayList<String> disabledWarnings;
	
public:
	ProjectSettings();
	ProjectSettings(const ProjectSettings&projSettings);
	~ProjectSettings();
	
	ProjectSettings& operator=(const ProjectSettings&projSettings);
	
	void setSDK(const String&sdk);
	
	void addAssemblerFlag(const String&flag);
	void addCompilerFlag(const String&flag);
	void addDisabledWarning(const String&warning);
	
	const String& getSDK() const;
	
	ArrayList<String>& getAssemblerFlags();
	const ArrayList<String>& getAssemblerFlags() const;
	ArrayList<String>& getCompilerFlags();
	const ArrayList<String>& getCompilerFlags() const;
	ArrayList<String>& getDisabledWarnings();
	const ArrayList<String>& getDisabledWarnings() const;
};