
#include "String.h"

#pragma once

class Console
{
private:
	static bool tofile;
	static String outputFile;
public:
	static void Write(const String&text);
	static void WriteLine(const String&text);
	static void OutputToFile(bool toggle, const String&filePath);
	static String Execute(const String&command, int*returnVal=NULL);
};