
#import "CreateFileAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../DDAlertPrompt/DDAlertPrompt.h"
#import "../../ProjectLoad/ProjLoadTools.h"
#import "../../IconManager/IconManager.h"

@implementation CreateFileAction

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	self = [super initWithProjectTreeViewController:projectTreeViewController];
	if(self==nil)
	{
		return nil;
	}
	
	[self createTextFieldAlertViewWithTitle:@"Create File" text:nil placeholder:@"File name"];
	
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
			NSString* categoryName = [self.viewCtrl.selectedCell getCategory];
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
				showSimpleMessageBox("Error", "Unknown category for cell");
				return;
			}
			
			NSString*relPath = [self.viewCtrl.selectedCell getPath];
			[fullPathString appendString:relPath];
			[fullPathString appendString:@"/"];
			[fullPathString appendString:textField.text];
			
			
			if(FileTools_fileExists([fullPathString UTF8String]))
			{
				showSimpleMessageBox("Error", "Duplicate file already exists");
			}
			else if(FileTools_folderExists([fullPathString UTF8String]))
			{
				showSimpleMessageBox("Error", "Folder with duplicate name already exists");
			}
			else if(!FileTools_createFile([fullPathString UTF8String]))
			{
				showSimpleMessageBox("Error", "Unable to create file");
			}
			else
			{
				StringTree_struct sourceTree;
				if([categoryName isEqual:@"src"])
				{
					sourceTree = ProjectData_getSourceFiles(appDelegate.projData);
					
					//ProjectBuildInfo tasks
					ProjectBuildInfo_struct projBuildInfo = ProjectData_getProjectBuildInfo(appDelegate.projData);
					ProjectBuildInfo_addEditedFile(&projBuildInfo, [relPath UTF8String]);
					ProjectBuildInfo_saveBuildInfoPlist(&projBuildInfo, appDelegate.projData);
					//end ProjectBuildInfo tasks
				}
				else if([categoryName isEqual:@"res"])
				{
					sourceTree = ProjectData_getResourceFiles(appDelegate.projData);
				}
				else
				{
					showSimpleMessageBox("Error", "Unknown category name for cell");
					[fullPathString release];
					return;
				}
				StringTree_struct folderTree = StringTree_getBranch(&sourceTree, [relPath UTF8String]);
				StringTree_addMember(&folderTree, [textField.text UTF8String]);
				
				ProjectData_saveProjectPlist(appDelegate.projData);
				
				StringList_struct branchNames = StringTree_getBranchNames(&folderTree);
				int index = StringList_size(&branchNames) + StringTree_hasMember(&folderTree, [textField.text UTF8String]);
				
				ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FILE identifier:textField.text];
				[self.viewCtrl.selectedCell insertMember:pcell atIndex:index];
				[pcell release];
			}
		}
	}
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self release];
}

@end
