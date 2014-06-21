
#include "GlobalPreferences.h"
#include "../Util/String.h"
#include "../ProjectLoad/ProjLoadTools.h"
#include "../Util/FileTools.h"
#include <stdlib.h>

#include "TargetConditionals.h"

#if (TARGET_IPHONE_SIMULATOR)
static String sdkFolder = "/Developer/Platforms/iPhoneOS.platform/Developer/SDKs";
#else
static String sdkFolder = "/var/stash/Developer/SDKs";
#endif

static String bundleID = "com.BrokenPhysics.miniCode";

static String defaultSDK = "";
static String codeEditorFont = "Helvetica";
static unsigned int codeEditorFontSize = 12;

static double currentVersion = 1.010;
static String versionMessage = "Welcome to miniCode! A lot of work has been put into this app, so I hope you enjoy it. "
								"If you find any bugs, please email me at luisfinke@gmail.com so I can fix them.";

static ArrayList<String> installedApps;


bool GlobalPreferences_load()
{
	String settingsPath = (String)getenv("HOME") + "/Library/Preferences/" + bundleID + ".plist";
	void*dict = ProjLoad_loadAllocatedPlist(settingsPath);
	if(dict!=NULL)
	{
		void* sdk = NSDictionary_objectForKey(dict, "DefaultSDK");
		if(sdk!=NULL)
		{
			defaultSDK = NSString_UTF8String(sdk);
			//make sure sdk is valid
			if(!Global_checkSDKFolderValid(defaultSDK))
			{
				defaultSDK = "";
			}
		}
		
		void* editorFont = NSDictionary_objectForKey(dict, "EditorFont");
		if(editorFont!=NULL)
		{
			codeEditorFont = NSString_UTF8String(editorFont);
			//TODO check and make sure font is valid
		}
		
		void* editorFontSize = NSDictionary_objectForKey(dict, "EditorFontSize");
		if(editorFontSize!=NULL)
		{
			codeEditorFontSize = NSNumber_intValue(editorFontSize);
			if(codeEditorFontSize < CODEEDITOR_MINFONTSIZE)
			{
				codeEditorFontSize = CODEEDITOR_MINFONTSIZE;
			}
			else if(codeEditorFontSize > CODEEDITOR_MAXFONTSIZE)
			{
				codeEditorFontSize = CODEEDITOR_MAXFONTSIZE;
			}
		}
		
		void* installedAppsArray = NSDictionary_objectForKey(dict, "InstalledApps");
		if(installedAppsArray!=NULL)
		{
			installedApps.clear();
			for(unsigned int i=0; i<NSArray_count(installedAppsArray); i++)
			{
				void*appName = NSArray_objectAtIndex(installedAppsArray, i);
				installedApps.add(NSString_UTF8String(appName));
			}
		}
		
		bool resave = false;
		void* latestVersion = NSDictionary_objectForKey(dict, "LatestVersion");
		if(latestVersion!=NULL)
		{
			double version = NSNumber_doubleValue(latestVersion);
			if(version!=currentVersion)
			{
				resave = true;
				showSimpleMessageBox("miniCode", versionMessage);
			}
		}
		else
		{
			resave = true;
			showSimpleMessageBox("miniCode", versionMessage);
		}
		
		id_release(dict);
		if(resave)
		{
			return GlobalPreferences_save();
		}
		return true;
	}
	else
	{
		showSimpleMessageBox("miniCode", versionMessage);
		return GlobalPreferences_save();
	}
	return false;
}

bool GlobalPreferences_save()
{
	String settingsPath = (String)getenv("HOME") + "/Library/Preferences/" + bundleID + ".plist";
	void*dict = ProjLoad_loadAllocatedPlist(settingsPath);
	if(dict==NULL)
	{
		dict = NSMutableDictionary_alloc_init();
	}
	if(dict!=NULL)
	{
		void*sdk = NSString_stringWithUTF8String(defaultSDK);
		NSMutableDictionary_setObjectForKey(dict, sdk, "DefaultSDK");
		
		void*editorFont = NSString_stringWithUTF8String(codeEditorFont);
		NSMutableDictionary_setObjectForKey(dict, editorFont, "EditorFont");
		
		void*editorFontSize = NSNumber_numberWithInt((int)codeEditorFontSize);
		NSMutableDictionary_setObjectForKey(dict, editorFontSize, "EditorFontSize");
		
		void*installedAppsArray = NSMutableArray_alloc_init();
		for(int i=0; i<installedApps.size(); i++)
		{
			void*appName = NSString_stringWithUTF8String(installedApps.get(i));
			NSMutableArray_addObject(installedAppsArray, appName);
		}
		NSMutableDictionary_setObjectForKey(dict, installedAppsArray, "InstalledApps");
		id_release(installedAppsArray);
		
		void*latestVersion = NSNumber_numberWithDouble(currentVersion);
		NSMutableDictionary_setObjectForKey(dict, latestVersion, "LatestVersion");
		
		String settingsPath = (String)getenv("HOME") + "/Library/Preferences/" + bundleID + ".plist";
		bool success = ProjLoad_savePlist(dict, settingsPath);
		id_release(dict);
		return success;
	}
	return false;
}

void GlobalPreferences_setDefaultSDK(const char*sdk)
{
	defaultSDK = sdk;
}

void GlobalPreferences_setCodeEditorFont(const char*font)
{
	codeEditorFont = font;
}

void GlobalPreferences_setCodeEditorFontSize(unsigned int size)
{
	if(size>=CODEEDITOR_MINFONTSIZE && size<=CODEEDITOR_MAXFONTSIZE)
	{
		codeEditorFontSize = size;
	}
}

void GlobalPreferences_installedApps_add(const char* appName)
{
	String appNameString = appName;
	for(int i=0; i<installedApps.size(); i++)
	{
		if(appNameString.equals(installedApps.get(i)))
		{
			return;
		}
	}
	installedApps.add(appNameString);
	GlobalPreferences_save();
}

const char* GlobalPreferences_getDefaultSDK()
{
	return defaultSDK;
}

const char* GlobalPreferences_getCodeEditorFont()
{
	return codeEditorFont;
}

unsigned int GlobalPreferences_getCodeEditorFontSize()
{
	return codeEditorFontSize;
}

unsigned int GlobalPreferences_installedApps_size()
{
	return (unsigned int)installedApps.size();
}

const char* GlobalPreferences_installedApps_get(unsigned int index)
{
	return installedApps.get((int)index);
}

bool GlobalPreferences_installedApps_contains(const char* appName)
{
	String appNameString = appName;
	for(int i=0; i<installedApps.size(); i++)
	{
		if(appNameString.equals(installedApps.get(i)))
		{
			return true;
		}
	}
	return false;
}

void GlobalPreferences_installedApps_remove(const char* appName)
{
	String appNameString = appName;
	for(int i=0; i<installedApps.size(); i++)
	{
		if(appNameString.equals(installedApps.get(i)))
		{
			installedApps.remove(i);
			return;
		}
	}
}

double Global_getVersion()
{
	return currentVersion;
}

const char* Global_getSDKFolderPath()
{
	return sdkFolder;
}

bool Global_checkSDKFolderValid(const char*folder)
{
	String sdk = folder;
	if(sdk.length()>0)
	{
		int onlyInvalidCharacters = true;
		for(int i=0; i<sdk.length(); i++)
		{
			char c = sdk.charAt(i);
			if(c!='/' && c!='\\' && c!=' ' && c!='?')
			{
				onlyInvalidCharacters = false;
			}
		}
		if(onlyInvalidCharacters)
		{
			return false;
		}
		
		return FileTools::folderExists(sdkFolder + '/' + folder);
	}
	return false;
}
