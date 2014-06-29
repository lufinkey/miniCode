
#include "CompilerOrganizer.h"
#include "CompilerThread.h"
#include "../Util/Console.h"

static CompilerOutputLine CompilerOrganizer_emptyOutputLine = CompilerOutputLine();

//CompilerOutputLine

CompilerOutputLine::CompilerOutputLine()
{
	type = COMPILER_UNKNOWN;
	value = 0;
}

CompilerOutputLine::CompilerOutputLine(CompilerOutputType type, const String&output)
{
	this->type = type;
	if(output.charAt(output.length()-1)=='\n')
	{
		this->output = output.substring(0, output.length()-1);
	}
	else
	{
		this->output = output;
	}
	value = 0;
	if(type == COMPILER_RESULT)
	{
		value = String::asInt(line);
	}
}

CompilerOutputLine::CompilerOutputLine(const String&fileName, unsigned int line, unsigned int offset, const String& errorType, const String&message)
{
	this->type = COMPILER_ERROR;
	this->fileName = fileName.trim();
	this->line = line;
	this->offset = offset;
	this->errorType = errorType.trim();
	if(message.charAt(message.length()-1)=='\n')
	{
		this->message = message.substring(0, message.length()-1).trim();
	}
	else
	{
		this->message = message.trim();
	}
	
	value = 0;
	
	if(this->errorType.equals("Error in file included from"))
	{
		output = this->errorType + ": " + this->fileName + ':' + this->line + ':' + this->offset + ": " + this->message;
	}
	else if(this->errorType.equals("ld"))
	{
		output = this->errorType + ": " + this->message;
	}
	else if(this->errorType.equals("clang warning"))
	{
		output = (String)"clang: warning: " + this->message;
	}
	else if(this->errorType.equals("clang error"))
	{
		output = (String)"clang: error: " + this->message;
	}
	else if(this->errorType.equals("clang fatal error"))
	{
		output = (String)"clang: fatal error: " + this->message;
	}
	else if(this->errorType.equals("libtool file"))
	{
		output = (String)"libtool: file: " + this->message;
	}
	else if(this->errorType.equals("libtool warning"))
	{
		output = (String)"libtool: warning: " + this->message;
	}
	else if(this->errorType.equals("libtool error"))
	{
		output = (String)"libtool: error: " + this->message;
	}
	else if(this->errorType.equals("libtool fatal error"))
	{
		output = (String)"libtool: fatal error: " + this->message;
	}
	else if(this->errorType.equals("undefined symbols"))
	{
		output = this->message;
	}
	else
	{
		output = this->fileName + ':' + this->line + ':' + this->offset + ": " + this->errorType + ": " + this->message;
	}
}

CompilerOutputLine::CompilerOutputLine(int result)
{
	type = COMPILER_RESULT;
	value = result;
	output = result;
}

CompilerOutputLine::CompilerOutputLine(const CompilerOutputLine& outputLine)
{
	output = outputLine.output;
	supplementaryOutput = outputLine.supplementaryOutput;
	type = outputLine.type;
	fileName = outputLine.fileName;
	line = outputLine.line;
	offset = outputLine.offset;
	errorType = outputLine.errorType;
	message = outputLine.message;
	value = outputLine.value;
}

CompilerOutputLine::~CompilerOutputLine()
{
	//
}

CompilerOutputLine& CompilerOutputLine::operator=(const CompilerOutputLine& outputLine)
{
	output = outputLine.output;
	supplementaryOutput = outputLine.supplementaryOutput;
	type = outputLine.type;
	fileName = outputLine.fileName;
	line = outputLine.line;
	offset = outputLine.offset;
	errorType = outputLine.errorType;
	message = outputLine.message;
	value = outputLine.value;
	
	return *this;
}

bool CompilerOutputLine::equals(const CompilerOutputLine& line)
{
	if(output.equals(line.output))
	{
		if(supplementaryOutput.size()==line.supplementaryOutput.size())
		{
			for(int i=0; i<supplementaryOutput.size(); i++)
			{
				if(!supplementaryOutput.get(i).equals(line.supplementaryOutput.get(i)))
				{
					return false;
				}
			}
			return true;
		}
		return false;
	}
	return false;
}

void CompilerOutputLine::addSupplementaryOutput(const String& suppOutput)
{
	if(suppOutput.charAt(suppOutput.length()-1)=='\n')
	{
		supplementaryOutput.add(suppOutput.substring(0,suppOutput.length()-1));
	}
	else
	{
		supplementaryOutput.add(suppOutput);
	}
}

CompilerOutputType CompilerOutputLine::getType()
{
	return type;
}

const String& CompilerOutputLine::getOutput()
{
	return output;
}

ArrayList<String>& CompilerOutputLine::getSupplementaryOutput()
{
	return supplementaryOutput;
}

int CompilerOutputLine::getResult()
{
	return value;
}

const String& CompilerOutputLine::getFileName()
{
	return fileName;
}

unsigned int CompilerOutputLine::getLine()
{
	return line;
}

unsigned int CompilerOutputLine::getOffset()
{
	return offset;
}

const String& CompilerOutputLine::getErrorType()
{
	return errorType;
}

const String& CompilerOutputLine::getMessage()
{
	return message;
}



//CompilerOrganizer

void CompilerOrganizer::parseOutput(const String& output)
{
	CompilerOutputLine* outputLine = new CompilerOutputLine(COMPILER_OUTPUT, output);
	CompilerOutputLine_struct outputLineStruct;
	outputLineStruct.data = outputLine;
	if(outputRecievedCallback!=NULL)
	{
		outputRecievedCallback(data, outputLineStruct);
	}
	delete outputLine;
}

void CompilerOrganizer::parseError(const String& error)
{
	if(expectingSupplementaryOutput>0)
	{
		if(currentError.getErrorType().equals("undefined symbols"))
		{
			if(expectingSupplementaryOutput>1)
			{
				currentError.addSupplementaryOutput(error);
				expectingSupplementaryOutput--;
				return;
			}
			else if(expectingSupplementaryOutput==1)
			{
				if(error.length()>4 && (error.substring(0,4).equals("    ") || error.charAt(0)=='\t'))
				{
					currentError.addSupplementaryOutput(error);
					return;
				}
				else
				{
					expectingSupplementaryOutput = 0;
					handleOutputLine(currentError);
				}
			}
		}
		else
		{
			currentError.addSupplementaryOutput(error);
			expectingSupplementaryOutput--;
			if(expectingSupplementaryOutput==0)
			{
				handleOutputLine(currentError);
			}
			return;
		}
	}
	
	int colon1 = -1;
	int colon2 = -1;
	int colon3 = -1;
	int colon4 = -1;
	
	for(int i=0; i<error.length(); i++)
	{
		char c = error.charAt(i);
		if(c==':')
		{
			if(colon1==-1)
			{
				colon1 = i;
			}
			else if(colon2==-1)
			{
				colon2 = i;
			}
			else if(colon3==-1)
			{
				colon3 = i;
			}
			else if(colon4==-1)
			{
				colon4 = i;
			}
		}
	}
	
	if(colon1==-1)
	{
		currentError = CompilerOutputLine(COMPILER_ERROR, error);
		handleOutputLine(currentError);
		return;
	}
	else if(colon2==-1)
	{
		String errorType = error.substring(0,colon1).trim();
		if(errorType.equals("ld"))
		{
			String message = error.substring(colon1+1);
			currentError = CompilerOutputLine("", 0, 0, "ld", message);
			handleOutputLine(currentError);
			return;
		}
		if(errorType.length()>=18 && error.substring(0,18).equals("Undefined symbols "))
		{
			currentError = CompilerOutputLine("", 0, 0, "undefined symbols", error);
			expectingSupplementaryOutput = 2;
			return;
		}
		else
		{
			currentError = CompilerOutputLine(COMPILER_ERROR, error);
			handleOutputLine(currentError);
			return;
		}
	}
	else if(colon3==-1)
	{
		if(error.length()>22)
		{
			String frontChecker = error.substring(0, 22);
			if(frontChecker.equals("In file included from "))
			{
				String fileName = error.substring(22, colon1);
				String lineNum = error.substring(colon1+1, colon2);
				bool onlyNums = true;
				for(int i=0; i<lineNum.length(); i++)
				{
					char c = lineNum.charAt(i);
					if(!(c>='0' && c<='9'))
					{
						onlyNums = false;
						i = lineNum.length();
					}
				}
				if(!onlyNums || lineNum.length()==0)
				{
					currentError = CompilerOutputLine(COMPILER_ERROR, error);
					handleOutputLine(currentError);
					return;
				}
				
				currentError = CompilerOutputLine(fileName, String::asInt(lineNum), 1, "Error in file included from", "");
				handleOutputLine(currentError);
				return;
			}
			else
			{
				String errorPrefix = error.substring(0, colon1).trim();
				if(errorPrefix.equals("clang"))
				{
					String errorType = error.substring(colon1+1, colon2).trim();
					String message = error.substring(colon2+1);
					
					currentError = CompilerOutputLine("", 0, 0, (String)"clang "+errorType, message);
					handleOutputLine(currentError);
					return;
				}
				else if(errorPrefix.equals("libtool"))
				{
					String errorType = error.substring(colon1+1, colon2).trim();
					String message = error.substring(colon2+1);
					currentError = CompilerOutputLine("", 0, 0, (String)"libtool "+errorType, message); 
					handleOutputLine(currentError);
					return;
				}
				else
				{
					currentError = CompilerOutputLine(COMPILER_ERROR, error);
					handleOutputLine(currentError);
					return;
				}
			}
		}
		else
		{
			String errorPrefix = error.substring(0, colon1).trim();
			if(errorPrefix.equals("clang"))
			{
				String errorType = error.substring(colon1+1, colon2).trim();
				String message = error.substring(colon2+1);
				
				currentError = CompilerOutputLine("", 0, 0, (String)"clang "+errorType, message);
				handleOutputLine(currentError);
				return;
			}
			else
			{
				currentError = CompilerOutputLine(COMPILER_ERROR, error);
				handleOutputLine(currentError);
				return;
			}
		}
	}
	else if(colon4==-1)
	{
		String errorPrefix = error.substring(0, colon1).trim();
		if(errorPrefix.equals("clang"))
		{
			String errorType = error.substring(colon1+1, colon2).trim();
			String message = error.substring(colon2+1);
			
			currentError = CompilerOutputLine("", 0, 0, (String)"clang "+errorType, message);
			handleOutputLine(currentError);
			return;
		}
		else
		{
			currentError = CompilerOutputLine(COMPILER_ERROR, error);
			handleOutputLine(currentError);
			return;
		}
	}
	else
	{
		String fileName = error.substring(0, colon1);
		
		String lineNum = error.substring(colon1+1, colon2);
		bool onlyNums = true;
		for(int i=0; i<lineNum.length(); i++)
		{
			char c = lineNum.charAt(i);
			if(!(c>='0' && c<='9'))
			{
				onlyNums = false;
				i = lineNum.length();
			}
		}
		if(!onlyNums || lineNum.length()==0)
		{
			String errorPrefix = error.substring(0, colon1).trim();
			if(errorPrefix.equals("clang"))
			{
				String errorType = error.substring(colon1+1, colon2).trim();
				String message = error.substring(colon2+1);
				
				currentError = CompilerOutputLine("", 0, 0, (String)"clang "+errorType, message);
				handleOutputLine(currentError);
				return;
			}
			else
			{
				currentError = CompilerOutputLine(COMPILER_ERROR, error);
				handleOutputLine(currentError);
				return;
			}
			return;
		}
		
		String lineOffset = error.substring(colon2+1, colon3);
		onlyNums = true;
		for(int i=0; i<lineOffset.length(); i++)
		{
			char c = lineOffset.charAt(i);
			if(!(c>='0' && c<='9'))
			{
				onlyNums = false;
				i = lineOffset.length();
			}
		}
		if(!onlyNums || lineOffset.length()==0)
		{
			String errorPrefix = error.substring(0, colon1).trim();
			if(errorPrefix.equals("clang"))
			{
				String errorType = error.substring(colon1+1, colon2).trim();
				String message = error.substring(colon2+1);
				
				currentError = CompilerOutputLine("", 0, 0, (String)"clang "+errorType, message);
				handleOutputLine(currentError);
				return;
			}
			else
			{
				currentError = CompilerOutputLine(COMPILER_ERROR, error);
				handleOutputLine(currentError);
				return;
			}
		}
		
		String errorType = error.substring(colon3+1, colon4).trim();
		String message = error.substring(colon4+1).trim();
		
		currentError = CompilerOutputLine(fileName, String::asInt(lineNum), String::asInt(lineOffset), errorType, message);
		handleOutputLine(currentError);
	}
}

void CompilerOrganizer::handleFileResult(int result)
{
	if(expectingSupplementaryOutput>0)
	{
		expectingSupplementaryOutput = 0;
		handleOutputLine(currentError);
	}
	CompilerOutputLine* outputLine = new CompilerOutputLine(result);
	handleOutputLine(*outputLine);
	delete outputLine;
}

void CompilerOrganizer::handleOutputLine(CompilerOutputLine& outputLine)
{
	CompilerOutputType type = outputLine.getType();
	if(type==COMPILER_ERROR)
	{
		const String& errorType = outputLine.getErrorType();
		if(errorType.equals("Error in file included from"))
		{
			if(stacking)
			{
				addOutputLine(stackFile, outputLine);
			}
			else
			{
				stacking = true;
				const String& fileName = outputLine.getFileName();
				stackFile = fileName;
				addOutputLine(fileName, outputLine);
			}
		}
		else
		{
			if(stacking)
			{
				stacking = false;
				addOutputLine(stackFile, outputLine);
			}
			else
			{
				const String& fileName = outputLine.getFileName();
				if(fileName.length()==0)
				{
					addOutputLine(stackFile, outputLine);
				}
				else
				{
					stackFile = fileName;
					addOutputLine(fileName, outputLine);
				}
			}
		}
	}
	else if(type==COMPILER_OUTPUT)
	{
		//
	}
	else if(type==COMPILER_RESULT)
	{
		//
	}
	
	if(outputRecievedCallback!=NULL)
	{
		CompilerOutputLine_struct outputLineStruct = CompilerOutputLine_createWithData(&outputLine);
		outputRecievedCallback(data, outputLineStruct);
	}
}

void CompilerOrganizer::handleFinish(int result)
{
	if(finishCallback!=NULL)
	{
		finishCallback(data, result);
	}
	running = false;
}

void CompilerOrganizer::addOutputLine(const String&fileName, CompilerOutputLine& outputLine)
{
	for(int i=0; i<errorLists.size(); i++)
	{
		CompilerErrorList& errorList = errorLists.get(i);
		if(errorList.fileName.equals(fileName))
		{
			for(int j=0; j<errorList.lines.size(); j++)
			{
				if(errorList.lines.get(j).equals(outputLine))
				{
					return;
				}
			}
			errorList.lines.add(outputLine);
			return;
		}
	}
	CompilerErrorList list;
	list.fileName = fileName;
	list.lines.add(outputLine);
	errorLists.add(list);
}

CompilerOrganizer::CompilerOrganizer(ProjectData* projData)
{
	this->projData = projData;
	outputRecievedCallback = NULL;
	finishCallback = NULL;
	statusCallback = NULL;
	data = NULL;
	stacking = false;
	running = false;
}

CompilerOrganizer::~CompilerOrganizer()
{
	//
}

bool CompilerOrganizer::isRunning()
{
	return running;
}

void CompilerOrganizer::runCompiler()
{
	if(!running)
	{
		stackFile = "";
		stacking = false;
		errorLists.clear();
		running = true;
		CompilerThread* thread = new CompilerThread(this);
		thread->start();
	}
	else
	{
		Console::WriteLine("Error: Compiler is already running");
	}
}

void CompilerOrganizer::setCurrentStatus(const String& status)
{
	this->status = status;
	if(statusCallback!=NULL)
	{
		statusCallback(data, status);
	}
}

const String& CompilerOrganizer::getCurrentStatus()
{
	return status;
}

void CompilerOrganizer::setCallbacks(CompilerOrganizer_OutputRecievedCallback outputRecievedCallback,
									 CompilerOrganizer_FinishCallback finishCallback,
									 CompilerOrganizer_StatusCallback statusCallback, void*data)
{
	this->data = data;
	this->outputRecievedCallback = outputRecievedCallback;
	this->finishCallback = finishCallback;
	this->statusCallback = statusCallback;
}

unsigned int CompilerOrganizer::totalFiles()
{
	return errorLists.size();
}

unsigned int CompilerOrganizer::totalErrors(const String&fileName)
{
	for(int i=0; i<errorLists.size(); i++)
	{
		if(errorLists.get(i).fileName.equals(fileName))
		{
			return errorLists.get(i).lines.size();
		}
	}
	return 0;
}

unsigned int CompilerOrganizer::totalErrors(unsigned int index)
{
	return errorLists.get(index).lines.size();
}

const String& CompilerOrganizer::getFile(unsigned int index)
{
	return errorLists.get(index).fileName;
}

CompilerOutputLine& CompilerOrganizer::getError(const String& fileName, unsigned int index)
{
	for(int i=0; i<errorLists.size(); i++)
	{
		if(errorLists.get(i).fileName.equals(fileName))
		{
			return errorLists.get(i).lines.get(index);
		}
	}
	return CompilerOrganizer_emptyOutputLine;
}

CompilerOutputLine& CompilerOrganizer::getError(unsigned int fileIndex, unsigned int errorIndex)
{
	return errorLists.get(fileIndex).lines.get(errorIndex);
}

void CompilerOrganizer::clear()
{
	errorLists.clear();
}







