
#import "RenameAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../DDAlertPrompt/DDAlertPrompt.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../IconManager/IconManager.h"

@implementation RenameAction

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	if([super initWithProjectTreeViewController:projectTreeViewController]==nil)
	{
		return nil;
	}
	
	if(viewCtrl.selectedCell.type==PROJECTTREECELL_FILE)
	{
		[self createTextFieldAlertViewWithTitle:@"Rename File" text:viewCtrl.selectedCell.text placeholder:@"File Name"];
	}
	else if(viewCtrl.selectedCell.type==PROJECTTREECELL_FOLDER)
	{
		[self createTextFieldAlertViewWithTitle:@"Rename File" text:viewCtrl.selectedCell.text placeholder:@"Folder Name"];
	}
	else
	{
		[self release];
		return nil;
	}
	
	return self;
}

- (void)createTextFieldAlertViewWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder
{
	DDAlertPrompt* renameAlert = [[DDAlertPrompt alloc] initWithTitle:title
															//message:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
													 otherButtonTitle:@"OK"];
	UITextField* textField = renameAlert.plainTextField;
	[textField setPlaceholder:placeholder];
	if(text!=nil)
	{
		[textField setText:text];
	}
	[textField setBackgroundColor:[UIColor whiteColor]];
	//[textField becomeFirstResponder];
	[renameAlert show];
	[renameAlert release];
}

- (void)didPresentAlertView:(UIAlertView*)alertView
{
	if([alertView isKindOfClass:[DDAlertPrompt class]])
	{
		DDAlertPrompt* textFieldAlert = (DDAlertPrompt*)alertView;
		[textFieldAlert.plainTextField becomeFirstResponder];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if([alertView isKindOfClass:[DDAlertPrompt class]])
	{
		DDAlertPrompt* textFieldAlert = (DDAlertPrompt*)alertView;
		UITextField*textField = textFieldAlert.plainTextField;
		if(buttonIndex==1)
		//OK
		{
			if([textField.text length]==0)
			{
				showSimpleMessageBox("Error", "Invalid name");
				return;
			}
			iCodeAppDelegate*appDelegate = [[UIApplication sharedApplication] delegate];
			NSMutableString* fullPathString = nil;
			NSString* categoryName = [viewCtrl.selectedCell getCategory];
			if([categoryName isEqual:@"src"])
			{
				fullPathString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
				[fullPathString appendString:@"/"];
				NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
				[fullPathString appendString:saveFolder];
				[saveFolder release];
				[fullPathString appendString:@"/src/"];
			}
			else if([categoryName isEqual:@"res"])
			{
				fullPathString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
				[fullPathString appendString:@"/"];
				NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
				[fullPathString appendString:saveFolder];
				[saveFolder release];
				[fullPathString appendString:@"/res/"];
			}
			else
			{
				showSimpleMessageBox("Error", "Unknown cell category");
				return;
			}
			NSFilePath* relPath = [[NSFilePath alloc] initWithString:[viewCtrl.selectedCell getPath]];
			[fullPathString appendString:[relPath pathAsString]];
			NSFilePath* oldPath = [[NSFilePath alloc] initWithString:fullPathString];
			[fullPathString release];
			NSMutableFilePath* newPath = [[NSMutableFilePath alloc] initWithFilePath:[oldPath pathAtIndex:([oldPath count]-2)]];
			[newPath addMember:textField.text];
			
			if(FileTools_fileExists([[newPath pathAsString] UTF8String]))
			{
				[oldPath release];
				[newPath release];
				[relPath release];
				showSimpleMessageBox("Error", "File with duplicate name already exists");
				return;
			}
			else if(FileTools_folderExists([[newPath pathAsString] UTF8String]))
			{
				[oldPath release];
				[newPath release];
				[relPath release];
				showSimpleMessageBox("Error", "Folder with duplicate name already exists");
				return;
			}
			
			bool success = FileTools_rename([[oldPath pathAsString] UTF8String], [[newPath pathAsString] UTF8String]);
			[oldPath release];
			[newPath release];
			
			if(success)
			{
				//ProjectBuildInfo tasks
				if([categoryName isEqual:@"src"])
				{
					NSMutableString* buildFolderPathString = [[NSMutableString alloc] initWithUTF8String:ProjLoad_getSavedProjectsFolder()];
					[buildFolderPathString appendString:@"/"];
					NSString* saveFolder = [[NSString alloc] initWithUTF8String:ProjectData_getFolderName(appDelegate.projData)];
					[buildFolderPathString appendString:saveFolder];
					[saveFolder release];
					[buildFolderPathString appendString:@"/bin/build"];
					
					NSFilePath* buildFolderPath = [[NSFilePath alloc] initWithString:buildFolderPathString];
					
					
					NSMutableFilePath* oldFilePath = [[NSMutableFilePath alloc] initWithFilePath:buildFolderPath];
					[oldFilePath appendPath:relPath];
					NSMutableFilePath* newFilePath = [[NSMutableFilePath alloc] initWithFilePath:[oldFilePath pathAtIndex:([oldFilePath count]-2)]];
					[newFilePath addMember:textField.text];
					
					if(viewCtrl.selectedCell.type==PROJECTTREECELL_FILE)
					{
						//delete .o, .d, and .output files for the file from the build folder
						//remove old "edited" path for file from ProjectBuildInfo
						//add new "edited" path for file to ProjectBuildInfo
						
						NSString* oldName = [[oldFilePath lastMember] retain];
						
						ProjectBuildInfo_struct projBuildInfo = ProjectData_getProjectBuildInfo(appDelegate.projData);
						
						NSFilePath* oldRelPath = [oldFilePath pathRelativeTo:buildFolderPath];
						NSFilePath* newRelPath = [newFilePath pathRelativeTo:buildFolderPath];
						NSMutableString* oldRelPathString = [[NSMutableString alloc] initWithString:[oldRelPath pathAsString]];
						if([oldRelPathString UTF8String][0]=='/')
						{
							[oldRelPathString deleteCharactersInRange:NSMakeRange(0, 1)];
						}
						NSMutableString* newRelPathString = [[NSMutableString alloc] initWithString:[newRelPath pathAsString]];
						if([newRelPathString UTF8String][0]=='/')
						{
							[newRelPathString deleteCharactersInRange:NSMakeRange(0, 1)];
						}
						
						ProjectBuildInfo_removeEditedFile(&projBuildInfo, [oldRelPathString UTF8String]);
						ProjectBuildInfo_addEditedFile(&projBuildInfo, [newRelPathString UTF8String]);
						[oldRelPathString release];
						[newRelPathString release];
						
						ProjectBuildInfo_saveBuildInfoPlist(&projBuildInfo, appDelegate.projData);
						
						
						[oldFilePath removeLastMember];
						NSMutableString* oldNameFile = [[NSMutableString alloc] initWithString:oldName];
						[oldNameFile appendString:@".o"];
						[oldFilePath addMember:oldNameFile];
						[oldNameFile release];
						
						FileTools_deleteFromFilesystem([[oldFilePath pathAsString] UTF8String]);
						
						[oldFilePath removeLastMember];
						oldNameFile = [[NSMutableString alloc] initWithString:oldName];
						[oldNameFile appendString:@".d"];
						[oldFilePath addMember:oldNameFile];
						[oldNameFile release];
						
						FileTools_deleteFromFilesystem([[oldFilePath pathAsString] UTF8String]);
						
						[oldFilePath removeLastMember];
						oldNameFile = [[NSMutableString alloc] initWithString:oldName];
						[oldNameFile appendString:@".output"];
						[oldFilePath addMember:oldNameFile];
						[oldNameFile release];
						
						FileTools_deleteFromFilesystem([[oldFilePath pathAsString] UTF8String]);
						
						[oldName release];
					}
					else if(viewCtrl.selectedCell.type==PROJECTTREECELL_FOLDER)
					{
						//remove all edited files within the old folder from ProjectBuildInfo
						//delete all .o, .d, and .output files from the build folder within that folder
						//add all "edited" files within the new folder to ProjectBuildInfo
						
						NSString* slashString = @"/";
						
						const char* oldFolder = [[oldFilePath pathAsString] UTF8String];
						const char* newFolder = [[newFilePath pathAsString] UTF8String];
						FileTools_rename(oldFolder, newFolder);
						
						NSString* relPathString = [relPath pathAsString];
						
						StringTree_struct sourceFiles = ProjectData_getSourceFiles(appDelegate.projData);
						StringTree_struct folderTree = StringTree_getBranch(&sourceFiles, [relPathString UTF8String]);
						
						StringList_struct* paths = StringTree_getPaths(&folderTree);
						
						NSMutableFilePath* newRelPath = [[NSMutableFilePath alloc] initWithFilePath:relPath];
						[newRelPath removeLastMember];
						[newRelPath addMember:textField.text];
						
						NSMutableString* oldRelPathString = [[NSMutableString alloc] initWithString:relPathString];
						if([oldRelPathString UTF8String][0]=='/')
						{
							[oldRelPathString deleteCharactersInRange:NSMakeRange(0, 1)];
						}
						
						NSMutableString* newRelPathString = [[NSMutableString alloc] initWithString:[newRelPath pathAsString]];
						if([newRelPathString UTF8String][0]=='/')
						{
							[newRelPathString deleteCharactersInRange:NSMakeRange(0, 1)];
						}
						
						
						ProjectBuildInfo_struct projBuildInfo = ProjectData_getProjectBuildInfo(appDelegate.projData);
						
						NSString* oExt = @".o";
						NSString* dExt = @".d";
						NSString* outputExt = @".output";
						
						for(int i=0; i<StringList_size(paths); i++)
						{
							NSMutableString* pathOld = [[NSMutableString alloc] initWithString:oldRelPathString];
							[pathOld appendString:slashString];
							NSString* pstr = [[NSString alloc] initWithUTF8String:StringList_get(paths, i)];
							[pathOld appendString:pstr];
							
							ProjectBuildInfo_removeEditedFile(&projBuildInfo, [pathOld UTF8String]);
							[pathOld release];
							
							NSMutableString* pathNew = [[NSMutableString alloc] initWithString:newRelPathString];
							[pathNew appendString:slashString];
							[pathNew appendString:pstr];
							[pstr release];
							
							ProjectBuildInfo_addEditedFile(&projBuildInfo, [pathNew UTF8String]);
							
							NSMutableString* pathNewFull = [[NSMutableString alloc] initWithString:buildFolderPathString];
							[pathNewFull appendString:slashString];
							[pathNewFull appendString:pathNew];
							[pathNewFull appendString:oExt];
							FileTools_deleteFromFilesystem([pathNewFull UTF8String]);
							[pathNewFull release];
							
							pathNewFull = [[NSMutableString alloc] initWithString:buildFolderPathString];
							[pathNewFull appendString:slashString];
							[pathNewFull appendString:pathNew];
							[pathNewFull appendString:dExt];
							FileTools_deleteFromFilesystem([pathNewFull UTF8String]);
							[pathNewFull release];
							
							pathNewFull = [[NSMutableString alloc] initWithString:buildFolderPathString];
							[pathNewFull appendString:slashString];
							[pathNewFull appendString:pathNew];
							[pathNewFull appendString:outputExt];
							FileTools_deleteFromFilesystem([pathNewFull UTF8String]);
							[pathNewFull release];
							
							[pathNew release];
						}
						
						ProjectBuildInfo_saveBuildInfoPlist(&projBuildInfo, appDelegate.projData);
						
						
						StringList_destroyInstance(paths);
						[buildFolderPath release];
						[newRelPath release];
						[oldRelPathString release];
						[newRelPathString release];
					}
					
					[buildFolderPath release];
					[buildFolderPathString release];
					[oldFilePath release];
					[newFilePath release];
				}
				//end ProjectBuildInfo tasks
				
				int oldIndex = [viewCtrl.selectedCell.supercell indexOfMember:viewCtrl.selectedCell];
				NSMutableFilePath* branchFolder = [[NSMutableFilePath alloc] initWithFilePath:relPath];
				NSString* oldName = [[NSString alloc] initWithString:[branchFolder lastMember]];
				[branchFolder removeLastMember];
				
				StringTree_struct sourceTree;
				if([categoryName isEqual:@"src"])
				{
					sourceTree = ProjectData_getSourceFiles(appDelegate.projData);
				}
				else if([categoryName isEqual:@"res"])
				{
					sourceTree = ProjectData_getResourceFiles(appDelegate.projData);
				}
				else
				{
					showSimpleMessageBox("Error", "Unknown category name");
					[relPath release];
					[oldName release];
					[branchFolder release];
					return;
				}
				
				const char* branchPath = [[branchFolder pathAsString] UTF8String];
				StringTree_struct folderTree = StringTree_getBranch(&sourceTree, branchPath);
				
				if(viewCtrl.selectedCell.type == PROJECTTREECELL_FILE)
				{
					const char* newName = [textField.text UTF8String];
					const char* oldNameString = [oldName UTF8String];
					StringTree_renameMember(&folderTree, oldNameString, newName);
					[viewCtrl.selectedCell setIdentifier:textField.text];
					[viewCtrl.selectedCell setText:textField.text];
					NSString* extension = [IconManager getExtensionForFilename:textField.text];
					[viewCtrl.selectedCell setExtension:extension];
					[ProjectTreeViewCell applyFileThumbnailToCell:viewCtrl.selectedCell extension:extension];
					if(viewCtrl.selectedCell.supercell!=nil)
					{
						StringList_struct branchNames = StringTree_getBranchNames(&folderTree);
						int index = StringList_size(&branchNames) + StringTree_hasMember(&folderTree, newName);
						[viewCtrl.selectedCell.supercell moveMemberAtIndex:oldIndex toIndex:index];
					}
				}
				else if(viewCtrl.selectedCell.type == PROJECTTREECELL_FOLDER)
				{
					const char* newName = [textField.text UTF8String];
					StringTree_renameBranch(&folderTree, [oldName UTF8String], newName);
					[viewCtrl.selectedCell setIdentifier:textField.text];
					[viewCtrl.selectedCell setText:textField.text];
					if(viewCtrl.selectedCell.supercell!=nil)
					{
						[viewCtrl.selectedCell.supercell moveMemberAtIndex:oldIndex toIndex:StringTree_hasBranch(&folderTree, newName)];
					}
				}
				else
				{
					[oldPath release];
					[newPath release];
					[relPath release];
					showSimpleMessageBox("Error", "Unknown type for cell");
					return;
				}
				
				[oldName release];
				[branchFolder release];
				
				ProjectData_saveProjectPlist(appDelegate.projData);
			}
			else
			{
				if(viewCtrl.selectedCell.type == PROJECTTREECELL_FILE)
				{
					showSimpleMessageBox("Error", "Unable to rename file");
				}
				else if(viewCtrl.selectedCell.type == PROJECTTREECELL_FOLDER)
				{
					showSimpleMessageBox("Error", "Unable to rename folder");
				}
				else
				{
					showSimpleMessageBox("Error", "Unable to rename cell");
				}
			}
			
			[relPath release];
			return;
		}
	}
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self release];
}

@end
