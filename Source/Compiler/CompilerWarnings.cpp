
#include "CompilerWarnings.h"
#include "../Util/String.h"
#include "../Util/ArrayList.h"
#include "../Util/FileTools.h"

StringList_struct* loadCompilerWarningList()
{
	String fileContents;
	String filePath = (String)FileTools_getExecutableDirectory() + "/CompilerWarnings.txt";
	
	if(!FileTools::loadFileIntoString(filePath, fileContents))
	{
		return NULL;
	}
	
	String currentLine;
	ArrayList<String>* lines = new ArrayList<String>();
	
	for(int i=0; i<fileContents.length(); i++)
	{
		char c = fileContents.charAt(i);
		if(c<' ')
		{
			if(currentLine.length()>0)
			{
				lines->add(currentLine);
				currentLine.clear();
			}
		}
		else
		{
			currentLine += c;
		}
	}
	
	fileContents.clear();
	
	StringList_struct* list = new StringList_struct();
	list->data = (void*)lines;
	return list;
}
