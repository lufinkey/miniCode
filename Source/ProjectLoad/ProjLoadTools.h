
#include "../ObjCBridge/ObjCBridge.h"

#pragma once

void ProjLoad_createDefaultFolders();

StringList_struct*ProjLoad_loadCategoryList(const char*templatesRoot);
StringList_struct*ProjLoad_loadTemplateList(const char*category, const char*templatesRoot);

//returns UIImage
void*ProjLoad_loadCategoryIcon(const char*category, const char*templatesRoot);
//returns UIImage
void*ProjLoad_loadTemplateIcon(const char*category, const char*templateName, const char*templatesRoot);
//returns NSMutableDictionary
void*ProjLoad_loadTemplateInfo(const char*category, const char*templateName, const char*templatesRoot);

ProjectData_struct*ProjLoad_loadProjectDataFromSavedProject(const char* projectName);
ProjectData_struct*ProjLoad_loadProjectDataFromNSDictionary(void*dict);
ProjectData_struct*ProjLoad_loadProjectDataFromTemplate(const char*category, const char*templateName, const char*templatesRoot);

ProjectSettings_struct*ProjLoad_loadProjectSettingsFromNSDictionary(void*dict);
ProjectBuildInfo_struct*ProjLoad_loadProjectBuildInfoFromNSDictionary(void*dict);

ProjectData_struct*ProjLoad_prepareProjectFromTemplate(const char*category, const char*templateName, const char*templatesRoot);

//gets the inputted name and author fields from the CreateProjectViewController
const char* ProjLoad_getIntendedProjectNameField();
const char* ProjLoad_getIntendedProjectAuthorField();

//returns UIImage
void*ProjLoad_loadUIImage(const char*path);
//returns NSMutableDictionary
void*ProjLoad_loadPlist(const char*path); //relative path is app directory
//returns NSMutableDictionary that must be released
void*ProjLoad_loadAllocatedPlist(const char*path);
//takes NSMutableDictionary, returns true on success, false on failure
bool ProjLoad_savePlist(void*dict, const char*path);

void ProjLoad_getPathWithExecutablePath(char*dest, const char*relPath, unsigned int size);
void ProjLoad_getPathWithHomePath(char*dest, const char*relPath, unsigned int size);
void ProjLoad_getPathWithSavedProjectsPath(char*dest, const char*relPath, unsigned int size);
const char*ProjLoad_getSavedProjectsFolder();
const char*ProjLoad_getSavedProjectsSubfolder();

const char*ProjLoad_getDefaultTemplatesFolder();
const char*ProjLoad_getUserTemplatesFolder();

