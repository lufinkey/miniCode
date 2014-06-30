
#include "CompilerThread.h"
#include "../ObjCBridge/ObjCBridge.h"
#include "../Util/FileTools.h"
#include "../Util/Console.h"
#include "../ProjectData/ProjectData.h"
#include "../ProjectLoad/ProjLoadTools.h"
#include "../Util/Subprocess.h"
#include "../PreferencesView/GlobalPreferences.h"

static String clangCommand = "clang";
static String libtoolCommand = "libtool";

const char* sourceTypes[7] = {"cpp", "c", "cc", "m", "mm", "a", "o"};

ArrayList<String> CompilerThread_getSourceTypes()
{
	ArrayList<String> srcTypesList;
	for(int i=0; i<7; i++)
	{
		srcTypesList.add(sourceTypes[i]);
	}
	return srcTypesList;
}

typedef enum
{
	COMPILERPACKET_OUTPUT,
	COMPILERPACKET_ERROR,
	COMPILERPACKET_RESULT,
	COMPILERPACKET_FINISHRESULT,
	COMPILERPACKET_STATUSCHANGE
} CompilerThread_OutputPacketType;

typedef struct
{
	CompilerOrganizer* organizer;
	
	CompilerThread_OutputPacketType type;
	String file;
	String string;
	int value;
} CompilerThread_OutputPacket;

void CompilerThread_MainThreadReciever(void*data)
{
	CompilerThread_OutputPacket* packet = (CompilerThread_OutputPacket*)data;
	if(packet->type == COMPILERPACKET_OUTPUT)
	{
		packet->organizer->parseOutput(packet->string);
	}
	else if(packet->type == COMPILERPACKET_ERROR)
	{
		packet->organizer->parseError(packet->string);
	}
	else if(packet->type == COMPILERPACKET_RESULT)
	{
		packet->organizer->handleFileResult(packet->value);
	}
	else if(packet->type == COMPILERPACKET_FINISHRESULT)
	{
		packet->organizer->handleFinish(packet->value);
	}
	else if(packet->type == COMPILERPACKET_STATUSCHANGE)
	{
		packet->organizer->setCurrentStatus(packet->string);
	}
	delete packet;
}

void CompilerThread_OutputReciever(void*data, const char*output)
{
	CompilerThread* thread = (CompilerThread*)data;
	
	const String& currentFile = thread->getCurrentFile();
	if(currentFile.length()>0)
	{
		String fullPath = (String)ProjLoad_getSavedProjectsFolder() + '/' + thread->getOrganizer()->projData->getFolderName();
		fullPath += (String)"/bin/build/" + currentFile + ".output";
		FileTools::appendStringToFile(fullPath, (String)"stdout: " + output);
	}
	
	CompilerThread_OutputPacket* packet = new CompilerThread_OutputPacket();
	packet->organizer = thread->getOrganizer();
	packet->type = COMPILERPACKET_OUTPUT;
	packet->string = output;
	packet->value = 0;
	
	runCallbackInMainThread(&CompilerThread_MainThreadReciever, packet, false);
}

void CompilerThread_ErrorReciever(void*data, const char*error)
{
	CompilerThread* thread = (CompilerThread*)data;
	
	const String& currentFile = thread->getCurrentFile();
	if(currentFile.length()>0)
	{
		String fullPath = (String)ProjLoad_getSavedProjectsFolder() + '/' + thread->getOrganizer()->projData->getFolderName();
		fullPath += (String)"/bin/build/" + currentFile + ".output";
		FileTools::appendStringToFile(fullPath, (String)"stderr: " + error);
	}
	
	CompilerThread_OutputPacket* packet = new CompilerThread_OutputPacket();
	packet->organizer = thread->getOrganizer();
	packet->type = COMPILERPACKET_ERROR;
	packet->string = error;
	packet->value = 0;
	
	runCallbackInMainThread(&CompilerThread_MainThreadReciever, packet, false);
}

void CompilerThread_ResultReciever(void*data, int result)
{
	CompilerThread* thread = (CompilerThread*)data;
	thread->lastResult = result;
	
	CompilerThread_OutputPacket* packet = new CompilerThread_OutputPacket();
	packet->organizer = thread->getOrganizer();
	packet->type = COMPILERPACKET_RESULT;
	packet->string = "";
	packet->value = result;
	
	runCallbackInMainThread(&CompilerThread_MainThreadReciever, packet, false);
}

void CompilerThread_FinishReciever(CompilerThread* thread, int result)
{
	CompilerThread_OutputPacket* packet = new CompilerThread_OutputPacket();
	packet->organizer = thread->getOrganizer();
	packet->type = COMPILERPACKET_FINISHRESULT;
	packet->string = "";
	packet->value = result;
	
	runCallbackInMainThread(&CompilerThread_MainThreadReciever, packet, false);
}

void CompilerThread_ChangeStatus(CompilerThread* thread, const String& status)
{
	CompilerThread_OutputPacket* packet = new CompilerThread_OutputPacket();
	packet->organizer = thread->getOrganizer();
	packet->type = COMPILERPACKET_STATUSCHANGE;
	packet->string = status;
	packet->value = 0;
	
	runCallbackInMainThread(&CompilerThread_MainThreadReciever, packet, false);
}

void CodesignThread_ResultReciever(void*data, int result)
{
	CompilerThread* thread = (CompilerThread*)data;
	thread->lastResult = result;
}

typedef struct
{
	String outputFile;
	String sourceFile;
	ArrayList<String> dependencies;
} CompilerThread_FileDependencyList;

String CompilerThread_createAssembleString(ProjectData& projData, const String& file, const String& outputFile, const String& dependencyFile);
String CompilerThread_createCompileString(ProjectData& projData, const ArrayList<String>& inputFiles, const String& outputFile);
String CompilerThread_createLibtoolString(ProjectData& projData, const ArrayList<String>& inputFiles, const String& outputFile);
bool CompilerThread_stringExistsAtIndex(const String& str, const String&cmp, int index);
String CompilerThread_getExtensionForFilename(const String& fileName);
CompilerThread_FileDependencyList* CompilerThread_parseDependencyFile(const String& file, const String& sourceFile, bool relativeOnly, const String& filter);

CompilerThread::CompilerThread(CompilerOrganizer* organizer)
{
	this->organizer = organizer;
	currentFile = "";
	lastResult = 0;
	result = 0;
}

CompilerThread::~CompilerThread()
{
	//
}

void CompilerThread::run()
{
	currentFile = "";
	lastResult = 0;
	result = 0;
	
	ProjectData& projData = *(organizer->projData);
	ProjectData_struct projDataStruct = ProjectData_createWithData(&projData);
	
	ProjectBuildInfo& projBuildInfo = projData.getProjectBuildInfo();
	ProjectBuildInfo_struct projBuildInfoStruct = ProjectBuildInfo_createWithData(&projBuildInfo);
	
	StringTree& sourceFiles = projData.getSourceFiles();
	ArrayList<String> sourceFilePaths = sourceFiles.getPaths();
	
	CompilerThread_ChangeStatus(this, "Preparing Directories...");
	String projectRoot = (String)ProjLoad_getSavedProjectsFolder() + '/' + projData.getFolderName();
	String binFolder = projectRoot + "/bin";
	FileTools::createDirectory(binFolder);
	String buildFolder = binFolder + "/build";
	FileTools::createDirectory(buildFolder);
	String releaseFolder = binFolder + "/release";
	FileTools::createDirectory(releaseFolder);
	String srcFolder = projectRoot + "/src";
	
	FileTools::createDirectoriesFromStringTree(buildFolder, sourceFiles);
	
	CompilerThread_ChangeStatus(this, "Checking Dependencies...");
	ArrayList<String> needsCompiling;
	ArrayList<String> fakeCompiling;
	
	//Check which files need compiling and which ones do not
	for(int i=0; i<sourceFilePaths.size(); i++)
	{
		String relPath = sourceFilePaths.get(i);
		int dotIndex = relPath.lastIndexOf('.');
		if(dotIndex!=-1)
		{
			if(!CompilerThread_stringExistsAtIndex(relPath, ".h", dotIndex) && !CompilerThread_stringExistsAtIndex(relPath, ".H", dotIndex))
			//if file is not a header file
			{
				String outFullPath = buildFolder + '/' + relPath + ".o";
				if(projBuildInfo.hasEditedFile(relPath))
				{
					needsCompiling.add(relPath);
				}
				else if(!FileTools_fileExists(outFullPath))
				{
					needsCompiling.add(relPath);
				}
				else
				{
					String depFullPath = buildFolder + '/' + relPath + ".d";
					String srcFullPath = srcFolder + '/' + relPath;
					CompilerThread_FileDependencyList* depList = CompilerThread_parseDependencyFile(depFullPath, srcFullPath, true, srcFolder);
					if(depList!=NULL)
					{
						bool pleaseCompile = false;
						for(int i=0; i<depList->dependencies.size(); i++)
						{
							if(projBuildInfo.hasEditedFile(depList->dependencies.get(i)))
							{
								pleaseCompile = true;
								i = depList->dependencies.size();
							}
						}
						
						if(pleaseCompile)
						{
							needsCompiling.add(relPath);
						}
						else
						{
							fakeCompiling.add(relPath);
						}
					}
					else
					{
						fakeCompiling.add(relPath);
					}
					delete depList;
				}
			}
		}
	}
	
	//"Fake" Compile already compiled files (load compile output from file)
	currentFile = "";
	for(int i=0; i<fakeCompiling.size(); i++)
	{
		String relPath = fakeCompiling.get(i);
		
		CompilerThread_ChangeStatus(this, (String)"Reading /bin/build/" + relPath + ".output");
		
		String fullPath = buildFolder + '/' + relPath + ".output";
		
		FILE* file = fopen(fullPath, "r");
		if(file!=NULL)
		{
			char* currentLine = (char*)malloc(1024);
			bool success = true;
			while(!feof(file) && success)
			{
				if(fgets(currentLine, 1024, file)!=NULL)
				{
					String line = currentLine;
					if(CompilerThread_stringExistsAtIndex(line, "stdout: ", 0))
					{
						CompilerThread_OutputReciever(this, line.substring(8));
					}
					else if(CompilerThread_stringExistsAtIndex(line, "stderr: ", 0))
					{
						CompilerThread_ErrorReciever(this, line.substring(8));
					}
					else
					{
						CompilerThread_ErrorReciever(this, line);
					}
				}
				else
				{
					success = false;
				}
			}
			free(currentLine);
			fclose(file);
		}
		else
		{
			Console::WriteLine((String)"Error opening output file " + fullPath);
		}
	}
	
	//Assemble remaining files
	for(int i=0; i<needsCompiling.size(); i++)
	{
		String relPath = needsCompiling.get(i);
		currentFile = relPath;
		CompilerThread_ChangeStatus(this, (String)"(" + (i+1) + "/" + needsCompiling.size() + ") " + relPath);
		FileTools::writeStringToFile(buildFolder + '/' + relPath + ".output", "");
		
		String fullPath = srcFolder + '/' + relPath;
		String depPath = buildFolder + '/' + relPath + ".d";
		String outPath = buildFolder + '/' + relPath + ".o";
		
		String assembleCommand = CompilerThread_createAssembleString(projData, fullPath, outPath, depPath);
		subprocess_execute(assembleCommand, this, &CompilerThread_OutputReciever, &CompilerThread_ErrorReciever, &CompilerThread_ResultReciever, true);
		//waits until subprocess finishes
		
		if(lastResult==0)
		{
			projBuildInfo.removeEditedFile(relPath);
			ProjectBuildInfo_saveBuildInfoPlist(&projBuildInfoStruct, &projDataStruct);
		}
		else
		{
			result = -1;
		}
	}
	
	if(result!=0)
	{
		CompilerThread_ChangeStatus(this, "Failed");
		CompilerThread_FinishReciever(this, result);
		return;
	}
	
	CompilerThread_ChangeStatus(this, "Enumerating Files");
	//Collecting compiled files
	ArrayList<String> inputFiles;
	for(int i=0; i<needsCompiling.size(); i++)
	{
		inputFiles.add(buildFolder + '/' + needsCompiling.get(i) + ".o");
	}
	for(int i=0; i<fakeCompiling.size(); i++)
	{
		inputFiles.add(buildFolder + '/' + fakeCompiling.get(i) + ".o");
	}
	
	//FileTools::deleteFromFilesystem(releaseFolder);
	//FileTools::createDirectory(releaseFolder);
	
	String outputFolder;
	ProjectType type = projData.getProjectType();
	if(type==PROJECTTYPE_APPLICATION)
	{
		outputFolder = releaseFolder + '/' + projData.getProductName() + ".app";
	}
	else if(type==PROJECTTYPE_CONSOLE)
	{
		outputFolder = releaseFolder + '/' + projData.getProductName();
	}
	else if(type==PROJECTTYPE_DYNAMICLIBRARY)
	{
		outputFolder = releaseFolder + '/' + projData.getProductName();
	}
	else if(type==PROJECTTYPE_STATICLIBRARY)
	{
		outputFolder = releaseFolder + '/' + projData.getProductName();
	}
	else
	{
		outputFolder = releaseFolder + '/' + projData.getProductName() + ".app";
	}
	FileTools::createDirectory(outputFolder);
	
	String outputFile;
	if(type==PROJECTTYPE_APPLICATION)
	{
		outputFile = outputFolder + '/' + projData.getExecutableName();
	}
	else if(type==PROJECTTYPE_CONSOLE)
	{
		outputFile = outputFolder + '/' + projData.getExecutableName();
	}
	else if(type==PROJECTTYPE_DYNAMICLIBRARY)
	{
		outputFile = outputFolder + '/' + projData.getProductName() + ".dylib";
	}
	else if(type==PROJECTTYPE_STATICLIBRARY)
	{
		outputFile = outputFolder + '/' + projData.getProductName() + ".a";
	}
	
	//Compiling everything
	String compileCommand;
	if(type==PROJECTTYPE_APPLICATION || type==PROJECTTYPE_CONSOLE)
	{
		compileCommand = CompilerThread_createCompileString(projData, inputFiles, outputFile);
	}
	else if(type==PROJECTTYPE_DYNAMICLIBRARY || type==PROJECTTYPE_STATICLIBRARY)
	{
		compileCommand = CompilerThread_createLibtoolString(projData, inputFiles, outputFile);
	}
	currentFile = "";
	CompilerThread_ChangeStatus(this, "Compiling...");
	subprocess_execute(compileCommand, this, &CompilerThread_OutputReciever, &CompilerThread_ErrorReciever, &CompilerThread_ResultReciever, true);
	if(lastResult!=0)
	{
		result = -1;
		CompilerThread_ChangeStatus(this, "Failed");
		CompilerThread_FinishReciever(this, result);
		return;
	}
	
	if(type==PROJECTTYPE_APPLICATION || type==PROJECTTYPE_CONSOLE)
	{
		CompilerThread_ChangeStatus(this, (String)"Codesigning " + projData.getExecutableName() + "...");
		String codesignCommand = (String)"ldid -S \"" + outputFile + "\"";
		currentFile = "";
		subprocess_execute(codesignCommand, this, &CompilerThread_OutputReciever, &CompilerThread_ErrorReciever, &CodesignThread_ResultReciever, true);
		
		if(lastResult!=0)
		{
			result = -1;
		}
		
		if(result==0)
		{
			CompilerThread_ChangeStatus(this, "Succeeded");
		}
		else
		{
			CompilerThread_ChangeStatus(this, "Failed");
		}
	}
	
	CompilerThread_FinishReciever(this, result);
}

void CompilerThread::finish()
{
	delete this;
}

CompilerOrganizer* CompilerThread::getOrganizer()
{
	return organizer;
}

const String& CompilerThread::getCurrentFile()
{
	return currentFile;
}



String CompilerThread_createAssembleString(ProjectData& projData, const String& file, const String& outputFile, const String& dependencyFile)
{
	String projectRoot = (String)ProjLoad_getSavedProjectsFolder() + '/' + projData.getFolderName();
	
	String command = clangCommand + ' ';
	
	if(dependencyFile.length()>0)
	{
		command += (String)"-MD -MF \"" + dependencyFile + "\" ";
	}
	
	//sdk root
	String sdk = projData.getProjectSettings().getSDK();
	if(!sdk.equals(""))
	{
		String sdkPath = (String)Global_getSDKFolderPath() + "/" + sdk;
		command += (String)"-isysroot \"" + sdkPath + "\" ";
	}
	
	//include directories
	ArrayList<String>& includes = projData.getIncludeDirs();
	for(int i=0; i<includes.size(); i++)
	{
		String& includeDir = includes.get(i);
		if(includeDir.length()>0)
		{
			if(includeDir.charAt(0)!='/')
			{
				command += (String)"-I\"" + projectRoot + "/ext/" + includeDir + "\" ";
			}
			else
			{
				command += (String)"-I\"" + includeDir + "\" ";
			}
		}
	}
	
	//assemble flag
	command += "-c ";
	
	//turn off fixit info
	command += "-fno-diagnostics-fixit-info -fno-caret-diagnostics ";
	
	//set disabled warning flags
	ArrayList<String>& disabledWarnings = projData.getProjectSettings().getDisabledWarnings();
	for(int i=0; i<disabledWarnings.size(); i++)
	{
		String warning = disabledWarnings.get(i);
		if(warning.length()>2 && warning.charAt(0)=='-' && warning.charAt(1)=='W')
		{
			String noWarning = (String)"-Wno-" + warning.substring(2) + ' ';
			command += noWarning;
		}
	}
	
	//source file
	command += (String)"\"" + file + "\" ";
	
	//output file
	command += (String)"-o \"" + outputFile + "\"";
	
	return command;
}

String CompilerThread_createCompileString(ProjectData& projData, const ArrayList<String>& inputFiles, const String& outputFile)
{
	String projectRoot = (String)ProjLoad_getSavedProjectsFolder() + '/' + projData.getFolderName();
	
	String command = clangCommand + ' ';
	
	ProjectType projType = projData.getProjectType();
	if(projType==PROJECTTYPE_DYNAMICLIBRARY)
	{
		command += "-dynamiclib ";
	}
	
	//sdk root
	String sdk = projData.getProjectSettings().getSDK();
	if(!sdk.equals(""))
	{
		String sdkPath = (String)Global_getSDKFolderPath() + "/" + sdk;
		command += (String)"-isysroot \"" + sdkPath + "\" ";
	}
	
	//include directories
	ArrayList<String>& includes = projData.getIncludeDirs();
	for(int i=0; i<includes.size(); i++)
	{
		String& includeDir = includes.get(i);
		if(includeDir.length()>0)
		{
			if(includeDir.charAt(0)!='/')
			{
				command += (String)"-I\"" + projectRoot + "/ext/" + includeDir + "\" ";
			}
			else
			{
				command += (String)"-I\"" + includeDir + "\" ";
			}
		}
	}
	
	//frameworks
	ArrayList<String>& frameworks = projData.getFrameworkList();
	for(int i=0; i<frameworks.size(); i++)
	{
		String& framework = frameworks.get(i);
		command += (String)"-framework " + framework + " ";
	}
	
	//c++ standard library and objective-c library
	command += "-lstdc++ -lobjc ";
	
	//turn off fixit info
	command += "-fno-diagnostics-fixit-info -fno-caret-diagnostics ";
	
	//set disabled warning flags
	ArrayList<String>& disabledWarnings = projData.getProjectSettings().getDisabledWarnings();
	for(int i=0; i<disabledWarnings.size(); i++)
	{
		String warning = disabledWarnings.get(i);
		if(warning.length()>2 && warning.charAt(0)=='-' && warning.charAt(1)=='W')
		{
			String noWarning = (String)"-Wno-" + warning.substring(2) + ' ';
			command += noWarning;
		}
	}
	
	//user-specified compiler flags
	ArrayList<String>& flags = projData.getProjectSettings().getCompilerFlags();
	for(int i=0; i<flags.size(); i++)
	{
		String& flag = flags.get(i);
		command += flag + " ";
	}
	
	//source (input) files
	for(int i=0; i<inputFiles.size(); i++)
	{
		const String& file = inputFiles.get(i);
		String extension = CompilerThread_getExtensionForFilename(file);
		if(!extension.equals("h"))
		{
			command += (String)"\"" + file + "\" ";
		}
	}
	
	//lib directories
	ArrayList<String> srcTypes = CompilerThread_getSourceTypes();
	ArrayList<String>& libs = projData.getLibDirs();
	for(int i=0; i<libs.size(); i++)
	{
		String& libDir = libs.get(i);
		if(libDir.length()>0)
		{
			ArrayList<String> libFiles;
			if(libDir.charAt(0)!='/')
			{
				String fullLibDir = projectRoot + "/ext/" + libDir;
				libFiles = FileTools::getFilenamesWithExtension(fullLibDir, srcTypes);
			}
			else
			{
				libFiles = FileTools::getFilenamesWithExtension(libDir, srcTypes);
			}
			
			for(int j=0; j<libFiles.size(); j++)
			{
				String& file = libFiles.get(j);
				command += (String)"\"" + file + "\" ";
			}
		}
	}
	
	//TODO replace version info with specified version info in ProjectData
	if(projType==PROJECTTYPE_DYNAMICLIBRARY)
	{
		command += "-current_version 1.0 -compatibility_version 1.0 -fvisibility=hidden ";
	}
	
	//output file (executable)
	command += (String)"-o \"" + outputFile + "\" ";
	
	return command;
}

String CompilerThread_createLibtoolString(ProjectData& projData, const ArrayList<String>& inputFiles, const String& outputFile)
{
	String projectRoot = (String)ProjLoad_getSavedProjectsFolder() + '/' + projData.getFolderName();
	
	String command = libtoolCommand + ' ';
	
	ProjectType projType = projData.getProjectType();
	if(projType==PROJECTTYPE_DYNAMICLIBRARY)
	{
		command += "-dynamic ";
	}
	else if(projType==PROJECTTYPE_STATICLIBRARY)
	{
		command += "-static ";
	}
	
	//user-specified compiler flags
	ArrayList<String>& flags = projData.getProjectSettings().getCompilerFlags();
	for(int i=0; i<flags.size(); i++)
	{
		String& flag = flags.get(i);
		command += flag + " ";
	}
	
	//source (input) files
	for(int i=0; i<inputFiles.size(); i++)
	{
		const String& file = inputFiles.get(i);
		String extension = CompilerThread_getExtensionForFilename(file);
		if(!extension.equals("h"))
		{
			command += (String)"\"" + file + "\" ";
		}
	}
	
	command += (String)"-o \"" + outputFile + "\"";
	
	return command;
}

bool CompilerThread_stringExistsAtIndex(const String& str, const String& cmp, int index)
{
	int total = str.length() - index;
	if(total<cmp.length())
	{
		return false;
	}
	
	for(int i=0; i<cmp.length(); i++)
	{
		if(cmp.charAt(i)!=str.charAt(index+i))
		{
			return false;
		}
	}
	return true;
}

String CompilerThread_getExtensionForFilename(const String& fileName)
{
	int index = fileName.lastIndexOf(".");
	if(index==-1 || index==(fileName.length()-1))
	{
		return "";
	}
	return fileName.substring(index+1).toLowerCase();
}

CompilerThread_FileDependencyList* CompilerThread_parseDependencyFile(const String& file, const String& sourceFile, bool relativeOnly, const String& filter)
{
	String contents;
	bool loaded = FileTools::loadFileIntoString(file, contents);
	if(!loaded)
	{
		return NULL;
	}
	
	String pathFilter;
	if(!FileTools::expandPath(filter, pathFilter))
	{
		Console::WriteLine((String)"Error expanding path filter " + filter);
		return NULL;
	}
	
	int sourceFileSlashIndex = sourceFile.lastIndexOf('/');
	String containingFolder = "";
	if(sourceFileSlashIndex != -1)
	{
		containingFolder = sourceFile.substring(0, sourceFileSlashIndex);
	}
	
	CompilerThread_FileDependencyList* list = new CompilerThread_FileDependencyList();
	
	String currentLine = "";
	int lines = 0;
	for(int i=0; i<contents.length(); i++)
	{
		char c = contents.charAt(i);
		
		bool lastChar = false;
		if(i==(contents.length()-1))
		{
			lastChar = true;
		}
		
		if(c=='\n' || lastChar)
		{
			if(lastChar && c!='\n' && c!='\\')
			{
				currentLine += c;
			}
			
			currentLine = currentLine.trim();
			
			if(currentLine.length()>2)
			{
				if(currentLine.charAt(currentLine.length()-1)=='\\')
				{
					if(currentLine.charAt(currentLine.length()-2)==' ')
					{
						currentLine = currentLine.substring(0, currentLine.length()-2).trim();
					}
					else
					{
						currentLine = currentLine.substring(0, currentLine.length()-1).trim();
					}
				}
			}
			
			if(currentLine.length()>0)
			{
				if(currentLine.charAt(0)!='/')
				{
					currentLine = containingFolder + '/' + currentLine;
				}
				
				String fullLine;
				if(FileTools::expandPath(currentLine, fullLine))
				{
					if(lines==0)
					{
						list->outputFile = fullLine;
					}
					else if(lines==1)
					{
						list->sourceFile = fullLine;
					}
					else
					{
						if(pathFilter.length()>0 && CompilerThread_stringExistsAtIndex(fullLine, pathFilter, 0))
						{
							String depFilePath;
							
							if(fullLine.charAt(pathFilter.length())=='/')
							{
								depFilePath = fullLine.substring(pathFilter.length()+1);
							}
							else
							{
								depFilePath = fullLine.substring(pathFilter.length());
							}
							list->dependencies.add(depFilePath);
						}
						else if(!relativeOnly)
						{
							list->dependencies.add(fullLine);
						}
					}
				}
				else
				{
					Console::WriteLine((String)"Error expanding path \"" + currentLine + "\" in dependency file \"" + file + "\"");
				}
				
				lines++;
			}
			
			currentLine.clear();
		}
		else
		{
			currentLine += c;
		}
	}
	
	return list;
}
