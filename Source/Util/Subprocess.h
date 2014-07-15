
#include <cstdio>

#pragma once

typedef void (*SubprocessOutputHandler)(void*, const char*);
typedef void (*SubprocessResultHandler)(void*, int);

void subprocess_execute(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle, bool readByLine, int*pid, bool wait);
FILE* subprocess_execute(const char*command, void*data, SubprocessOutputHandler outputHandle, SubprocessOutputHandler errorHandle, SubprocessResultHandler resultHandle, bool readByLine, int*pid);
