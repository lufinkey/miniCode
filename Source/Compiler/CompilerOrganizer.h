
#include "../Util/String.h"
#include "../Util/ArrayList.h"
#include "../ProjectData/ProjectData.h"
#include "CompilerTools.h"

#pragma once

class CompilerOutputLine
{
	friend class CompilerOrganizer;
private:
	ArrayList<String> supplementaryOutput;
	CompilerOutputType type;

	unsigned int line, offset;
	String output, fileName, errorType, message;
	
	int value;
	
	void addSupplementaryOutput(const String&suppOutput);
	
public:
	CompilerOutputLine();
	CompilerOutputLine(CompilerOutputType type, const String&output);
	CompilerOutputLine(const String&fileName, unsigned int line, unsigned int offset, const String&errorType, const String&message);
	CompilerOutputLine(int result);
	CompilerOutputLine(const CompilerOutputLine& outputLine);
	~CompilerOutputLine();
	
	CompilerOutputLine& operator=(const CompilerOutputLine& outputLine);
	bool equals(const CompilerOutputLine& line);
	
	CompilerOutputType getType();
	const String& getOutput();
	ArrayList<String>& getSupplementaryOutput();
	int getResult();
	const String& getFileName();
	unsigned int getLine();
	unsigned int getOffset();
	const String& getErrorType();
	const String& getMessage();
};



typedef struct
{
	String fileName;
	ArrayList<CompilerOutputLine> lines;
} CompilerErrorList;



class CompilerOrganizer
{
	friend class CompilerThread;
	friend void CompilerThread_MainThreadReciever(void*);
	friend void CompilerThread_OutputReciever(void*, const char*);
	friend void CompilerThread_ErrorReciever(void*, const char*);
private:
	ProjectData* projData;
	
	CompilerOutputLine currentError;
	int expectingSupplementaryOutput;
	
	ArrayList<CompilerErrorList> errorLists;
	
	bool stacking;
	String stackFile;
	
	bool running;
	
	void* data;
	CompilerOrganizer_OutputRecievedCallback outputRecievedCallback;
	CompilerOrganizer_FinishCallback finishCallback;
	CompilerOrganizer_StatusCallback statusCallback;
	
	String status;
	
	void parseOutput(const String& output);
	void parseError(const String& error);
	void handleFileResult(int result);
	
	void handleOutputLine(CompilerOutputLine& outputLine);
	void handleFinish(int result);
	
	void addOutputLine(const String&fileName, CompilerOutputLine& outputLine);
	
public:
	CompilerOrganizer(ProjectData* projData);
	~CompilerOrganizer();
	
	bool isRunning();
	void runCompiler();
	
	void setCurrentStatus(const String& status);
	const String& getCurrentStatus();
	
	void setCallbacks(CompilerOrganizer_OutputRecievedCallback outputRecievedCallback,
					  CompilerOrganizer_FinishCallback finishCallback,
					  CompilerOrganizer_StatusCallback statusCallback, void*data);
	
	unsigned int totalFiles();
	unsigned int totalErrors(const String&fileName);
	unsigned int totalErrors(unsigned int index);
	
	const String& getFile(unsigned int index);
	CompilerOutputLine& getError(const String& fileName, unsigned int index);
	CompilerOutputLine& getError(unsigned int fileIndex, unsigned int errorIndex);
	
	void clear();
};


