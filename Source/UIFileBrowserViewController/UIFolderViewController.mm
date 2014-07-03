
#import "UIFolderViewController.h"
#import "UIFileBrowserViewController.h"
#import "DirectoryItem.h"
#import "../IconManager/IconManager.h"
#import "../Util/UIImageManager.h"


@implementation UIFolderViewController

@synthesize folder;
@synthesize folders;
@synthesize files;
@synthesize links;
@synthesize fileTable;
@synthesize navigator;

- (id)initWithName:(NSString*)name entries:(NSArray*)entries navigator:(UIFileBrowserViewController*)fileNavigator
{
	firstOpen = YES;
	
	if(fileNavigator==nil)
	{
		[self release];
		return nil;
	}
	
	self = [super init];
	if(self==nil)
	{
		return nil;
	}
	
	if(name!=nil)
	{
		[self setTitle:name];
		//[self.navigationItem setTitle:name];
	}
	
	navigator = fileNavigator;
	
	files = [[NSMutableArray alloc] init];
	folders = [[NSMutableArray alloc] init];
	links = [[NSMutableArray alloc] init];
	appNames = [[NSMutableArray alloc] init];
	appIcons = [[NSMutableArray alloc] init];
	
	folder = [[NSString alloc] initWithString:name];
	
	for(int i=0; i<[entries count]; i++)
	{
		DirectoryItem* item = [entries objectAtIndex:i];
		switch(item.type)
		{
			case DIRECTORYITEM_FILE:
			[files addObject:item.name];
			break;
			
			case DIRECTORYITEM_FOLDER:
			[folders addObject:item.name];
			break;
			
			case DIRECTORYITEM_LINK_FILE:
			[links addObject:item.name];
			[files addObject:item.name];
			break;
			
			case DIRECTORYITEM_LINK_FOLDER:
			[links addObject:item.name];
			[folders addObject:item.name];
			break;
		}
	}
	
	fileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	fileTable.delegate = self;
	fileTable.dataSource = self;
	[self.view addSubview:fileTable];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[self resetFrame];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self resetFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self resetFrame];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if(firstOpen)
	{
		firstOpen = NO;
		if(animated)
		{
			if(navigator!=nil && navigator.delegate!=nil && [navigator.delegate respondsToSelector:@selector(fileBrowser:didOpenFolder:)])
			{
				[navigator.delegate fileBrowser:navigator didOpenFolder:folder];
			}
		}
	}
	[self resetFrame];
}

- (void)resetFrame
{
	[fileTable setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (void)refreshWithEntries:(NSArray*)entries
{
	[files removeAllObjects];
	[folders removeAllObjects];
	[links removeAllObjects];
	
	for(int i=0; i<[entries count]; i++)
	{
		DirectoryItem* item = [entries objectAtIndex:i];
		switch(item.type)
		{
			case DIRECTORYITEM_FILE:
			[files addObject:item.name];
			break;
			
			case DIRECTORYITEM_FOLDER:
			[folders addObject:item.name];
			break;
			
			case DIRECTORYITEM_LINK_FILE:
			[links addObject:item.name];
			[files addObject:item.name];
			break;
			
			case DIRECTORYITEM_LINK_FOLDER:
			[links addObject:item.name];
			[folders addObject:item.name];
			break;
		}
	}
	
	[fileTable reloadData];
}

- (BOOL)itemIsLink:(NSString*)item
{
	for(unsigned int i=0; i<[links count]; i++)
	{
		if([item isEqual:[links objectAtIndex:i]])
		{
			return YES;
		}
	}
	return NO;
}

- (NSFilePath*)getPath
{
	if(self.navigator!=nil)
	{
		int index = -1;
		for(int i=0; i<[self.navigator.viewControllers count]; i++)
		{
			UIViewController*viewCtrl = [self.navigator.viewControllers objectAtIndex:i];
			if(viewCtrl == self)
			{
				index = i;
				i = [self.navigator.viewControllers count];
			}
		}
		
		if(index!=-1)
		{
			NSFilePath* path = nil;
			if(index==0)
			{
				path = [[NSFilePath alloc] initWithString:@"/"];
			}
			else
			{
				path = [[NSFilePath alloc]  initWithFilePath:[navigator.path pathAtIndex:(index-1)]];
			}
			
			NSFilePath*fullPath = [[NSFilePath alloc] initWithFilePaths:navigator.root, path, nil];
			[path release];
			return [fullPath autorelease];
		}
	}
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [folders count] + [files count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* cellID = nil;
	BOOL isFolder = NO;
	if(indexPath.row<[folders count])
	{
		cellID = [folders objectAtIndex:indexPath.row];
		isFolder = YES;
	}
	else
	{
		cellID = [files objectAtIndex:(indexPath.row-[folders count])];
	}
	BOOL isLink = [self itemIsLink:cellID];
	UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	
	[cell.textLabel setText:cellID];
	[cell setEditingAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	if(isFolder)
	{
		NSString* extension = [IconManager getExtensionForFilename:cellID];
		BOOL setAppIcon = NO;
		NSFilePath*path = [self getPath];
		if([extension isEqual:@"app"])
		{
			NSString* appName = cellID;
			if(path!=nil)
			{
				NSMutableFilePath* appPath = [[NSMutableFilePath alloc] initWithFilePath:path];
				[appPath addMember:appName];
				
				for(unsigned int i=0; i<[appNames count]; i++)
				{
					if([appName isEqual:[appNames objectAtIndex:i]])
					{
						[cell.imageView setImage:[appIcons objectAtIndex:i]];
						setAppIcon = YES;
						i = [appNames count];
					}
				}
				
				if(!setAppIcon)
				{
					UIImage* icon = [IconManager iconForApplication:[appPath pathAsString]];
					if(icon!=nil)
					{
						[cell.imageView setImage:icon];
						[appNames addObject:appName];
						[appIcons addObject:icon];
						setAppIcon = YES;
					}
				}
				[appPath release];
			}
		}
		if(!setAppIcon)
		{
			if([IconManager extensionIsPackage:extension])
			{
				[cell.imageView setImage:[IconManager imageForExtension:extension]];
			}
			else
			{
				[cell.imageView setImage:[IconManager imageForFolder]];
			}
		}
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	else
	{
		NSString* extension = [IconManager getExtensionForFilename:cellID];
		if([IconManager extensionIsPackage:extension])
		{
			[cell.imageView setImage:[IconManager imageForExtension:@""]];
		}
		else
		{
			[cell.imageView setImage:[IconManager imageForExtension:extension]];
		}
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	if(isLink)
	{
		cell.textLabel.textColor = [UIColor blueColor];
	}
	else
	{
		[cell.textLabel setTextColor:[UIColor blackColor]];
	}
	
	if(navigator!=nil && navigator.delegate!=nil && [navigator.delegate respondsToSelector:@selector(fileBrowser:reloadCell:)])
	{
		[navigator.delegate fileBrowser:navigator reloadCell:cell];
	}
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row < [folders count])
	{
		NSString*folderName = [folders objectAtIndex:indexPath.row];
		if([self itemIsLink:folderName])
		{
			[navigator didSelectFolderLink:folderName];
		}
		else
		{
			[navigator didSelectFolder:folderName];
		}
	}
	else
	{
		NSString*fileName = [files objectAtIndex:(indexPath.row-[folders count])];
		if([self itemIsLink:fileName])
		{
			[navigator didSelectFileLink:fileName];
		}
		else
		{
			[navigator didSelectFile:fileName];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(navigator!=nil && navigator.delegate!=nil && [navigator.delegate respondsToSelector:@selector(canEditItemsInFileBrowser:)])
	{
		return [navigator.delegate canEditItemsInFileBrowser:navigator];
	}
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row < [folders count])
	{
		if(navigator!=nil && navigator.delegate!=nil && [navigator.delegate respondsToSelector:@selector(fileBrowser:shouldDeleteFolder:)])
		{
			NSMutableFilePath* folderPath = [[NSMutableFilePath alloc] initWithFilePath:[self getPath]];
			NSString* folderName = [folders objectAtIndex:indexPath.row];
			[folderPath addMember:folderName];
			if([navigator.delegate fileBrowser:navigator shouldDeleteFolder:folderPath])
			{
				NSMutableString* command = [[NSMutableString alloc] initWithUTF8String:"rm -rf \""];
				[command appendString:[folderPath pathAsString]];
				[command appendString:@"\""];
				int result = system([command UTF8String]);
				if(result==0)
				{
					for(unsigned int i=0; i<[appNames count]; i++)
					{
						if([folderName isEqual:[appNames objectAtIndex:i]])
						{
							[appNames removeObjectAtIndex:i];
							[appIcons removeObjectAtIndex:i];
							i = [appNames count];
						}
					}
					
					[folders removeObjectAtIndex:indexPath.row];
					NSArray*indexes = [[NSArray alloc] initWithObjects:indexPath, nil];
					[fileTable deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationBottom];
					[indexes release];
					
					if([navigator.delegate respondsToSelector:@selector(fileBrowser:didDeleteFolder:)])
					{
						[navigator.delegate fileBrowser:navigator didDeleteFolder:folderPath];
					}
				}
				else
				{
					/*if(tableView.editing)
					{
						[tableView setEditing:NO animated:NO];
						[tableView setEditing:YES animated:NO];
					}*/
					
					if([navigator.delegate respondsToSelector:@selector(fileBrowser:errorDeletingFolder:)])
					{
						[navigator.delegate fileBrowser:navigator errorDeletingFolder:folderPath];
					}
				}
			}
			else
			{
				/*if(tableView.editing)
				{
					[tableView setEditing:NO animated:NO];
					[tableView setEditing:YES animated:NO];
				}*/
			}
			
			[folderPath release];
		}
		else
		{
			/*if(tableView.editing)
			{
				[tableView setEditing:NO animated:NO];
				[tableView setEditing:YES animated:NO];
			}*/
		}
	}
	else
	{
		if(navigator!=nil && navigator.delegate!=nil && [navigator.delegate respondsToSelector:@selector(fileBrowser:shouldDeleteFile:)])
		{
			NSMutableFilePath* filePath = [[NSMutableFilePath alloc] initWithFilePath:[self getPath]];
			[filePath addMember:[files objectAtIndex:(indexPath.row-[folders count])]];
			if([navigator.delegate fileBrowser:navigator shouldDeleteFile:filePath])
			{
				NSMutableString* command = [[NSMutableString alloc] initWithUTF8String:"rm -rf \""];
				[command appendString:[filePath pathAsString]];
				[command appendString:@"\""];
				int result = system([command UTF8String]);
				if(result==0)
				{
					[files removeObjectAtIndex:(indexPath.row-[folders count])];
					NSArray*indexes = [[NSArray alloc] initWithObjects:indexPath, nil];
					[fileTable deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationBottom];
					[indexes release];
					
					if([navigator.delegate respondsToSelector:@selector(fileBrowser:didDeleteFile:)])
					{
						[navigator.delegate fileBrowser:navigator didDeleteFile:filePath];
					}
				}
				else
				{
					/*if(tableView.editing)
					{
						[tableView setEditing:NO animated:NO];
						[tableView setEditing:YES animated:NO];
					}*/
					
					if([navigator.delegate respondsToSelector:@selector(fileBrowser:errorDeletingFile:)])
					{
						[navigator.delegate fileBrowser:navigator errorDeletingFile:filePath];
					}
				}
			}
			
			[filePath release];
		}
		else
		{
			/*if(tableView.editing)
			{
				[tableView setEditing:NO animated:NO];
				[tableView setEditing:YES animated:NO];
			}*/
		}
	}
}

- (void)dealloc
{
	[folder release];
	[files release];
	[folders release];
	[links release];
	[fileTable release];
	[appNames release];
	[appIcons release];
	[super dealloc];
}

@end
