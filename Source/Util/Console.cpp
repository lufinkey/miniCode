
#include "Console.h"
#include <iostream>
#include "../ObjCBridge/ObjCBridge.h"

String Console::outputFile = "";
bool Console::tofile = false;

void Console::Write(const String&text)
{
	//std::cout << text;
	NS_LogOutput(text);
	if(tofile)
	{
		/*SDL_RWops*file = SDL_RWFromFile(outputFile, "a+");
		SDL_RWseek(file,0,RW_SEEK_END);
		SDL_RWwrite(file,(char*)text,1,text.length());
		SDL_RWclose(file);*/
		FILE*file = fopen(outputFile, "a+");
		fseek(file,0,SEEK_END);
		fwrite((char*)text, 1, text.length(), file);
		fclose(file);
	}
}

void Console::WriteLine(const String&text)
{
	//std::cout << text << std::endl;
	NS_LogOutput(text + '\n');
	if(tofile)
	{
		/*SDL_RWops*file = SDL_RWFromFile(outputFile, "a+");
		SDL_RWseek(file,0,RW_SEEK_END);
		SDL_RWwrite(file,(char*)(text + '\n'),1,text.length()+1);
		SDL_RWclose(file);*/
		FILE*file = fopen(outputFile, "a+");
		fseek(file,0,SEEK_END);
		fwrite((char*)(text+'\n'), 1, text.length()+1, file);
		fclose(file);
	}
}

void Console::OutputToFile(bool toggle, const String&filePath)
{
	tofile = toggle;
	outputFile = (String)getenv("HOME") + "/Documents/" + filePath;
}

String Console::Execute(const String&command, int*returnVal)
{
	FILE* pipe = popen(command, "r");
	if(!pipe)
	{
		return "ERROR";
	}
	char buffer[500];
	String output = "";
	while(!feof(pipe))
	{
		if(fgets(buffer, 500, pipe) != NULL)
		{
			output += buffer;
		}
	}
	int result = pclose(pipe)/256;
	if(returnVal!=NULL)
	{
		*returnVal = result;
	}
	return output;
}