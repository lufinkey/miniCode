
#import "CreateFolderAction.h"
#import "../../iCodeAppDelegate.h"
#import "../../DDAlertPrompt/DDAlertPrompt.h"
#import "../../ProjectLoad/ProjLoadTools.h"


@implementation CreateFolderAction

- (id)initWithProjectTreeViewController:(ProjectTreeViewController*)projectTreeViewController
{
	self = [super initWithProjectTreeViewController:projectTreeViewController];
	if(self==nil)
	{
		return nil;
	}
	
	[self createTextFieldAlertViewWithTitle:@"Create Folder" text:nil placeholder:@"Folder name"];
	
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
			
			if(FileTools_folderExists([fullPathString UTF8String]))
			{
				showSimpleMessageBox("Error", "Duplicate folder already exists");
			}
			else
			{
				FileTools_createDirectory([fullPathString UTF8String]);
				
				StringTree_struct sourceTree;
				sourceTree.data = NULL;
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
					showSimpleMessageBox("Error", "Unknown category name for cell");
					[fullPathString release];
					return;
				}
				StringTree_struct folderTree;
				folderTree.data = NULL;
				folderTree = StringTree_getBranch(&sourceTree, [relPath UTF8String]);
				StringTree_addBranch(&folderTree, [textField.text UTF8String]);
				
				ProjectData_saveProjectPlist(appDelegate.projData);
				
				ProjectTreeViewCell*pcell = [[ProjectTreeViewCell alloc] initWithType:PROJECTTREECELL_FOLDER identifier:textField.text];
				[self.viewCtrl.selectedCell insertMember:pcell atIndex:StringTree_hasBranch(&folderTree, [textField.text UTF8String])];
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
