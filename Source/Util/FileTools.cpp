
#include "FileTools.h"
#include "Console.h"
#include <dirent.h>
#include <copyfile.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>

ArrayList<String> FileTools::getFilenamesWithExtension(const String& directory, ArrayList<String>& extensions)
{
	String command;
	
	if(extensions.size()>0)
	{
		command = (String)"find \"" + directory + "\" -iregex \'.*\\(";
		int counter = 0;
		while(counter<extensions.size())
		{
			if(counter!=0)
			{
				command += "\\|";
			}
			
			command += extensions.get(counter);
			
			counter++;
		}
		
		command += "\\)\' -type f";
	}
	else
	{
		command = (String)"find \"" + directory + "\" -type f";
	}
	
	String output = Console::Execute(command);
	
	if(output.length()==0)
	{
		return ArrayList<String>();
	}
	
	ArrayList<String> files;
	
	String currentFile = "";
	for(int i=0; i<output.length(); i++)
	{
		char c = output.charAt(i);
		if(c=='\n')
		{
			if(currentFile.length()>0)
			{
				files.add(currentFile);
				currentFile = "";
			}
		}
		else
		{
			currentFile += c;
		}
	}
	
	if(currentFile.length()>0)
	{
		files.add(currentFile);
		currentFile = "";
	}
	
	return files;
}

ArrayList<String> FileTools::getFoldersInDirectory(const String&directory, bool hidden)
{
	DIR*dir = opendir(directory);
	if(dir==NULL)
	{
		Console::WriteLine((String)"Error: directory \"" + directory + "\" does not exist!");
		return ArrayList<String>();
	}
	
	ArrayList<String> folders;
	
	if(dir!=NULL)
	{
		struct dirent *entry = readdir(dir);
		
		while (entry != NULL)
		{
			if(entry->d_type == DT_DIR)
			{
				String folderName = entry->d_name;
				if(!folderName.equals(".") && !folderName.equals(".."))
				{
					if(hidden || (!hidden && folderName.charAt(0)!='.'))
					{
						folders.add(entry->d_name);
					}
				}
			}
			
			entry = readdir(dir);
		}
		
		closedir(dir);
	}
	
	return folders;
	
	//old function
	/*String command;
	command = (String)"find " + directory + " -maxdepth 1 -type d";
	
	String output = Console::Execute(command);
	
	ArrayList<String> lines;
	String currentLine = "";
	
	for(int i=0; i<output.length(); i++)
	{
		char c = output.charAt(i);
		if(c=='\n')
		{
			if(currentLine.length()>0)
			{
				lines.add(currentLine);
				currentLine = "";
			}
		}
		else
		{
			currentLine+=c;
		}
	}
	
	if(currentLine.length()>0)
	{
		lines.add(currentLine);
		currentLine = "";
	}
	
	for(int i=0; i<lines.size(); i++)
	{
		String line = lines.get(i);
		if(line.length()<=directory.length())
		{
			lines.remove(i);
			i--;
		}
		else
		{
			if(line.charAt(directory.length())=='/')
			{
				line = line.substring(directory.length()+1, line.length());
			}
			else
			{
				line = line.substring(directory.length(), line.length());
			}
			lines.set(i, line);
		}
	}
	
	return lines;*/
}

ArrayList<String> FileTools::getFilesInDirectory(const String&directory, bool hidden)
{
	DIR*dir = opendir(directory);
	if(dir==NULL)
	{
		Console::WriteLine((String)"Error: directory \"" + directory + "\" does not exist!");
		return ArrayList<String>();
	}
	
	struct dirent *entry = readdir(dir);
	
	ArrayList<String> files;
	
	while (entry != NULL)
	{
		if(entry->d_type == DT_REG)
		{
			String fileName = entry->d_name;
			if(!fileName.equals(".") && !fileName.equals(".."))
			{
				if(hidden || (!hidden && fileName.charAt(0)!='.'))
				{
					files.add(entry->d_name);
				}
			}
		}
		
		entry = readdir(dir);
	}
	
	closedir(dir);
	
	return files;
}

StringTree FileTools::getStringTreeFromDirectory(const String&directory, bool hidden)
{
	StringTree tree;
	
	ArrayList<String> files = getFilesInDirectory(directory, hidden);
	ArrayList<String> folders = getFoldersInDirectory(directory, hidden);
	
	for(int i=0; i<files.size(); i++)
	{
		tree.addMember(files.get(i));
	}
	
	files.clear();
	
	for(int i=0; i<folders.size(); i++)
	{
		StringTree branch = getStringTreeFromDirectory(directory+'/'+folders.get(i), hidden);
		tree.addBranch(folders.get(i), branch);
	}
	
	folders.clear();
	
	return tree;
}

void FileTools::createDirectoriesFromStringTree(const String&directory, const StringTree&tree)
{
	const ArrayList<String>& branchNames = tree.getBranchNames();
	for(int i=0; i<branchNames.size(); i++)
	{
		String branchName = branchNames.get(i);
		String newDir = directory+'/'+branchName;
		FileTools::createDirectory(newDir);
		FileTools::createDirectoriesFromStringTree(newDir, *tree.getBranch(branchName));
	}
}

unsigned int FileTools::totalFilesInDirectory(const String&directory, bool hidden)
{
	unsigned int total = 0;
	
	ArrayList<String> files = FileTools::getFilesInDirectory(directory, hidden);
	total += files.size();
	files.clear();
	
	ArrayList<String> folders = FileTools::getFoldersInDirectory(directory, hidden);
	for(int i=0; i<folders.size(); i++)
	{
		total += FileTools::totalFilesInDirectory(directory+'/'+folders.get(i), hidden);
	}
	return total;
}

bool FileTools::directoryContainsFiles(const String&directory, bool hidden)
{
	DIR*dir = opendir(directory);
	if(dir==NULL)
	{
		return false;
	}
	
	struct dirent *entry = readdir(dir);
	
	while (entry != NULL)
	{
		String entryName = entry->d_name;
		if(!entryName.equals(".") && !entryName.equals(".."))
		{
			if(entry->d_type==DT_REG || entry->d_type==DT_LNK)
			{
				closedir(dir);
				return true;
			}
			else if(entry->d_type==DT_DIR)
			{
				bool contains = FileTools::directoryContainsFiles(directory+'/'+entryName, hidden);
				if(contains)
				{
					closedir(dir);
					return true;
				}
			}
		}
		
		entry = readdir(dir);
	}
	
	closedir(dir);
	
	return false;
}

bool FileTools::createFile(const String&path)
{
	/*if(creat(path, S_IWUSR)==-1)
	{
		return false;
	}
	return true;*/
	FILE*file = fopen(path, "a+");
	if(file==NULL)
	{
		return false;
	}
	fclose(file);
	return true;
}

bool FileTools::createDirectory(const String&directory)
{
	int result = mkdir(directory, 0755);
	if(result == -1)
	{
		return false;
	}
	return true;
}

bool FileTools::createSymbolicLink(const String&srcPath, const String&dstPath)
{
	if(!createFile(dstPath))
	{
		Console::WriteLine("Failed to create symbolic link: Unable to create file for writing");
		return false;
	}
	if(symlink(srcPath, dstPath)!=0)
	{
		String message = "Failed to create symbolic link: ";
		switch(errno)
		{
			default:
			message += "Unknown error";
			break;
			
			case EACCES:
			message += "Permission denied";
			break;
			
			case EEXIST:
			message += "File already exists";
			break;
			
			case EINVAL:
			message += "Invalid destination path";
			break;
			
			case EIO:
			message += "IO error";
			break;
			
			case ELOOP:
			message += "Loop error";
			break;
			
			case ENAMETOOLONG:
			message += "Destination path name too long";
			break;
			
			case ENOENT:
			if(dstPath.length()==0)
			{
				message += "Destination path is an empty string";
			}
			else
			{
				message += "Destination path does not name an existing file";
			}
			break;
			
			case ENOSPC:
			message += "No available space on disk";
			break;
			
			case ENOTDIR:
			message += "Prefix of destination path is not a directory";
			break;
			
			case EROFS:
			message += "Destination path cannot reside in a read-only system";
			break;
		}
		Console::WriteLine(message);
		return false;
	}
	return true;
}

/*bool FileTools::createSymbolicLinkRoot(const String&srcPath, const String&dstPath)
{
	String command = "ln -s ";
	command += (String)"\"" + srcPath + "\" \"" + dstPath + "\"";
	int result = 0;
	String output = Console::Execute(command, &result);
	Console::WriteLine((String)"ln returned " + result + ". " + output);
	if(result!=0)
	{
		return false;
	}
	return true;
}*/

bool FileTools::copyFile(const String&src, const String&dest)
{
	copyfile_state_t state = copyfile_state_alloc();
	int result = copyfile(src, dest, state, COPYFILE_ALL);
	if(result<0)
	{
		String message = "Error: FileTools::copyFile(const String&, const String&): ";
		switch(errno)
		{
			default:
			message += "Unknown Error";
			break;
			
			case EINVAL:
			message += "Invalid argument";
			break;
			
			case ENOMEM:
			message += "Not enough memory";
			break;
			
			case ENOTSUP:
			message += "The source file was not a directory, symbolic link, or regular file";
			break;
			
			case ECANCELED:
			message += "Copy was cancelled by the callback";
			break;
		}
		Console::WriteLine(message);
		copyfile_state_free(state);
		return false;
	}
	copyfile_state_free(state);
	return true;
}

bool FileTools::copyFolder(const String&src, const String&dest)
{
	createDirectory(dest);
	
	bool success = true;
	
	ArrayList<String> files = FileTools::getFilesInDirectory(src, true);
	for(int i=0; i<files.size(); i++)
	{
		String&file = files.get(i);
		String srcFile = src+'/'+file;
		String dstFile = dest+'/'+file;
		bool copied = copyFile(srcFile, dstFile);
		if(!copied)
		{
			Console::WriteLine((String)"Error: FileTools::copyFolder(const String&, const String&), failed to copy file " + srcFile);
			success = false;
		}
	}
	
	ArrayList<String> folders = FileTools::getFoldersInDirectory(src, true);
	for(int i=0; i<folders.size(); i++)
	{
		String&folder = folders.get(i);
		String srcFolder = src+'/'+folder;
		String dstFolder = dest+'/'+folder;
		bool copied = copyFolder(srcFolder, dstFolder);
		if(!copied)
		{
			success = false;
		}
	}
	
	return success;
}

bool FileTools::folderExists(const String&path)
{
	DIR*dir = opendir(path);
	if(dir==NULL)
	{
		return false;
	}
	closedir(dir);
	return true;
}

bool FileTools::pathIsFolder(const String&path)
{
	struct stat s;
	if(stat(path, &s)==0)
	{
		if((s.st_mode&S_IFMT) == S_IFDIR)
		{
			return true;
		}
	}
	else
	{
		if(errno == EACCES)
		{
			Console::WriteLine((String)"Error: FileTools::pathIsFolder(const String&): Access denied: " + path);
		}
	}
	return false;
}

bool FileTools::pathIsFile(const String&path)
{
	struct stat s;
	if(stat(path, &s)==0)
	{
		if((s.st_mode&S_IFMT) == S_IFREG)
		{
			return true;
		}
	}
	else
	{
		if(errno == EACCES)
		{
			Console::WriteLine((String)"Error: FileTools::pathIsFile(const String&): Access denied: " + path);
		}
	}
	return false;
}

bool FileTools::expandPath(const String& path, String& dest)
{
	char* buffer = (char*)malloc(PATH_MAX);
	if(realpath(path, buffer)==NULL)
	{
		free(buffer);
		dest = "";
		if(errno==EACCES)
		{
			Console::WriteLine((String)"Error: FileTools::expandPath(const String&, String&): Access denied: " + path);
		}
		return false;
	}
	dest = buffer;
	free(buffer);
	return true;
}

bool FileTools::deleteFromFilesystem(const String&path)
{
	int result = system((String)"rm -rf \"" + path + "\"");
	if(result==0)
	{
		return true;
	}
	return false;
}

/*bool FileTools::deleteFromFilesystem(const String&path)
{
	return NSFileManager_removeItemAtPath(NSFileManager_defaultManager(), NSString_stringWithUTF8String(path), NULL);
}*/

bool FileTools::rename(const String&oldFile, const String&newFile)
{
	int result = std::rename(oldFile, newFile);
	if(result==0)
	{
		return true;
	}
	return false;
}

bool FileTools::loadFileIntoString(const String&path, String&str)
{
	/*FILE*file = fopen(path, "r");
	if(file==NULL)
	{
		return false;
	}
	
	char buffer[512];
	str.clear();
	while(!feof(file))
	{
		if(fgets(buffer, 512, file) != NULL)
		{
			str += buffer;
		}
	}
	fclose(file);
	return true;*/
	
	FILE*file = fopen(path, "r");
	if(file==NULL)
	{
		return false;
	}
	fseek(file, 0, SEEK_END);
	int total = ftell(file);
	fseek(file, 0, SEEK_SET);
	
	char*fileText = new char[total+1];
	fileText[total] = '\0';
	
	fread(fileText, 1, total+1, file);
	str = fileText;
	
	fclose(file);
	delete[] fileText;
	return true;
}

bool FileTools::writeStringToFile(const String&path, const String&content)
{
	FILE*file = fopen(path, "w");
	if(file==NULL)
	{
		return false;
	}
	
	fwrite((const char*)content, 1, content.length(), file);
	
	fclose(file);
	return true;
}

bool FileTools::appendStringToFile(const String&path, const String&content)
{
	FILE*file = fopen(path, "a+");
	if(file==NULL)
	{
		return false;
	}
	fseek(file,0,SEEK_END);
	fwrite((const char*)content, 1, content.length(), file);
	
	fclose(file);
	return true;
}


