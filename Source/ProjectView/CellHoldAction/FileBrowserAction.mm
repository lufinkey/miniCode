
#import "FileBrowserAction.h"
#import <unistd.h>

@implementation FileBrowserAction

@synthesize fileBrowserCtrl;

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController path:(NSString*)path root:(NSString*)root
{
	if([super initWithProjectTreeViewController:projectTreeViewController]==nil)
	{
		return nil;
	}
	
	fileBrowserCtrl = [[UIFileBrowserViewController alloc] initWithString:path root:root delegate:self];
	[self.viewCtrl presentModalViewController:fileBrowserCtrl animated:YES];
	
	return self;
}

- (void)fileBrowser:(UIFileBrowserViewController*)fileBrowser didSelectFolderLink:(NSString*)folder
{
	NSMutableFilePath* fullPath = [[NSMutableFilePath alloc] initWithFilePaths:fileBrowser.root, fileBrowser.path, nil];
	[fullPath addMember:folder];
	char* linkPathPtr = (char*)malloc(PATH_MAX);
	int linkResult = readlink([[fullPath pathAsString] UTF8String], linkPathPtr, PATH_MAX);
	if(linkResult==-1)
	{
		[fullPath release];
		free(linkPathPtr);
		return;
	}
	else
	{
		linkPathPtr[linkResult] = '\0';
		
		[fullPath release];
		
		NSString* linkPathString = [[NSString alloc] initWithUTF8String:linkPathPtr];
		free(linkPathPtr);
		NSFilePath* fullLinkPath = [[NSFilePath alloc] initWithString:linkPathString];
		[linkPathString release];
		
		if(![fullLinkPath containsSubfoldersOf:fileBrowser.root])
		{
			[fullLinkPath release];
			return;
		}
		
		NSFilePath* relPath = [fullLinkPath pathRelativeTo:fileBrowser.root];
		[fullLinkPath release];
		
		[fileBrowser navigateToPath:[relPath pathAsString] withRoot:[fileBrowser.root pathAsString]];
	}
}

- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFileLink:(NSFilePath*)file
{
	char* linkPathPtr = (char*)malloc(PATH_MAX);
	int linkResult = readlink([[file pathAsString] UTF8String], linkPathPtr, PATH_MAX);
	if(linkResult!=-1)
	{
		linkPathPtr[linkResult] = '\0';
		
		NSString* linkPathString = [[NSString alloc] initWithUTF8String:linkPathPtr];
		NSFilePath* linkPath = [[NSFilePath alloc] initWithString:linkPathString];
		[linkPathString release];
		
		if([linkPath containsSubfoldersOf:fileBrowser.root])
		{
			[linkPath release];
			free(linkPathPtr);
			return NO;
		}
	}
	free(linkPathPtr);
	return YES;
}


- (BOOL)fileBrowser:(UIFileBrowserViewController*)fileBrowser shouldHideFolderLink:(NSFilePath*)folder
{
	char* linkPathPtr = (char*)malloc(PATH_MAX);
	int linkResult = readlink([[folder pathAsString] UTF8String], linkPathPtr, PATH_MAX);
	if(linkResult!=-1)
	{
		linkPathPtr[linkResult] = '\0';
		
		NSString* linkPathString = [[NSString alloc] initWithUTF8String:linkPathPtr];
		NSFilePath* linkPath = [[NSFilePath alloc] initWithString:linkPathString];
		[linkPathString release];
		
		if([linkPath containsSubfoldersOf:fileBrowser.root])
		{
			[linkPath release];
			free(linkPathPtr);
			return NO;
		}
	}
	free(linkPathPtr);
	return YES;
}

- (void)dealloc
{
	[fileBrowserCtrl release];
	[super dealloc];
}

@end
