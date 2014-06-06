
#include "../Util/Thread.h"
#include "CompilerTools.h"
#include "../ProjectData/ProjectData.h"

#pragma once

class CopyResourcesThread : public Thread
{
private:
	ProjectData* projData;
	CopyResourcesThreadFinishCallback callback;
	void* data;
	bool success;
	
public:
	CopyResourcesThread(ProjectData* projData);
	virtual ~CopyResourcesThread();
	
	void setCallback(CopyResourcesThreadFinishCallback callback, void*data);
	
	virtual void run();
	virtual void finish();
};
