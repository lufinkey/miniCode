
#include "Subprocess.h"
#include "Thread.h"
#include "String.h"
#include "popenRWE.h"

class SubprocessFileThread : public Thread
{
private:
	bool done;
	bool ending;
	FILE* outFile;
	void* data;
	
	SubprocessOutputHandler outputHandle;
	
public:
	SubprocessFileThread(SubprocessOutputHandler outputHandle, void*data)
	{
		outFile = NULL;
		this->outputHandle = outputHandle;
		this->data = data;
		ending = false;
		done = false;
	}
	
	virtual ~SubprocessFileThread()
	{
		//
	}
	
	void end()
	{
		ending = true;
	}
	
	bool isDone()
	{
		return done;
	}
	
	void exec(FILE* file)
	{
		outFile = file;
		if(outFile!=NULL)
		{
			start();
		}
	}
	
	virtual void run()
	{
		char buffer[1028];
		while(!ending && fgets(buffer, 1028, outFile) != NULL)
		{
			if(outputHandle!=NULL)
			{
				outputHandle(data, buffer);
			}
		}
	}
	
	virtual void finish()
	{
		done = true;
	}
};

class SubprocessThread : public Thread
{
	friend FILE* subprocess_execute(const char*,void*,SubprocessOutputHandler,SubprocessOutputHandler,SubprocessResultHandler);
	//friend void subprocess_execute(const char*,void*,SubprocessOutputHandler,SubprocessOutputHandler,SubprocessResultHandler, bool);
private:
	String command;
	FILE* outFile[3];
	int rwePipe[3];
	void* data;
	int pid;
	
	bool selfDestruct;
	
	SubprocessFileThread* errorThread;
	
	SubprocessOutputHandler outputHandle;
	SubprocessOutputHandler errorHandle;
	SubprocessResultHandler resultHandle;
	
public:
	SubprocessThread(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle, bool selfDestruct)
	{
		pid = -1;
		outFile[STDIN_FILENO] = NULL;
		outFile[STDOUT_FILENO] = NULL;
		outFile[STDERR_FILENO] = NULL;
		rwePipe[STDIN_FILENO] = 0;
		rwePipe[STDOUT_FILENO] = 0;
		rwePipe[STDERR_FILENO] = 0;
		this->command = command;
		this->data = data;
		this->outputHandle = outputHandle;
		this->errorHandle = errorHandle;
		this->resultHandle = resultHandle;
		errorThread = NULL;
		
		this->selfDestruct = selfDestruct;
	}
	
	virtual ~SubprocessThread()
	{
		//
	}
	
	bool exec()
	{
		errorThread = new SubprocessFileThread(errorHandle, data);
		pid = popenRWE(rwePipe, command);
		if(pid!=-1)
		{
			outFile[STDIN_FILENO] = fdopen(rwePipe[STDIN_FILENO], "w");
			outFile[STDOUT_FILENO] = fdopen(rwePipe[STDOUT_FILENO], "r");
			outFile[STDERR_FILENO] = fdopen(rwePipe[STDERR_FILENO], "r");
			errorThread->exec(outFile[STDERR_FILENO]);
			start();
			return true;
		}
		delete errorThread;
		errorThread = NULL;
		if(outputHandle!=NULL)
		{
			outputHandle(data, "subprocess: error: Unable to start subprocess");
		}
		if(resultHandle!=NULL)
		{
			resultHandle(data, -1);
		}
		return false;
	}
	
	virtual void run()
	{
		char buffer[1028];
		while(fgets(buffer, 1028, outFile[STDOUT_FILENO]) != NULL)
		{
			if(outputHandle!=NULL)
			{
				outputHandle(data, buffer);
			}
		}
		errorThread->end();
		while(!errorThread->isDone())
		{
			sleep(1);
		}
		delete errorThread;
		errorThread = NULL;
		int result = pcloseRWE(pid, rwePipe)/256;
		if(resultHandle!=NULL)
		{
			resultHandle(data, result);
		}
	}
	
	virtual void finish()
	{
		if(selfDestruct)
		{
			delete this;
		}
	}
};

void subprocess_execute(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle, bool wait)
{
	if(!wait)
	{
		subprocess_execute(command, data, outputHandle, errorHandle, resultHandle);
	}
	else
	{
		SubprocessThread* process = new SubprocessThread(command, data, outputHandle, errorHandle, resultHandle, false);
		bool success = process->exec();
		if(!success)
		{
			delete process;
		}
		else
		{
			process->join();
			delete process;
		}
	}
}

FILE* subprocess_execute(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle)
{
	SubprocessThread* process = new SubprocessThread(command, data, outputHandle, errorHandle, resultHandle, true);
	bool success = process->exec();
	if(!success)
	{
		delete process;
		return NULL;
	}
	return process->outFile[STDIN_FILENO];
}
