
#include "Subprocess.h"
#include "Thread.h"
#include "String.h"
#include "popenRWE.h"

class SubprocessFileThread : public Thread
{
private:
	bool done;
	bool ending;
	bool readByLine;
	FILE* outFile;
	int outFileDes;
	void* data;
	
	SubprocessOutputHandler outputHandle;
	
public:
	SubprocessFileThread(SubprocessOutputHandler outputHandle, void*data, bool readByLine)
	{
		outFile = NULL;
		this->outputHandle = outputHandle;
		this->data = data;
		ending = false;
		done = false;
		this->readByLine = readByLine;
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
	
	void exec(FILE* file, int fileDes)
	{
		outFile = file;
		outFileDes = fileDes;
		if(outFile!=NULL)
		{
			start();
		}
	}
	
	virtual void run()
	{
		if(readByLine)
		{
			char buffer[1028];
			while(/*!ending && */fgets(buffer, 1028, outFile) != NULL)
			{
				if(outputHandle!=NULL)
				{
					outputHandle(data, buffer);
				}
			}
		}
		else
		{
			char buffer[1028];
			bool finished = false;
			while(/*!ending && */!finished)
			{
				
				int totalRead = read(outFileDes, buffer, 1028);
				//int errnum = errno;
				if(totalRead==-1)
				{
					//
				}
				else if(totalRead==0)
				{
					finished = true;
				}
				else
				{
					buffer[totalRead] = '\0';
					if(outputHandle!=NULL)
					{
						outputHandle(data, buffer);
					}
				}
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
	friend int subprocess_execute(const char*,void*,SubprocessOutputHandler,SubprocessOutputHandler,SubprocessResultHandler, bool, int*);
	friend void subprocess_execute(const char*,void*,SubprocessOutputHandler,SubprocessOutputHandler,SubprocessResultHandler, bool, int*, bool);
private:
	String command;
	FILE* outFile[3];
	int rwePipe[3];
	void* data;
	int pid;
	
	bool selfDestruct;
	bool readByLine;
	
	SubprocessFileThread* errorThread;
	
	SubprocessOutputHandler outputHandle;
	SubprocessOutputHandler errorHandle;
	SubprocessResultHandler resultHandle;
	
public:
	SubprocessThread(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle, bool selfDestruct, bool readByLine)
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
		this->readByLine = readByLine;
	}
	
	virtual ~SubprocessThread()
	{
		//
	}
	
	bool exec()
	{
		errorThread = new SubprocessFileThread(errorHandle, data, readByLine);
		pid = popenRWE(rwePipe, command);
		if(pid!=-1)
		{
			outFile[STDIN_FILENO] = fdopen(rwePipe[STDIN_FILENO], "w");
			setbuf(outFile[STDIN_FILENO], NULL);
			outFile[STDOUT_FILENO] = fdopen(rwePipe[STDOUT_FILENO], "r");
			//setbuf(outFile[STDOUT_FILENO], NULL);
			outFile[STDERR_FILENO] = fdopen(rwePipe[STDERR_FILENO], "r");
			//setbuf(outFile[STDERR_FILENO], NULL);
			errorThread->exec(outFile[STDERR_FILENO], rwePipe[STDERR_FILENO]);
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
		if(readByLine)
		{
			char buffer[1028];
			while(fgets(buffer, 1028, outFile[STDOUT_FILENO]) != NULL)
			{
				if(outputHandle!=NULL)
				{
					outputHandle(data, buffer);
				}
			}
		}
		else
		{
			char buffer[1028];
			bool finished = false;
			while(!finished)
			{
				
				int totalRead = read(rwePipe[STDOUT_FILENO], buffer, 1028);
				//int errnum = errno;
				if(totalRead==-1)
				{
					//
				}
				else if(totalRead==0)
				{
					finished = true;
				}
				else
				{
					buffer[totalRead]='\0';
					if(outputHandle!=NULL)
					{
						outputHandle(data, buffer);
					}
				}
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

void subprocess_execute(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle, bool readByLine, int*pid, bool wait)
{
	if(!wait)
	{
		subprocess_execute(command, data, outputHandle, errorHandle, resultHandle, readByLine, pid);
	}
	else
	{
		SubprocessThread* process = new SubprocessThread(command, data, outputHandle, errorHandle, resultHandle, false, readByLine);
		bool success = process->exec();
		if(!success)
		{
			if(pid!=NULL)
			{
				*pid = -1;
			}
			delete process;
		}
		else
		{
			if(pid!=NULL)
			{
				*pid = process->pid;
			}
			process->join();
			delete process;
		}
	}
}

int subprocess_execute(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle, bool readByLine, int*pid)
{
	SubprocessThread* process = new SubprocessThread(command, data, outputHandle, errorHandle, resultHandle, true, readByLine);
	bool success = process->exec();
	if(!success)
	{
		delete process;
		if(pid!=NULL)
		{
			*pid = -1;
		}
		return -1;
	}
	if(pid!=NULL)
	{
		*pid = process->pid;
	}
	return process->rwePipe[STDIN_FILENO];
}
