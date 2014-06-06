
#include "../Util/Thread.h"
#include "CompilerTools.h"
#include "../ProjectData/ProjectData.h"

#pragma once

class InstallThread : public Thread
{
private:
	ProjectData* projData;
	InstallThreadFinishCallback callback;
	void*data;
	bool success;
	
public:
	InstallThread(ProjectData* projData);
	virtual ~InstallThread();
	
	void setCallback(InstallThreadFinishCallback callback, void*data);
	
	virtual void run();
	virtual void finish();
};
