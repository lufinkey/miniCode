
#include "../Util/Thread.h"
#include "CompilerOrganizer.h"

#pragma once

class CompilerThread : public Thread
{
	friend void CompilerThread_ResultReciever(void*,int);
	friend void CodesignThread_ResultReciever(void*,int);
private:
	CompilerOrganizer* organizer;
	
	String currentFile;
	int lastResult;
	int result;
	
public:
	CompilerThread(CompilerOrganizer* organizer);
	virtual ~CompilerThread();
	
	virtual void run();
	virtual void finish();
	
	CompilerOrganizer* getOrganizer();
	const String& getCurrentFile();
};
