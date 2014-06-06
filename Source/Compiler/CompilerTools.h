
#include "../ObjCBridge/ObjCBridge.h"

#pragma once

typedef enum
{
	COMPILER_UNKNOWN,
	COMPILER_OUTPUT,
	COMPILER_ERROR,
	COMPILER_RESULT
} CompilerOutputType;


typedef struct
{
	void* data;
} CompilerOutputLine_struct;

CompilerOutputLine_struct CompilerOutputLine_createWithData(void*data);

CompilerOutputType CompilerOutputLine_getType(CompilerOutputLine_struct*outputLine);
const char* CompilerOutputLine_getOutput(CompilerOutputLine_struct*outputLine);
StringList_struct CompilerOutputLine_getSupplementaryOutput(CompilerOutputLine_struct*outputLine);
int CompilerOutputLine_getResult(CompilerOutputLine_struct*outputLine);
const char* CompilerOutputLine_getFileName(CompilerOutputLine_struct*outputLine);
unsigned int CompilerOutputLine_getLine(CompilerOutputLine_struct*outputLine);
unsigned int CompilerOutputLine_getOffset(CompilerOutputLine_struct*outputLine);
const char* CompilerOutputLine_getErrorType(CompilerOutputLine_struct*outputLine);
const char* CompilerOutputLine_getMessage(CompilerOutputLine_struct*outputLine);



typedef struct
{
	void* data;
} CompilerOrganizer_struct;

typedef void (*CompilerOrganizer_OutputRecievedCallback)(void*, CompilerOutputLine_struct);
typedef void (*CompilerOrganizer_StatusCallback)(void*, const char*);
typedef void (*CompilerOrganizer_FinishCallback)(void*, int);

CompilerOrganizer_struct* CompilerOrganizer_createInstance(ProjectData_struct*projData);
void CompilerOrganizer_destroyInstance(CompilerOrganizer_struct*organizer);

bool CompilerOrganizer_isRunning(CompilerOrganizer_struct*organizer);
void CompilerOrganizer_runCompiler(CompilerOrganizer_struct*organizer);

const char* CompilerOrganizer_getCurrentStatus(CompilerOrganizer_struct*organizer);

void CompilerOrganizer_setCallbacks(CompilerOrganizer_struct*organizer,
									CompilerOrganizer_OutputRecievedCallback outputRecievedCallback,
									CompilerOrganizer_FinishCallback finishCallback,
									CompilerOrganizer_StatusCallback statusCallback, void*data);

unsigned int CompilerOrganizer_totalFiles(CompilerOrganizer_struct*organizer);
unsigned int CompilerOrganizer_totalErrors(CompilerOrganizer_struct*organizer, const char* fileName);
unsigned int CompilerOrganizer_totalErrors(CompilerOrganizer_struct*organizer, unsigned int index);
const char* CompilerOrganizer_getFile(CompilerOrganizer_struct*organizer, unsigned int index);
CompilerOutputLine_struct CompilerOrganizer_getError(CompilerOrganizer_struct*organizer, const char* fileName, unsigned int index);
CompilerOutputLine_struct CompilerOrganizer_getError(CompilerOrganizer_struct*organizer, unsigned int fileIndex, unsigned int errorIndex);
void CompilerOrganizer_clear(CompilerOrganizer_struct*organizer);



//CompilerTools

typedef void (*InstallThreadFinishCallback)(void*, bool);
typedef void (*CopyResourcesThreadFinishCallback)(void*, bool);

void CompilerTools_cleanOutput(ProjectData_struct* project);
void CompilerTools_clearInfoPlist(ProjectData_struct*project);
void CompilerTools_fillInfoPlist(ProjectData_struct*project);
void CompilerTools_copyResources(ProjectData_struct*project, CopyResourcesThreadFinishCallback callback, void*data);
void CompilerTools_installApplication(ProjectData_struct*project, InstallThreadFinishCallback callback, void*data);
void CompilerTools_runApplication(const char* bundleID);


