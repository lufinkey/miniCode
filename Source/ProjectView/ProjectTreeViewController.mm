
#import "ProjectTreeViewController.h"
#import "../iCodeAppDelegate.h"
#import "../ProjectLoad/ProjLoadTools.h"
#import "../ObjCBridge/ObjCBridge.h"
#import "../Util/UIImageManager.h"
#import "../Util/UIBarImageButtonItem.h"
#import "../CompilerView/CompilerViewController.h"
#import "../CompilerView/BuildOptionsActionSheet.h"
#import "../IconManager/IconManager.h"
#import "../PreferencesView/GlobalPreferences.h"

#import "CellHoldAction/AddFrameworkAction.h"
#import "CellHoldAction/CellHoldAction.h"
#import "CellHoldAction/CopyAction.h"
#import "CellHoldAction/CreateFileAction.h"
#import "CellHoldAction/CreateFolderAction.h"
#import "CellHoldAction/DeleteAction.h"
#import "CellHoldAction/EditExternalLibrariesAction.h"
#import "CellHoldAction/EditIncludeFoldersAction.h"
#import "CellHoldAction/EditLibFoldersAction.h"
#import "CellHoldAction/ImportExternalLibraryAction.h"
#import "CellHoldAction/ImportFileAction.h"
#import "CellHoldAction/ImportFolderAction.h"
#import "CellHoldAction/LinkIncludeFolderAction.h"
#import "CellHoldAction/LinkLibFolderAction.h"
#import "CellHoldAction/MoveAction.h"
#import "CellHoldAction/RenameAction.h"
#import "CellHoldAction/SelectIncludeFolderAction.h"
#import "CellHoldAction/SelectLibFolderAction.h"

#import "CellHoldAction/ProjectTreeViewController+CellHoldAction.h"


@interface ProjectTreeViewController()
+ (void)sortStringPathArray:(NSMutableArray*)paths;
- (void)removeFrameworkAction;
- (void)projectSettingsAction;
@property (nonatomic, assign) ProjectTreeViewCell* selectedCell;
@end

void ProjectTreeViewController_updateIncludeFolder(void*data);
void ProjectTreeViewController_updateLibFolder(void*data);
void ProjectTreeViewController_updateDynamicFolder(void*data);
void ProjectTreeViewController_updateFrameworkFolder(void*data);


@implementation ProjectTreeViewController

@synthesize treeView;

@synthesize srcCell;
@synthesize resCell;
@synthesize extCell;
@synthesize includeCell;
@synthesize libCell;
@synthesize frameworksCell;

@synthesize currentHoldAction;
@synthesize selectedCell;
@synthesize operationHUD;
@synthesize obstructView;


- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	[UIImageManager loadImage:@"Images/icons/folder_small.png"];
	
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	treeView = [[UITreeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	self.treeView.delegate = self;
	
	ProjectTreeViewCell*rootCell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_CATEGORY identifier:@"root"];
	[rootCell setBranchOpen:YES];
	[rootCell setFrame:CGRectMake(0, 8, rootCell.frame.size.width, rootCell.frame.size.height)];
	if([UIImageManager loadImage:@"Images/icons/file_xcodeproj.png"])
	{
		[rootCell setIcon:[UIImageManager getImage:@"Images/icons/file_xcodeproj.png"]];
	}
	[treeView setRootCell:rootCell];
	[self.view addSubview:treeView];
	
	srcCell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_CATEGORY identifier:@"Source Files"];
	[srcCell setCategoryName:@"src"];
	[rootCell addMember:srcCell];
	
	resCell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_CATEGORY identifier:@"Resources"];
	[resCell setCategoryName:@"res"];
	[rootCell addMember:resCell];
	
	extCell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_CATEGORY identifier:@"External"];
	[extCell setCategoryName:@"ext"];
	includeCell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_INCLUDEDIR identifier:@""];
	[includeCell setText:@"include"];
	libCell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_LIBDIR identifier:@""];
	[libCell setText:@"lib"];
	[extCell addMember:includeCell];
	[extCell addMember:libCell];
	[rootCell addMember:extCell];
	
	frameworksCell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_CATEGORY identifier:@"Frameworks"];
	[frameworksCell setCategoryName:@"frameworks"];
	[rootCell addMember:frameworksCell];
	
	[rootCell release];
	
	UIBarButtonItem*exitButton = [[UIBarButtonItem alloc] initWithTitle:@"Exit" style:UIBarButtonItemStyleDone target:self action:@selector(exitProjectView)];
	[self.navigationItem setLeftBarButtonItem:exitButton animated:YES];
	[exitButton release];
	
	[UIImageManager loadImage:@"Images/buttons_white/build.png"];
	UIBarImageButtonItem* buildButton = [[UIBarImageButtonItem alloc] initWithImage:[UIImageManager getImage:@"Images/buttons_white/build.png"] target:self action:@selector(buildButtonSelected)];
	[buildButton setSize:32];
	[self.navigationItem setRightBarButtonItem:buildButton];
	[buildButton release];
	
	projectMenu = [[UIActionSheet alloc] initWithTitle:@"Project Options"
											  delegate:self
									 cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:nil
									 otherButtonTitles:@"Project Settings", nil];
	
	srcFolderMenu = [[UIActionSheet alloc] initWithTitle:@"Source Files"
												delegate:self
									   cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
									   otherButtonTitles:@"Import File", @"Import Folder", @"Create File", @"Create Folder", nil];
	
	resFolderMenu = [[UIActionSheet alloc] initWithTitle:@"Resources"
												delegate:self
									   cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
									   otherButtonTitles:@"Import File", @"Import Folder", @"Create File", @"Create Folder", nil];
	
	extFolderMenu = [[UIActionSheet alloc] initWithTitle:@"External Libraries"
												delegate:self
									   cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
									   otherButtonTitles:@"Import Library", @"Edit Library Folders", nil];
	
	includeMenu = [[UIActionSheet alloc] initWithTitle:@"Include Folders"
											  delegate:self
									 cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:nil
									 otherButtonTitles:@"Link Folder", @"Edit Include Folders", nil];
	
	libMenu = [[UIActionSheet alloc] initWithTitle:@"Folder Options"
										  delegate:self
								 cancelButtonTitle:@"Cancel"
							destructiveButtonTitle:nil
								 otherButtonTitles:@"Link Folder", @"Edit Lib Folders", nil];
	
	frameworksMenu = [[UIActionSheet alloc] initWithTitle:@"Frameworks"
												 delegate:self
										cancelButtonTitle:@"Cancel"
								   destructiveButtonTitle:nil
										otherButtonTitles:@"Add Framework", nil];
	
	fileMenu = [[UIActionSheet alloc] initWithTitle:@"File Options"
										   delegate:self
								  cancelButtonTitle:@"Cancel"
							 destructiveButtonTitle:nil
								  otherButtonTitles:@"Rename File", @"Delete File", @"Move File", @"Copy File", nil];
	
	folderMenu = [[UIActionSheet alloc] initWithTitle:@"Folder Options"
											 delegate:self
									cancelButtonTitle:@"Cancel"
							   destructiveButtonTitle:nil
									otherButtonTitles:@"Rename Folder", @"Delete Folder", @"Move Folder", @"Copy Folder",
													@"Import File", @"Import Folder", @"Create File", @"Create Folder", nil];
	
	frameworkMenu = [[UIActionSheet alloc] initWithTitle:@"Framework Options"
												delegate:self
									   cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
									   otherButtonTitles:@"Remove Framework", nil];
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[treeView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}



#pragma mark -
#pragma mark ProjectData Loading



- (void)loadWithProjectData:(ProjectData_struct*)projData
{
	[((ProjectTreeViewCell*)treeView.rootCell) setText:[NSString stringWithUTF8String:ProjectData_getFolderName(projData)]];
	
	[srcCell removeAllMembers];
	[resCell removeAllMembers];
	[includeCell removeAllMembers];
	[libCell removeAllMembers];
	
	StringTree_struct srcTree = ProjectData_getSourceFiles(projData);
	[ProjectTreeViewController addStringTreeToCell:srcCell tree:(&srcTree)];
	
	StringTree_struct resTree = ProjectData_getResourceFiles(projData);
	[ProjectTreeViewController addStringTreeToCell:resCell tree:(&resTree)];
	
	StringList_struct frameworkList = ProjectData_getFrameworkList(projData);
	for(int i=0; i<StringList_size(&frameworkList); i++)
	{
		NSMutableString* framework = [[NSMutableString alloc] initWithUTF8String:StringList_get(&frameworkList, i)];
		if([framework length]<10 || ![[framework substringFromIndex:([framework length]-10)] isEqual:@".framework"])
		{
			[framework appendString:@".framework"];
		}
		
		ProjectTreeViewCell* pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FRAMEWORK identifier:framework];
		[frameworksCell addMember:pcell];
		[pcell release];
		[framework release];
	}
}

- (id<FileEditorDelegate>)getFileViewerByExtension:(NSString*)extension
{
	if([extension length]>0)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		if(NSString_isEqualToObjectInArray(extension, EXTENSIONS_CODEEDITOR))
		{
			return appDelegate.codeEditorController;
		}
		else if(NSString_isEqualToObjectInArray(extension, EXTENSIONS_IMAGEVIEWER))
		{
			return appDelegate.imageViewerController;
		}
		else if(NSString_isEqualToObjectInArray(extension, EXTENSIONS_PLISTEDITOR))
		{
			return appDelegate.plistViewerController;
		}
	}
	return nil;
}

- (void)exitProjectView
{
	[((ProjectTreeViewCell*)treeView.rootCell) setText:@""];
	
	[treeView.rootCell setBranchOpen:YES];
	[srcCell removeAllMembers];
	[srcCell setBranchOpen:NO];
	[resCell removeAllMembers];
	[resCell setBranchOpen:NO];
	[extCell setBranchOpen:NO];
	[includeCell removeAllMembers];
	[includeCell setBranchOpen:NO];
	[libCell removeAllMembers];
	[libCell setBranchOpen:NO];
	[frameworksCell removeAllMembers];
	[frameworksCell setBranchOpen:NO];
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectData_saveProjectPlist(appDelegate.projData);
	ProjectData_destroyInstance(appDelegate.projData);
	appDelegate.projData = NULL;
	
	if(appDelegate.compilerController!=nil)
	{
		appDelegate.compilerController = nil;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark UITreeView Loading



+ (void)sortStringPathArray:(NSMutableArray*)paths
{
	for(unsigned int i=0; i<[paths count]; i++)
	{
		for(int j=1; j<([paths count]-i); j++)
		{
			NSString* string1 = [[paths objectAtIndex:(j-1)] retain];
			NSFilePath* path1 = [[NSFilePath alloc] initWithString:string1];
			NSString* string2 = [[paths objectAtIndex:j] retain];
			NSFilePath* path2 = [[NSFilePath alloc] initWithString:string2];
			
			if([[path1 lastMember] compare:[path2 lastMember]]==NSOrderedDescending) //right is less than left
			{
				[paths replaceObjectAtIndex:(j-1) withObject:string2];
				[paths replaceObjectAtIndex:(j) withObject:string1];
			}
			
			[string1 release];
			[path1 release];
			[string2 release];
			[path2 release];
		}
	}
}

+ (void)addStringTreeToCell:(ProjectTreeViewCell*)cell tree:(StringTree_struct*)tree
{
	StringList_struct branchNames = StringTree_getBranchNames(tree);
	for(unsigned int i=0; i<StringList_size(&branchNames); i++)
	{
		const char*branchName = StringList_get(&branchNames, i);
		ProjectTreeViewCell*member = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FOLDER identifier:[NSString stringWithUTF8String:branchName]];
		[cell addMember:member];
		StringTree_struct branch = StringTree_getBranch(tree, branchName);
		[ProjectTreeViewController addStringTreeToCell:member tree:(&branch)];
		[member release];
	}
	
	StringList_struct members = StringTree_getMembers(tree);
	for(unsigned int i=0; i<StringList_size(&members); i++)
	{
		const char*memberName = StringList_get(&members, i);
		ProjectTreeViewCell*member = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:[NSString stringWithUTF8String:memberName]];
		[cell addMember:member];
		[member release];
	}
}

+ (void)addDirectoryListToCell:(ProjectTreeViewCell*)cell list:(StringList_struct*)list
{
	ProjectData_struct*projData = ((iCodeAppDelegate*)[[UIApplication sharedApplication] delegate]).projData;
	const char*projFolderName = ProjectData_getFolderName(projData);
	
	int extPathSize = strlen(ProjLoad_getSavedProjectsFolder()) + 1 + strlen(projFolderName) + 1 + strlen("ext") + 1 + 1;
	char*projExtFolder = (char*)malloc(extPathSize);
	const char*extPathArray[4] = {ProjLoad_getSavedProjectsFolder(),"/",projFolderName,"/ext"};
	concatStrings(projExtFolder, extPathArray, extPathSize, 4);
	
	NSMutableArray* folderPaths = [[NSMutableArray alloc] init];
	NSMutableArray* filePaths = [[NSMutableArray alloc] init];
	for(unsigned int i=0; i<StringList_size(list); i++)
	{
		const char*dirName = StringList_get(list, i);
		if(strlen(dirName)!=0)
		{
			bool allocated = false;
			char* fullDir = (char*)dirName;
			if(dirName[0]!='/')
			{
				int strSize = (extPathSize-1) + 1 + strlen(dirName) + 1;
				fullDir = (char*)malloc(strSize);
				allocated = true;
				concatPath(fullDir, projExtFolder, dirName, strSize);
			}
			
			StringList_struct*folderList = FileTools_getFoldersInDirectory(fullDir);
			for (int j=0; j<StringList_size(folderList); j++)
			{
				const char* folder = StringList_get(folderList, j);
				int strSize = strlen(fullDir) + 1 + strlen(folder) + 1;
				char* folderPath = (char*)malloc(strSize);
				concatPath(folderPath, fullDir, folder, strSize);
				NSString* folderPathString = [[NSString alloc] initWithUTF8String:folderPath];
				[folderPaths addObject:folderPathString];
				[folderPathString release];
				/*ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_DYNAMICFOLDER identifier:[NSString stringWithUTF8String:folderPath]];
				[cell addMember:pcell];
				[pcell release];*/
				free(folderPath);
			}
			StringList_destroyInstance(folderList);
			
			StringList_struct*fileList = FileTools_getFilesInDirectory(fullDir);
			for (int j=0; j<StringList_size(fileList); j++)
			{
				const char* file = StringList_get(fileList, j);
				int strSize = strlen(fullDir) + 1 + strlen(file) + 1;
				char* filePath = (char*)malloc(strSize);
				concatPath(filePath, fullDir, file, strSize);
				NSString* filePathString = [[NSString alloc] initWithUTF8String:filePath];
				[filePaths addObject:filePathString];
				[filePathString release];
				/*ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:[NSString stringWithUTF8String:filePath]];
				[cell addMember:pcell];
				[pcell release];*/
				free(filePath);
			}
			StringList_destroyInstance(fileList);
			
			if(allocated)
			{
				free(fullDir);
			}
		}
	}
	
	[ProjectTreeViewController sortStringPathArray:folderPaths];
	[ProjectTreeViewController sortStringPathArray:filePaths];
	
	NSMutableArray* addedCells = [[NSMutableArray alloc] init];
	
	for(unsigned int i=0; i<[folderPaths count]; i++)
	{
		NSString* path = [folderPaths objectAtIndex:i];
		ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_DYNAMICFOLDER identifier:path];
		[addedCells addObject:pcell];
		[cell performSelectorOnMainThread:@selector(addMember:) withObject:pcell waitUntilDone:NO];
		//[cell addMember:pcell];
		[pcell release];
	}
	
	for(unsigned int i=0; i<[filePaths count]; i++)
	{
		NSString* path = [filePaths objectAtIndex:i];
		ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:path];
		[addedCells addObject:pcell];
		[cell performSelectorOnMainThread:@selector(addMember:) withObject:pcell waitUntilDone:NO];
		//[cell addMember:pcell];
		[pcell release];
	}
	
	[addedCells autorelease];
	//[addedCells release];
	
	[folderPaths release];
	[filePaths release];
	
	free(projExtFolder);
}

+ (void)expandDynamicFolderCell:(ProjectTreeViewCell*)cell
{
	if(cell.type == PROJECTTREECELL_DYNAMICFOLDER && [cell count]==0)
	{
		const char*cellPath = [cell.identifier UTF8String];
		if(strlen(cellPath)!=0 && cellPath[0]=='/')
		{
			StringList_struct*folderList = FileTools_getFoldersInDirectory(cellPath);
			for(int i=0; i<StringList_size(folderList); i++)
			{
				const char*folder = StringList_get(folderList, i);
				int strSize = strlen(cellPath) + 1 + strlen(folder) + 1;
				char*folderPath = (char*)malloc(strSize);
				concatPath(folderPath, cellPath, folder, strSize);
				ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_DYNAMICFOLDER identifier:[NSString stringWithUTF8String:folderPath]];
				[cell addMember:pcell];
				[pcell release];
				free(folderPath);
			}
			StringList_destroyInstance(folderList);
			
			StringList_struct*fileList = FileTools_getFilesInDirectory(cellPath);
			for(int i=0; i<StringList_size(fileList); i++)
			{
				const char*file = StringList_get(fileList, i);
				//int strSize = strlen(cellPath) + 1 + strlen(file) + 1;
				/*char*filePath = (char*)malloc(strSize);
				concatPath(filePath, cellPath, file, strSize);*/
				ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:[NSString stringWithUTF8String:file]];
				[cell addMember:pcell];
				[pcell release];
				//free(filePath);
			}
			StringList_destroyInstance(fileList);
		}
	}
}



#pragma mark -
#pragma mark Events



- (void)treeView:(UITreeView*)treeView didSelectButtonOnCell:(UITreeViewCell*)cell
{
	//
}

- (void)treeView:(UITreeView*)treeView didSelectCell:(UITreeViewCell*)cell
{
	if([cell isKindOfClass:[ProjectTreeViewCell class]])
	{
		ProjectTreeViewCell*pcell = (ProjectTreeViewCell*)cell;
		if(pcell.type == PROJECTTREECELL_FILE)
		{
			id<FileEditorDelegate> fileViewer = [self getFileViewerByExtension:pcell.extension];
			if(fileViewer!=nil)
			{
				NSString*relPath = [pcell getPath];
				if([relPath length]==0)
				{
					return;
				}
				
				if([relPath UTF8String][0]=='/')
				{
					if([fileViewer loadWithFile:relPath])
					{
						if([[pcell getCategory] isEqual:@"ext"] || [[pcell getCategory] isEqual:@"frameworks"])
						{
							[fileViewer setFileLocked:YES];
						}
						[self.navigationController pushViewController:(UIViewController*)fileViewer animated:YES];
					}
				}
				else
				{
					NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
					[fullPath appendString:@"/"];
					NSString*saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(((iCodeAppDelegate*)[[UIApplication sharedApplication] delegate]).projData)];
					[fullPath appendString:saveFolder];
					[saveFolder release];
					[fullPath appendString:@"/"];
					
					NSString*categoryName = [pcell getCategory];
					if([categoryName length]!=0)
					{
						[fullPath appendString:categoryName];
						[fullPath appendString:@"/"];
					}
					[fullPath appendString:relPath];
					if([fileViewer loadWithFile:fullPath])
					{
						if([[pcell getCategory] isEqual:@"ext"] || [[pcell getCategory] isEqual:@"frameworks"])
						{
							[fileViewer setFileLocked:YES];
						}
						[self.navigationController pushViewController:(UIViewController*)fileViewer animated:YES];
					}
					[fullPath release];
				}
			}
		}
	}
}

- (void)treeView:(UITreeView*)treeView branchWillOpen:(UITreeViewCell*)cell
{
	if([cell isKindOfClass:[ProjectTreeViewCell class]])
	{
		//iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		
		ProjectTreeViewCell*pcell = (ProjectTreeViewCell*)cell;
		selectedCell = pcell;
		if(pcell.type == PROJECTTREECELL_INCLUDEDIR && [pcell count]==0)
		{
			[self showObstructionInView:self.navigationController.view];
			operationHUD = [LGViewHUD defaultHUD];
			[operationHUD setTopText:@"Loading..."];
			[operationHUD setBottomText:@""];
			[operationHUD setActivityIndicatorOn:YES];
			[operationHUD showInView:self.navigationController.view withAnimation:HUDAnimationShowZoom];
			
			//StringList_struct includeDirs = ProjectData_getIncludeDirs(appDelegate.projData);
			//[ProjectTreeViewController addDirectoryListToCell:pcell list:&includeDirs];
			
			runCallbackInThread(&ProjectTreeViewController_updateIncludeFolder, self, false);
		}
		else if(pcell.type == PROJECTTREECELL_LIBDIR && [pcell count]==0)
		{
			[self showObstructionInView:self.navigationController.view];
			operationHUD = [LGViewHUD defaultHUD];
			[operationHUD setTopText:@"Loading..."];
			[operationHUD setBottomText:@""];
			[operationHUD setActivityIndicatorOn:YES];
			[operationHUD showInView:self.navigationController.view withAnimation:HUDAnimationShowZoom];
			
			runCallbackInThread(&ProjectTreeViewController_updateLibFolder, self, false);
		}
		else if(pcell.type == PROJECTTREECELL_DYNAMICFOLDER && [pcell count]==0)
		{
			[self showObstructionInView:self.navigationController.view];
			operationHUD = [LGViewHUD defaultHUD];
			[operationHUD setTopText:@"Loading..."];
			[operationHUD setBottomText:@""];
			[operationHUD setActivityIndicatorOn:YES];
			[operationHUD showInView:self.navigationController.view withAnimation:HUDAnimationShowZoom];
			
			runCallbackInThread(&ProjectTreeViewController_updateDynamicFolder, self, false);
		}
		else if(pcell.type == PROJECTTREECELL_FRAMEWORK && [pcell count]==0)
		{
			[self showObstructionInView:self.navigationController.view];
			operationHUD = [LGViewHUD defaultHUD];
			[operationHUD setTopText:@"Loading..."];
			[operationHUD setBottomText:@""];
			[operationHUD setActivityIndicatorOn:YES];
			[operationHUD showInView:self.navigationController.view withAnimation:HUDAnimationShowZoom];
			
			runCallbackInThread(&ProjectTreeViewController_updateFrameworkFolder, self, false);
		}
	}
}

- (void)treeView:(UITreeView*)treeView branchDidClose:(UITreeViewCell*)cell
{
	if([cell isKindOfClass:[ProjectTreeViewCell class]])
	{
		ProjectTreeViewCell*pcell = (ProjectTreeViewCell*)cell;
		if(pcell.type == PROJECTTREECELL_INCLUDEDIR)
		{
			[pcell removeAllMembers];
		}
		else if(pcell.type == PROJECTTREECELL_LIBDIR)
		{
			[pcell removeAllMembers];
		}
		else if(pcell.type == PROJECTTREECELL_DYNAMICFOLDER)
		{
			[pcell removeAllMembers];
		}
		else if(pcell.type == PROJECTTREECELL_FRAMEWORK)
		{
			[pcell removeAllMembers];
		}
	}
}

- (void)buildButtonSelected
{
	BuildOptionsActionSheet* buildOptions = [[BuildOptionsActionSheet alloc] initForViewController:self];
	[buildOptions showInView:self.view];
	[buildOptions release];
}

- (void)treeView:(UITreeView*)treeView didHoldDownOnCell:(UITreeViewCell*)cell
{
	if([cell isKindOfClass:[ProjectTreeViewCell class]])
	{
		ProjectTreeViewCell*pcell = (ProjectTreeViewCell*)cell;
		selectedCell = pcell;
		switch(pcell.type)
		{
			case PROJECTTREECELL_CATEGORY:
			{
				if([pcell.categoryName isEqual:@"src"])
				{
					[srcFolderMenu showInView:pcell];
					[pcell deselect];
				}
				else if([pcell.categoryName isEqual:@"res"])
				{
					[resFolderMenu showInView:pcell];
					[pcell deselect];
				}
				else if([pcell.categoryName isEqual:@"ext"])
				{
					[extFolderMenu showInView:pcell];
					[pcell deselect];
				}
				else if([pcell.categoryName isEqual:@"frameworks"])
				{
					[frameworksMenu showInView:pcell];
					[pcell deselect];
				}
				else if(pcell.supercell==nil)
				{
					[projectMenu showInView:pcell];
					[pcell deselect];
				}
			}
			break;
			
			case PROJECTTREECELL_FILE:
			{
				NSString* categoryName = [pcell getCategory];
				if([categoryName isEqual:@"src"] || [categoryName isEqual:@"res"])
				{
					[fileMenu showInView:pcell];
					[pcell deselect];
				}
			}
			break;
			
			case PROJECTTREECELL_FOLDER:
			{
				NSString* categoryName = [pcell getCategory];
				if([categoryName isEqual:@"src"] || [categoryName isEqual:@"res"])
				{
					[folderMenu showInView:pcell];
					[pcell deselect];
				}
			}
			break;
			
			case PROJECTTREECELL_INCLUDEDIR:
			{
				[includeMenu showInView:pcell];
				[pcell deselect];
			}
			break;
			
			case PROJECTTREECELL_LIBDIR:
			{
				[libMenu showInView:pcell];
				[pcell deselect];
			}
			break;
			
			case PROJECTTREECELL_FRAMEWORK:
			{
				[frameworkMenu showInView:pcell];
				[pcell deselect];
			}
			break;
		}
	}
}

- (void)removeFrameworkAction
{
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	NSMutableString* frameworkName = [[NSMutableString alloc] initWithString:selectedCell.identifier];
	if([frameworkName length]>10 && [[frameworkName substringFromIndex:([frameworkName length]-10)] isEqual:@".framework"])
	{
		[frameworkName deleteCharactersInRange:NSMakeRange(([frameworkName length]-10), 10)];
	}
	
	StringList_struct frameworks = ProjectData_getFrameworkList(appDelegate.projData);
	for(int i=0; i<StringList_size(&frameworks); i++)
	{
		NSString* cmpFramework = [[NSString alloc] initWithUTF8String:StringList_get(&frameworks, i)];
		if([frameworkName isEqual:cmpFramework])
		{
			StringList_remove(&frameworks, i);
			i = StringList_size(&frameworks);
		}
		[cmpFramework release];
	}
	
	ProjectData_saveProjectPlist(appDelegate.projData);
	
	[selectedCell.supercell removeMember:selectedCell];
	
	[frameworkName release];
}

- (void)projectSettingsAction
{
	ProjectSettingsViewController* viewCtrl = [[ProjectSettingsViewController alloc] init];
	[viewCtrl setTitle:@"Settings"];
	UINavigator* navigator = [[UINavigator alloc] initWithRootViewController:viewCtrl];
	[viewCtrl release];
	[self presentModalViewController:navigator animated:YES];
	[navigator release];
}

- (void)showObstructionInView:(UIView*)view
{
	if(obstructView==nil)
	{
		obstructView = [[UIView alloc] initWithFrame:view.frame];
	}
	[obstructView setUserInteractionEnabled:YES];
	[obstructView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
	[obstructView setFrame:view.frame];
	[view addSubview:obstructView];
}

- (void)hideOperationHUDZoom
{
	[operationHUD hideWithAnimation:HUDAnimationHideZoom];
}

- (void)hideOperationHUDFade
{
	[operationHUD hideWithAnimation:HUDAnimationHideFadeOut];
}

- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(actionSheet==projectMenu)
	{
		//Project Menu
		switch(buttonIndex)
		{
			case 0:
			//Project Settings - Project Menu
			{
				[self projectSettingsAction];
			}
			break;
		}
	}
	else if(actionSheet==srcFolderMenu)
	{
		//Source Folder Menu
		switch(buttonIndex)
		{
			case 0:
			//Import File - Source Folder Menu
			{
				currentHoldAction = [[ImportFileAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 1:
			//Import Folder - Source Folder Menu
			{
				currentHoldAction = [[ImportFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 2:
			//Create File - Source Folder Menu
			{
				currentHoldAction = [[CreateFileAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 3:
			//Create Folder - Source Folder Menu
			{
				currentHoldAction = [[CreateFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==resFolderMenu)
	{
		//Resource Folder Menu
		switch(buttonIndex)
		{
			case 0:
			//Import File - Resource Folder Menu
			{
				currentHoldAction = [[ImportFileAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 1:
			//Import Folder - Resource Folder Menu
			{
				currentHoldAction = [[ImportFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 2:
			//Create File - Resource Folder Menu
			{
				currentHoldAction = [[CreateFileAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 3:
			//Create Folder - Resource Folder Menu
			{
				currentHoldAction = [[CreateFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==extFolderMenu)
	{
		//External Folder Menu
		switch(buttonIndex)
		{
			case 0:
			//Import Library - External Folder Menu
			{
				currentHoldAction = [[ImportExternalLibraryAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 1:
			//Edit Library Folders - External Folder Menu
			{
				currentHoldAction = [[EditExternalLibrariesAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==includeMenu)
	{
		//Include Menu
		switch(buttonIndex)
		{
			case 0:
			//Link Folder - Include Menu
			{
				currentHoldAction = [[LinkIncludeFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 1:
			//Edit Include Folders - Include Menu
			{
				currentHoldAction = [[EditIncludeFoldersAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==libMenu)
	{
		//Lib Menu
		switch(buttonIndex)
		{
			case 0:
			//Link Folder - Lib Menu
			{
				currentHoldAction = [[LinkLibFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 1:
			//Edit Lib Folders - Lib Menu
			{
				currentHoldAction = [[EditLibFoldersAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==frameworksMenu)
	{
		//Frameworks Menu
		switch(buttonIndex)
		{
			case 0:
			//Add Framework - Frameworks Menu
			{
				currentHoldAction = [[AddFrameworkAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==fileMenu)
	{
		//File Menu
		switch(buttonIndex)
		{
			case 0:
			//Rename File - File Menu
			{
				currentHoldAction = [[RenameAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 1:
			//Delete File - File Menu
			{
				currentHoldAction = [[DeleteAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 2:
			//Move File - File Menu
			{
				currentHoldAction = [[MoveAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 3:
			//Copy File - File Menu
			{
				currentHoldAction = [[CopyAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==folderMenu)
	{
		//Folder Menu
		switch(buttonIndex)
		{
			case 0:
			//Rename Folder - Folder Menu
			{
				currentHoldAction = [[RenameAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 1:
			//Delete Folder - Folder Menu
			{
				currentHoldAction = [[DeleteAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 2:
			//Move Folder - Folder Menu
			{
				currentHoldAction = [[MoveAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 3:
			//Copy Folder - Folder Menu
			{
				currentHoldAction = [[CopyAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 4:
			//Import File - Folder Menu
			{
				currentHoldAction = [[ImportFileAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 5:
			//Import Folder - Folder Menu
			{
				currentHoldAction = [[ImportFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 6:
			//Create File - Folder Menu
			{
				currentHoldAction = [[CreateFileAction alloc] initWithProjectTreeViewController:self];
			}
			break;
			
			case 7:
			//Create Folder - Folder Menu
			{
				currentHoldAction = [[CreateFolderAction alloc] initWithProjectTreeViewController:self];
			}
			break;
		}
	}
	else if(actionSheet==frameworkMenu)
	{
		//Framework Menu
		switch(buttonIndex)
		{
			case 0:
			//Remove Framework - Framework Menu
			{
				[self removeFrameworkAction];
			}
			break;
		}
	}
}

- (void)dealloc
{
	[treeView release];
	[srcCell release];
	[resCell release];
	[extCell release];
	[includeCell release];
	[libCell release];
	[frameworksCell release];
	
	[projectMenu release];
	[srcFolderMenu release];
	[resFolderMenu release];
	[extFolderMenu release];
	[includeMenu release];
	[libMenu release];
	[frameworksMenu release];
	[fileMenu release];
	[folderMenu release];
	[frameworkMenu release];
	
	[obstructView release];
	
	[super dealloc];
}

@end


void ProjectTreeViewController_updateIncludeFolder(void*data)
{
	ProjectTreeViewController* viewCtrl = (ProjectTreeViewController*)data;
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	
	StringList_struct includeDirs = ProjectData_getIncludeDirs(appDelegate.projData);
	[ProjectTreeViewController addDirectoryListToCell:viewCtrl.selectedCell list:&includeDirs];
	
	[viewCtrl.obstructView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
	[viewCtrl performSelectorOnMainThread:@selector(hideOperationHUDZoom) withObject:nil waitUntilDone:NO];
}

void ProjectTreeViewController_updateLibFolder(void*data)
{
	ProjectTreeViewController* viewCtrl = (ProjectTreeViewController*)data;
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	
	StringList_struct libDirs = ProjectData_getLibDirs(appDelegate.projData);
	[ProjectTreeViewController addDirectoryListToCell:viewCtrl.selectedCell list:&libDirs];
	
	[viewCtrl.obstructView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
	[viewCtrl performSelectorOnMainThread:@selector(hideOperationHUDZoom) withObject:nil waitUntilDone:NO];
}

void ProjectTreeViewController_updateDynamicFolder(void*data)
{
	ProjectTreeViewController* viewCtrl = (ProjectTreeViewController*)data;
	
	[ProjectTreeViewController expandDynamicFolderCell:viewCtrl.selectedCell];
	
	[viewCtrl.obstructView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
	[viewCtrl performSelectorOnMainThread:@selector(hideOperationHUDZoom) withObject:nil waitUntilDone:NO];
}

void ProjectTreeViewController_updateFrameworkFolder(void*data)
{
	ProjectTreeViewController* viewCtrl = (ProjectTreeViewController*)data;
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectSettings_struct projSettings = ProjectData_getProjectSettings(appDelegate.projData);
	NSString* sdkFolder = [[NSString alloc] initWithUTF8String:ProjectSettings_getSDK(&projSettings)];
	if([sdkFolder length]==0 || ([sdkFolder length]==1 && [sdkFolder UTF8String][0]=='/'))
	{
		showSimpleMessageBox("Error", "You must select a valid sdk for this project");
	}
	else if(!Global_checkSDKFolderValid([sdkFolder UTF8String]))
	{
		ProjectSettings_setSDK(&projSettings, "");
		showSimpleMessageBox("Error", "You must select a valid sdk for this project");
		ProjectData_saveProjectPlist(appDelegate.projData);
	}
	else
	{
		NSMutableString* fullPath = [[NSMutableString alloc] initWithUTF8String:Global_getSDKFolderPath()];
		[fullPath appendString:@"/"];
		[fullPath appendString:sdkFolder];
		[fullPath appendString:@"/System/Library/Frameworks/"];
		[fullPath appendString:viewCtrl.selectedCell.identifier];
		if(!FileTools_folderExists([fullPath UTF8String]))
		{
			showSimpleMessageBox("Error", "Framework does not exist");
		}
		else
		{
			StringList_struct*folders = FileTools_getFoldersInDirectory([fullPath UTF8String]);
			for(int i=0; i<StringList_size(folders); i++)
			{
				NSMutableString* folderPath = [[NSMutableString alloc] initWithString:fullPath];
				[folderPath appendString:@"/"];
				NSString* folderName = [[NSString alloc] initWithUTF8String:StringList_get(folders, i)];
				[folderPath appendString:folderName];
				[folderName release];
				ProjectTreeViewCell* pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_DYNAMICFOLDER identifier:folderPath];
				[folderPath release];
				[viewCtrl.selectedCell addMember:pcell];
				[pcell release];
			}
			StringList_destroyInstance(folders);
			folders = NULL;
			
			StringList_struct*files = FileTools_getFilesInDirectory([fullPath UTF8String]);
			for(int i=0; i<StringList_size(folders); i++)
			{
				NSMutableString* filePath = [[NSMutableString alloc] initWithString:fullPath];
				[filePath appendString:@"/"];
				NSString* fileName = [[NSString alloc] initWithUTF8String:StringList_get(files, i)];
				[filePath appendString:fileName];
				[fileName release];
				ProjectTreeViewCell* pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:filePath];
				[filePath release];
				[viewCtrl.selectedCell addMember:pcell];
				[pcell release];
			}
			StringList_destroyInstance(files);
			files = NULL;
		}
		
		[fullPath release];
	}
	
	[sdkFolder release];
	
	[viewCtrl.obstructView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
	[viewCtrl performSelectorOnMainThread:@selector(hideOperationHUDZoom) withObject:nil waitUntilDone:NO];
}

