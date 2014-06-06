

#pragma once


typedef enum
{
	FILEOPERATION_MOVE,
	FILEOPERATION_DELETE,
	FILEOPERATION_COPYFILE,
	FILEOPERATION_COPYFOLDER
} FileOperationType;

typedef void (*FileOperationFinishCallback)(void*, int);

void performFileOperationThread(const char*src, const char*dst, FileOperationType type, void*data, FileOperationFinishCallback callback);

