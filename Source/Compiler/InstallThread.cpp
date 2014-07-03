
#include "InstallThread.h"
#include "../PreferencesView/GlobalPreferences.h"
#include "../ProjectLoad/ProjLoadTools.h"
#include "../Util/FileTools.h"
#include "../Util/Console.h"
#include "../Util/AppManager.h"
#include "../Util/Subprocess.h"
#include <stdlib.h>

#include "TargetConditionals.h"

typedef struct
{
	void*data;
	bool success;
	InstallThreadFinishCallback callback;
} InstallThreadFinishPacket;

void InstallThread_FinishHandler(void*data)
{
	InstallThreadFinishPacket* packet = (InstallThreadFinishPacket*)data;
	packet->callback(packet->data, packet->success);
	delete packet;
}

InstallThread::InstallThread(ProjectData* projData)
{
	this->projData = projData;
	success = false;
	callback = NULL;
	data = NULL;
}

InstallThread::~InstallThread()
{
	//
}

void InstallThread::setCallback(InstallThreadFinishCallback callback, void*data)
{
	this->callback = callback;
	this->data = data;
}

void InstallThread::run()
{
	String productName = projData->getProductName();
	String productFolder = productName + ".app";
	String fixedProductFolder = productFolder;
	
	if(!GlobalPreferences_installedApps_contains(productFolder))
	{
		int counter = 0;
		String fullProductPath = (String)"/Applications/" + fixedProductFolder;
		while(FileTools::folderExists(fullProductPath))
		{
			counter++;
			fixedProductFolder = productName + " (" + counter + ").app";
			fullProductPath = (String)"/Applications/" + fixedProductFolder;
		}
	}
	
	String srcPath = (String)ProjLoad_getSavedProjectsFolder() + '/' + projData->getFolderName() + "/bin/release/" + productFolder;
	String dstPath = fixedProductFolder;
	
	bool needsRefresh = true;
	if(FileTools::folderExists((String)"/Applications/" + fixedProductFolder))
	{
		needsRefresh = false;
	}
	
	success = AppManager_install(srcPath, dstPath);
	
	if(success)
	{
		GlobalPreferences_installedApps_add(fixedProductFolder);
#if !(TARGET_IPHONE_SIMULATOR)
		if(needsRefresh)
		{
			subprocess_execute("uicache", NULL, NULL, NULL, NULL, NULL, true);
		}
#endif
	}
}

void InstallThread::finish()
{
	if(callback!=NULL)
	{
		InstallThreadFinishPacket* packet = new InstallThreadFinishPacket();
		packet->data = data;
		packet->success = success;
		packet->callback = callback;
		runCallbackInMainThread(&InstallThread_FinishHandler, packet, false);
	}
	delete this;
}

