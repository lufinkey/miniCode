
#import "ProjLoadTools.h"
#import <UIKit/UIKit.h>
#import "../Util/UIImageManager.h"
#import "../iCodeAppDelegate.h"

void*ProjLoad_loadUIImage(const char*path)
{
	NSString* imagePath = [NSString stringWithUTF8String:path];
	BOOL success = [UIImageManager loadImage:imagePath];
	if(success==YES)
	{
		return [UIImageManager getImage:imagePath];
	}
	return NULL;
}

void*ProjLoad_loadPlist(const char*path)
{
	return [(NSMutableDictionary*)ProjLoad_loadAllocatedPlist(path) autorelease];
}

void*ProjLoad_loadAllocatedPlist(const char*path)
{
	if(path==NULL)
	{
		return NULL;
	}
	else if(path[0]=='/')
	{
		return [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithUTF8String:path]];
	}
	else
	{
		const char*relPath = path;
		if(strlen(path)>2)
		{
			if(path[0]=='.' && path[1]=='/')
			{
				relPath = path+2;
			}
		}
		
		int size = strlen(FileTools_getExecutableDirectory()) + 2 + strlen(relPath);
		char*fullPath = (char*)malloc(size);
		ProjLoad_getPathWithExecutablePath(fullPath, path, size);
		NSMutableDictionary*dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithUTF8String:fullPath]];
		free(fullPath);
		return dict;
	}
}

bool ProjLoad_savePlist(void*dict, const char*path)
{
	/*NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString* userDir = [paths objectAtIndex:0];*/
	NSString* filePath = [NSString stringWithUTF8String:path];//[userDir stringByAppendingPathComponent:[NSString stringWithUTF8String:path]];
	BOOL success = [((NSDictionary*)dict) writeToFile:filePath atomically:YES];
	if(success)
	{
		return true;
	}
	return false;
}

const char* ProjLoad_getIntendedProjectNameField()
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	return [appDelegate.createProjectController.projectNameField.text UTF8String];
}

const char* ProjLoad_getIntendedProjectAuthorField()
{
	iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
	return [appDelegate.createProjectController.projectAuthorField.text UTF8String];
}

