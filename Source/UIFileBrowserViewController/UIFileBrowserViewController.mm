
#import "UIFileBrowserViewController.h"
#import "DirectoryItem.h"
#import "UIFolderViewController.h"
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

NSMutableArray* UIFileBrowser_allocateArrayFromDirectory(const char*path)
{
	DIR*dir = opendir(path);
	if(dir!=NULL)
	{
		NSMutableArray* itemList = [[NSMutableArray alloc] init];
		
		struct dirent *entry = readdir(dir);
		
		while (entry!=NULL)
		{
			NSString*name = [[NSString alloc] initWithUTF8String:entry->d_name];
			if(![name isEqual:@"."] && ![name isEqual:@".."])
			{
				DirectoryItemType type = DIRECTORYITEM_UNKNOWN;
				if(entry->d_type==DT_REG)
				{
					type = DIRECTORYITEM_FILE;
				}
				else if(entry->d_type==DT_DIR)
				{
					type = DIRECTORYITEM_FOLDER;
				}
				else if(entry->d_type==DT_LNK)
				{
					//NSLog(@"link:");
					//NSLog(name);
					char* linkPath = (char*)malloc(PATH_MAX);
					NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:path];
					[fullPath appendString:@"/"];
					[fullPath appendString:name];
					if(realpath([fullPath UTF8String], linkPath)!=NULL)
					{
						//linkPath[linkResult] = '\0';
						
						struct stat s;
						if(stat(linkPath, &s)!=-1)
						{
							switch(s.st_mode&S_IFMT)
							{
								case S_IFREG:
								type = DIRECTORYITEM_LINK_FILE;
								break;
								
								case S_IFDIR:
								type = DIRECTORYITEM_LINK_FOLDER;
								break;
							}
						}
						else
						{
							switch(errno)
							{
								case EACCES:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Access denied");
								break;
								
								case EBADF:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Bad file descriptor");
								break;
								
								case EFAULT:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Bad address");
								break;
								
								case ELOOP:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Too many symbolic links while traversing path");
								break;
								
								case ENAMETOOLONG:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Path name is too long");
								break;
								
								case ENOENT:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Path does not exist");
								break;
								
								case ENOMEM:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Out of memory");
								break;
								
								case ENOTDIR:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": A component of the path prefix is not a directory");
								break;
								
								case EOVERFLOW:
								NSLog(@"%s%s%s", "Error: stat(const char*, struct stat): ", linkPath, ": Overflow; Path cannot be represented in structure");
								break;
							}
						}
					}
					[fullPath release];
					free(linkPath);
				}
				
				if(type!=DIRECTORYITEM_UNKNOWN)
				{
					DirectoryItem* item = [[DirectoryItem alloc] initWithName:name type:type];
					[itemList addObject:item];
					[item release];
				}
				[name release];
			}
			else
			{
				[name release];
			}
			
			entry = readdir(dir);
		}
		closedir(dir);
		
		return itemList;
	}
	return nil;
}

@interface UIFileBrowserViewController()
- (void)filterEntries:(NSMutableArray*)entries atPath:(NSFilePath*)folderPath;
@end


@implementation UIFileBrowserViewController

@synthesize root;
@synthesize path;
@synthesize delegate;
@synthesize globalToolbar;
@synthesize globalToolbarHidden;
@synthesize editing;

- (id)initWithRootViewController:(UIViewController*)rootViewController
{
	[self release];
	return nil;
}

- (id)initWithString:(NSString*)startPath
{
	NSFilePath* startFilePath = [[NSFilePath alloc] initWithString:startPath];
	self = [self initWithFilePath:startFilePath];
	[startFilePath release];
	return self;
}

- (id)initWithString:(NSString*)startPath delegate:(id<UIFileBrowserDelegate>)del
{
	NSFilePath* startFilePath = [[NSFilePath alloc] initWithString:startPath];
	self = [self initWithFilePath:startFilePath delegate:del];
	[startFilePath release];
	return self;
}

- (id)initWithString:(NSString*)startPath root:(NSString*)pathRoot
{
	NSFilePath* startFilePath = [[NSFilePath alloc] initWithString:startPath];
	NSFilePath* filePathRoot = [[NSFilePath alloc] initWithString:pathRoot];
	self = [self initWithFilePath:startFilePath root:filePathRoot];
	[startFilePath release];
	[filePathRoot release];
	return self;
}

- (id)initWithString:(NSString*)startPath root:(NSString*)pathRoot delegate:(id<UIFileBrowserDelegate>)del
{
	NSFilePath* startFilePath = [[NSFilePath alloc] initWithString:startPath];
	NSFilePath* filePathRoot = [[NSFilePath alloc] initWithString:pathRoot];
	self = [self initWithFilePath:startFilePath root:filePathRoot delegate:del];
	[startFilePath release];
	[filePathRoot release];
	return self;
}

- (id)initWithFilePath:(NSFilePath*)startPath
{
	return [self initWithFilePath:startPath delegate:nil];
}

- (id)initWithFilePath:(NSFilePath*)startPath delegate:(id<UIFileBrowserDelegate>)del
{
	NSFilePath* rootPath = [[NSFilePath alloc] initWithString:@""];
	self = [self initWithFilePath:startPath root:rootPath delegate:del];
	[rootPath release];
	return self;
}

- (id)initWithFilePath:(NSFilePath*)startPath root:(NSFilePath*)pathRoot
{
	return [self initWithFilePath:startPath root:pathRoot delegate:nil];
}

- (id)initWithFilePath:(NSFilePath*)startPath root:(NSFilePath*)pathRoot delegate:(id<UIFileBrowserDelegate>)del
{
	self.delegate = del;
	
	root = [[NSMutableFilePath alloc] initWithFilePath:pathRoot];
	path = [[NSMutableFilePath alloc] initWithFilePath:startPath];
	
	NSMutableArray* dirList = [[NSMutableArray alloc] init];
	for(unsigned int i=0; i<[path count]; i++)
	{
		NSFilePath* fullPath = [[NSFilePath alloc] initWithFilePaths:root, [path pathAtIndex:i], nil];
		NSMutableArray* dirItems = UIFileBrowser_allocateArrayFromDirectory([[fullPath pathAsString] UTF8String]);
		if(dirItems==nil)
		{
			[dirList release];
			[fullPath release];
			[self release];
			return nil;
		}
		[self filterEntries:dirItems atPath:fullPath];
		[fullPath release];
		[dirList addObject:dirItems];
		[dirItems release];
	}
	
	NSMutableArray* rootDirItems = UIFileBrowser_allocateArrayFromDirectory([[root pathAsString] UTF8String]);
	if(rootDirItems==nil)
	{
		[dirList release];
		[self release];
		return nil;
	}
	[self filterEntries:rootDirItems atPath:root];
	UIFolderViewController* rootPathController = [[UIFolderViewController alloc] initWithName:[root lastMember] entries:rootDirItems navigator:self];
	[rootDirItems release];
	
	self = [super initWithRootViewController:rootPathController];
	if(self==nil)
	{
		[dirList release];
		[rootPathController release];
		[self release];
		return nil;
	}
	[rootPathController release];
	
	for(unsigned int i=0; i<[dirList count]; i++)
	{
		UIFolderViewController*viewCtrl = [[UIFolderViewController alloc] initWithName:[path memberAtIndex:i] entries:[dirList objectAtIndex:i] navigator:self];
		[self pushViewController:viewCtrl animated:NO];
		[viewCtrl release];
	}
	
	[dirList release];
	
	globalToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
	globalToolbarHidden = YES;
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[globalToolbar setFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if(delegate!=nil)
	{
		if([delegate respondsToSelector:@selector(fileBrowser:viewDidDisappear:)])
		{
			[delegate fileBrowser:self viewDidDisappear:animated];
		}
	}
}

- (void)setEditing:(BOOL)edit
{
	[self setEditing:edit animated:NO];
}

- (void)setEditing:(BOOL)edit animated:(BOOL)animated
{
	editing = edit;
	for(unsigned int i=0; i<[self.viewControllers count]; i++)
	{
		UIViewController* viewCtrl = [self.viewControllers objectAtIndex:i];
		if([viewCtrl isKindOfClass:[UIFolderViewController class]])
		{
			UIFolderViewController* folderViewCtrl = (UIFolderViewController*)viewCtrl;
			[folderViewCtrl.fileTable setEditing:editing animated:animated];
		}
	}
}

- (void)setToolbarHidden:(BOOL)hidden
{
	if(!hidden && !globalToolbarHidden)
	{
		globalToolbarHidden = YES;
		[globalToolbar removeFromSuperview];
	}
	[super setToolbarHidden:hidden];
	if(self.visibleViewController!=nil && [self.visibleViewController isKindOfClass:[UIFolderViewController class]])
	{
		[((UIFolderViewController*)self.visibleViewController) resetFrame];
	}
}

- (void)setGlobalToolbarHidden:(BOOL)hidden
{
	[super setToolbarHidden:hidden];
	[globalToolbar setFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
	if(hidden && !globalToolbarHidden)
	{
		globalToolbarHidden = hidden;
		[globalToolbar removeFromSuperview];
	}
	else if(!hidden && globalToolbarHidden)
	{
		globalToolbarHidden = hidden;
		[self.view addSubview:globalToolbar];
	}
	if(self.visibleViewController!=nil && [self.visibleViewController isKindOfClass:[UIFolderViewController class]])
	{
		[((UIFolderViewController*)self.visibleViewController) resetFrame];
	}
}

- (void)dealloc
{
	[root release];
	[path release];
	[super dealloc];
}



#pragma mark - FileBrowser implementation



- (BOOL)selectFile:(NSString*)file
{
	UIFolderViewController* currentFolder = (UIFolderViewController*)self.topViewController;
	NSArray* files = [currentFolder files];
	
	int index = -1;
	
	for(int i=0; i<[files count]; i++)
	{
		if([file isEqual:[files objectAtIndex:i]])
		{
			index = i + [[currentFolder folders] count];
			i = [files count];
		}
	}
	if(index==-1)
	{
		return NO;
	}
	
	[[currentFolder fileTable] selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
	return YES;
}

- (BOOL)selectFolder:(NSString*)folder
{
	UIFolderViewController* currentFolder = (UIFolderViewController*)self.topViewController;
	NSArray* folders = [currentFolder folders];
	
	int index = -1;
	
	for(int i=0; i<[folders count]; i++)
	{
		if([folder isEqual:[folders objectAtIndex:i]])
		{
			index = i;
			i = [folders count];
		}
	}
	if(index==-1)
	{
		return NO;
	}
	
	[[currentFolder fileTable] selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
	return YES;
}

- (void)didSelectFile:(NSString*)file
{
	if(delegate!=nil && [delegate respondsToSelector:@selector(fileBrowser:didSelectFile:)])
	{
		[delegate fileBrowser:self didSelectFile:file];
	}
}

- (void)didSelectFolder:(NSString*)folder
{
	if(delegate!=nil)
	{
		if([delegate respondsToSelector:@selector(fileBrowser:didSelectFolder:)])
		{
			[delegate fileBrowser:self didSelectFolder:folder];
		}
		if([delegate respondsToSelector:@selector(fileBrowser:shouldOpenFolder:)]
		   && ![delegate fileBrowser:self shouldOpenFolder:folder])
		{
			return;
		}
	}
	
	[path addMember:folder];
	NSFilePath* fullPath = [[NSFilePath alloc] initWithFilePaths:root, path, nil];
	NSMutableArray*entries = UIFileBrowser_allocateArrayFromDirectory([[fullPath pathAsString] UTF8String]);
	[self filterEntries:entries atPath:fullPath];
	[fullPath release];
	if(entries==nil)
	{
		[path removeLastMember];
		return;
	}
	
	UIFolderViewController* folderViewCtrl = [[UIFolderViewController alloc] initWithName:folder entries:entries navigator:self];
	[entries release];
	if(delegate!=nil && [delegate respondsToSelector:@selector(fileBrowser:willOpenFolder:)])
	{
		[delegate fileBrowser:self willOpenFolder:folder];
	}
	[self pushViewController:folderViewCtrl animated:YES];
}

- (void)didSelectFileLink:(NSString*)file
{
	if(delegate!=nil && [delegate respondsToSelector:@selector(fileBrowser:didSelectFileLink:)])
	{
		[delegate fileBrowser:self didSelectFileLink:file];
	}
}

- (void)didSelectFolderLink:(NSString*)folder
{
	if(delegate!=nil && [delegate respondsToSelector:@selector(fileBrowser:didSelectFolderLink:)])
	{
		[delegate fileBrowser:self didSelectFolderLink:folder];
	}
}

- (BOOL)navigateToPath:(NSString*)pathString withRoot:(NSString*)rootString
{
	NSFilePath* rootPath = [[NSFilePath alloc] initWithString:rootString];
	NSFilePath* relPath = [[NSFilePath alloc] initWithString:pathString];
	
	NSMutableArray* dirList = [[NSMutableArray alloc] init];
	for(unsigned int i=0; i<[relPath count]; i++)
	{
		NSFilePath* fullPath = [[NSFilePath alloc] initWithFilePaths:rootPath, [relPath pathAtIndex:i], nil];
		NSMutableArray* dirItems = UIFileBrowser_allocateArrayFromDirectory([[fullPath pathAsString] UTF8String]);
		if(dirItems==nil)
		{
			[rootPath release];
			[relPath release];
			[dirList release];
			[fullPath release];
			return NO;
		}
		[self filterEntries:dirItems atPath:fullPath];
		[fullPath release];
		[dirList addObject:dirItems];
		[dirItems release];
	}
	
	NSMutableArray* viewCtrls = [[NSMutableArray alloc] init];
	
	NSMutableArray* rootDirItems = UIFileBrowser_allocateArrayFromDirectory([[rootPath pathAsString] UTF8String]);
	if(rootDirItems==nil)
	{
		[rootPath release];
		[relPath release];
		[dirList release];
		[viewCtrls release];
		return NO;
	}
	[self filterEntries:rootDirItems atPath:rootPath];
	UIFolderViewController* rootPathController = [[UIFolderViewController alloc] initWithName:[rootPath lastMember] entries:rootDirItems navigator:self];
	[rootDirItems release];
	[viewCtrls addObject:rootPathController];
	[rootPathController release];
	
	for(unsigned int i=0; i<[dirList count]; i++)
	{
		UIFolderViewController*viewCtrl = [[UIFolderViewController alloc] initWithName:[relPath memberAtIndex:i] entries:[dirList objectAtIndex:i] navigator:self];
		[viewCtrls addObject:viewCtrl];
		[viewCtrl release];
	}
	
	[root release];
	root = [[NSMutableFilePath alloc] initWithFilePath:rootPath];
	[path release];
	path = [[NSMutableFilePath alloc] initWithFilePath:relPath];
	
	[rootPath release];
	[relPath release];
	
	[self setViewControllers:viewCtrls animated:YES];
	[viewCtrls release];
	
	return YES;
}

- (void)refreshFolders
{
	NSMutableArray* dirList = [[NSMutableArray alloc] init];
	
	NSMutableArray* rootDirItems = UIFileBrowser_allocateArrayFromDirectory([[root pathAsString] UTF8String]);
	[self filterEntries:rootDirItems atPath:root];
	[dirList addObject:rootDirItems];
	[rootDirItems release];
	
	for(unsigned int i=0; i<[path count]; i++)
	{
		NSFilePath* fullPath = [[NSFilePath alloc] initWithFilePaths:root, [path pathAtIndex:i], nil];
		NSMutableArray* dirItems = UIFileBrowser_allocateArrayFromDirectory([[fullPath pathAsString] UTF8String]);
		[self filterEntries:dirItems atPath:fullPath];
		[fullPath release];
		[dirList addObject:dirItems];
		[dirItems release];
	}
	
	for(unsigned int i=0; i<[self.viewControllers count]; i++)
	{
		UIViewController* viewCtrl = [self.viewControllers objectAtIndex:i];
		if([viewCtrl isKindOfClass:[UIFolderViewController class]])
		{
			UIFolderViewController* folderViewCtrl = (UIFolderViewController*)viewCtrl;
			[folderViewCtrl refreshWithEntries:[dirList objectAtIndex:i]];
		}
	}
	
	[dirList release];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated
{
	if([self.topViewController isKindOfClass:[UIFolderViewController class]] && [self.viewControllers count]>1)
	{
		if(delegate!=nil)
		{
			NSMutableFilePath* backPath = [[NSMutableFilePath alloc] initWithFilePath:path];
			[backPath removeLastMember];
			if([delegate respondsToSelector:@selector(fileBrowser:willNavigateBackToPath:)])
			{
				[delegate fileBrowser:self willNavigateBackToPath:backPath];
			}
			[backPath release];
		}
		[path removeLastMember];
	}
	return [super popViewControllerAnimated:animated];
}

- (NSArray*)popToViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	int ctrlIndex = -1;
	for(int i=0; i<[self.viewControllers count]; i++)
	{
		if(viewController==[self.viewControllers objectAtIndex:i])
		{
			ctrlIndex = i;
			i = [self.viewControllers count];
		}
	}
	
	if(ctrlIndex!=-1)
	{
		if([viewController isKindOfClass:[UIFolderViewController class]])
		{
			UIFolderViewController* currentFolder = nil;
			if([self.topViewController isKindOfClass:[UIFolderViewController class]])
			{
				currentFolder = (UIFolderViewController*)self.topViewController;
			}
			else
			{
				for(int i=([self.viewControllers count]-1); i>ctrlIndex; i--)
				{
					UIViewController* viewCtrl = [self.viewControllers objectAtIndex:i];
					if([viewCtrl isKindOfClass:[UIFolderViewController class]])
					{
						currentFolder = (UIFolderViewController*)viewCtrl;
						i=0;
					}
				}
			}
			
			if(currentFolder!=nil && currentFolder!=viewController)
			{
				if(delegate!=nil && [delegate respondsToSelector:@selector(fileBrowser:willNavigateBackToPath:)])
				{
					if(ctrlIndex==0)
					{
						NSFilePath*backPath = [[NSFilePath alloc] initWithString:@""];
						[delegate fileBrowser:self willNavigateBackToPath:backPath];
						[backPath release];
					}
					else
					{
						NSFilePath*backPath = [path pathAtIndex:(ctrlIndex-1)];
						[delegate fileBrowser:self willNavigateBackToPath:backPath];
					}
				}
			}
		}
		
		while([path count]>ctrlIndex)
		{
			[path removeLastMember];
		}
	}
	return [super popToViewController:viewController animated:animated];
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
	if([self.viewControllers count]>1)
	{
		if(delegate!=nil && [delegate respondsToSelector:@selector(fileBrowser:willNavigateBackToPath:)])
		{
			NSFilePath*backPath = [[NSFilePath alloc] initWithString:@""];
			[delegate fileBrowser:self willNavigateBackToPath:backPath];
			[backPath release];
		}
	}
	[path removeAllMembers];
	return [super popToRootViewControllerAnimated:animated];
}

- (void)filterEntries:(NSMutableArray*)entries atPath:(NSFilePath*)folderPath
{
	if(delegate!=nil && ([delegate respondsToSelector:@selector(fileBrowser:shouldHideFile:)] || [delegate respondsToSelector:@selector(fileBrowser:shouldHideFolder:)] ||
						 [delegate respondsToSelector:@selector(fileBrowser:shouldHideFileLink:)] || [delegate respondsToSelector:@selector(fileBrowser:shouldHideFolderLink:)]))
	{
		for(int i=0; i<[entries count]; i++)
		{
			DirectoryItem* item = [entries objectAtIndex:i];
			if(item.type == DIRECTORYITEM_FILE)
			{
				if([delegate respondsToSelector:@selector(fileBrowser:shouldHideFile:)])
				{
					NSMutableFilePath*fPath = [[NSMutableFilePath alloc] initWithFilePath:folderPath];
					[fPath addMember:item.name];
					if([delegate fileBrowser:self shouldHideFile:fPath])
					{
						[entries removeObjectAtIndex:i];
						i--;
					}
					[fPath release];
				}
			}
			else if(item.type == DIRECTORYITEM_FOLDER)
			{
				if([delegate respondsToSelector:@selector(fileBrowser:shouldHideFolder:)])
				{
					NSMutableFilePath*fPath = [[NSMutableFilePath alloc] initWithFilePath:folderPath];
					[fPath addMember:item.name];
					if([delegate fileBrowser:self shouldHideFolder:fPath])
					{
						[entries removeObjectAtIndex:i];
						i--;
					}
					[fPath release];
				}
			}
			else if(item.type == DIRECTORYITEM_LINK_FILE)
			{
				if([delegate respondsToSelector:@selector(fileBrowser:shouldHideFileLink:)])
				{
					NSMutableFilePath*fPath = [[NSMutableFilePath alloc] initWithFilePath:folderPath];
					[fPath addMember:item.name];
					if([delegate fileBrowser:self shouldHideFileLink:fPath])
					{
						[entries removeObjectAtIndex:i];
						i--;
					}
					[fPath release];
				}
			}
			else if(item.type == DIRECTORYITEM_LINK_FOLDER)
			{
				if([delegate respondsToSelector:@selector(fileBrowser:shouldHideFolderLink:)])
				{
					NSMutableFilePath*fPath = [[NSMutableFilePath alloc] initWithFilePath:folderPath];
					[fPath addMember:item.name];
					if([delegate fileBrowser:self shouldHideFolderLink:fPath])
					{
						[entries removeObjectAtIndex:i];
						i--;
					}
					[fPath release];
				}
			}
		}
	}
	
	for(unsigned int i=0; i<[entries count]; i++)
	{
		for(int j=1; j<([entries count]-i); j++)
		{
			DirectoryItem* item1 = [[entries objectAtIndex:(j-1)] retain];
			DirectoryItem* item2 = [[entries objectAtIndex:j] retain];
			
			if([item1.name compare:item2.name options:NSForcedOrderingSearch]==NSOrderedDescending) //right is less than left
			{
				[entries replaceObjectAtIndex:(j-1) withObject:item2];
				[entries replaceObjectAtIndex:(j) withObject:item1];
			}
			
			[item1 release];
			[item2 release];
		}
	}
}

- (void)setDelegate:(id<UIFileBrowserDelegate>)del
{
	[super setDelegate:del];
	delegate = del;
}

@end
