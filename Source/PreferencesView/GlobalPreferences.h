
#pragma once

#define CODEEDITOR_MINFONTSIZE 4
#define CODEEDITOR_MAXFONTSIZE 64

bool GlobalPreferences_load();
bool GlobalPreferences_save();

void GlobalPreferences_setDefaultSDK(const char*sdk);
void GlobalPreferences_setCodeEditorFont(const char*font);
void GlobalPreferences_setCodeEditorFontSize(unsigned int size);
void GlobalPreferences_enableSyntaxHighlighting(bool toggle);
void GlobalPreferences_installedApps_add(const char* appName);

const char* GlobalPreferences_getDefaultSDK();
const char* GlobalPreferences_getCodeEditorFont();
unsigned int GlobalPreferences_getCodeEditorFontSize();
bool GlobalPreferences_syntaxHighlightingEnabled();
unsigned int GlobalPreferences_installedApps_size();
const char* GlobalPreferences_installedApps_get(unsigned int index);
bool GlobalPreferences_installedApps_contains(const char* appName);
void GlobalPreferences_installedApps_remove(const char* appName);

double Global_getVersion();
const char* Global_getSDKFolderPath();
bool Global_checkSDKFolderValid(const char*folder);

