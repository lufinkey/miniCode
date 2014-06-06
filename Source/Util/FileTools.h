
#include "ArrayList.h"
#include "String.h"
#include "StringTree.h"

#pragma once

class FileTools
{
public:
	static ArrayList<String> getFilenamesWithExtension(const String&directory, ArrayList<String>&extensions);
	static ArrayList<String> getFoldersInDirectory(const String&directory, bool hidden=true);
	static ArrayList<String> getFilesInDirectory(const String&directory, bool hidden=true);
	static StringTree getStringTreeFromDirectory(const String&directory, bool hidden=true);
	static void createDirectoriesFromStringTree(const String&directory, const StringTree&tree);
	static unsigned int totalFilesInDirectory(const String&directory, bool hidden=true);
	static bool directoryContainsFiles(const String&directory, bool hidden=true);
	
	static bool createFile(const String&path);
	static bool createDirectory(const String&directory);
	static bool createSymbolicLink(const String&srcPath, const String&dstPath);
	static bool copyFile(const String&src, const String&dest);
	static bool copyFolder(const String&src, const String&dest);
	static bool folderExists(const String&path);
	static bool pathIsFolder(const String&path);
	static bool pathIsFile(const String&path);
	static bool expandPath(const String&path, String&dest);
	static bool deleteFromFilesystem(const String&path);
	static bool rename(const String&oldFile, const String&newFile);
	static bool loadFileIntoString(const String&path, String&str);
	static bool writeStringToFile(const String&path, const String&content);
	static bool appendStringToFile(const String&path, const String&content);
};
