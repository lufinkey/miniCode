
#include "CopyResourcesThread.h"
#include "../ProjectLoad/ProjLoadTools.h"
#include "../ObjCBridge/ObjCBridge.h"
#include "../Util/FileTools.h"

typedef struct
{
	void*data;
	bool success;
	CopyResourcesThreadFinishCallback callback;
} CopyResourcesThreadFinishPacket;

void CopyResourcesThread_FinishHandler(void*data)
{
	CopyResourcesThreadFinishPacket* packet = (CopyResourcesThreadFinishPacket*)data;
	packet->callback(packet->data, packet->success);
	delete packet;
}

bool CopyResourcesThread_copyTree(StringTree& tree, const String&srcRoot, const String&dstRoot);

bool CopyResourcesThread_copyTree(StringTree& tree, const String&srcRoot, const String&dstRoot)
{
	ArrayList<String>& members = tree.getMembers();
	for(int i=0; i<members.size(); i++)
	{
		String dstFile = dstRoot + '/' + members.get(i);
		if(!FileTools_fileExists(dstFile))
		{
			String srcFile = srcRoot + '/' + members.get(i);
			bool success = FileTools::copyFile(srcFile, dstFile);
			if(!success)
			{
				return false;
			}
		}
	}
	
	ArrayList<String>& branchNames = tree.getBranchNames();
	for(int i=0; i<branchNames.size(); i++)
	{
		String dstFolder = dstRoot + '/' + branchNames.get(i);
		FileTools::createDirectory(dstFolder);
		String srcFolder = srcRoot + '/' + branchNames.get(i);
		bool success = CopyResourcesThread_copyTree(*tree.getBranch(branchNames.get(i)), srcFolder, dstFolder);
		if(!success)
		{
			return false;
		}
	}
	
	return true;
}

CopyResourcesThread::CopyResourcesThread(ProjectData* projData)
{
	this->projData = projData;
	success = false;
	callback = NULL;
	data = NULL;
}

CopyResourcesThread::~CopyResourcesThread()
{
	//
}

void CopyResourcesThread::setCallback(CopyResourcesThreadFinishCallback callback, void*data)
{
	this->callback = callback;
	this->data = data;
}

void CopyResourcesThread::run()
{
	String resFolder = (String)ProjLoad_getSavedProjectsFolder() + '/' + projData->getFolderName() + "/res";
	String dstFolder = (String)ProjLoad_getSavedProjectsFolder() + '/' + projData->getFolderName() + "/bin/release/" + projData->getProductName() + ".app";
	
	StringTree& resTree = projData->getResourceFiles();
	
	success = CopyResourcesThread_copyTree(resTree, resFolder, dstFolder);
}

void CopyResourcesThread::finish()
{
	if(callback!=NULL)
	{
		CopyResourcesThreadFinishPacket* packet = new CopyResourcesThreadFinishPacket();
		packet->data = data;
		packet->success = success;
		packet->callback = callback;
		runCallbackInMainThread(&CopyResourcesThread_FinishHandler, packet, false);
	}
	delete this;
}
