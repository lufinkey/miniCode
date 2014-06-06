
#include "FileOperationThread.h"
#include "Thread.h"
#include "FileTools.h"
#include "../ObjCBridge/ObjCBridge.h"

class FileOperationThread : public Thread
{
private:
	String src;
	String dst;
	FileOperationType type;
	void* data;
	FileOperationFinishCallback callback;
	int result;
	
public:
	FileOperationThread(const String&src, const String&dst, FileOperationType type, void* data, FileOperationFinishCallback callback)
	{
		this->src = src;
		this->dst = dst;
		this->type = type;
		this->data = data;
		this->callback = callback;
		result = 0;
	}
	
	virtual ~FileOperationThread()
	{
		//
	}
	
	virtual void run()
	{
		switch(type)
		{
			case FILEOPERATION_MOVE:
			{
				bool success = FileTools::rename(src, dst);
				if(success)
				{
					result = 0;
				}
				else
				{
					result = -1;
				}
			}
			break;
			
			case FILEOPERATION_DELETE:
			{
				bool success = FileTools::deleteFromFilesystem(src);
				if(success)
				{
					result = 0;
				}
				else
				{
					result = -1;
				}
			}
			break;
			
			case FILEOPERATION_COPYFILE:
			{
				bool success = FileTools::copyFile(src, dst);
				if(success)
				{
					result = 0;
				}
				else
				{
					result = -1;
				}
			}
			break;
			
			case FILEOPERATION_COPYFOLDER:
			{
				bool success = FileTools::copyFolder(src, dst);
				if(success)
				{
					result = 0;
				}
				else
				{
					result = -1;
				}
			}
			break;
		}
	}
	
	virtual void finish()
	{
		if(callback!=NULL)
		{
			callback(data, result);
		}
		
		delete this;
	}
};


void performFileOperationThread(const char*src, const char*dst, FileOperationType type, void*data, FileOperationFinishCallback callback)
{
	String srcString;
	if(src!=NULL)
	{
		srcString = src;
	}
	String dstString;
	if(dst!=NULL)
	{
		dstString = dst;
	}
	FileOperationThread* fileThread = new FileOperationThread(srcString, dstString, type, data, callback);
	fileThread->start();
}


