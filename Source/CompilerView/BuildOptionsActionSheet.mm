
#import "BuildOptionsActionSheet.h"
#import "../Util/UIImageManager.h"
#import "../iCodeAppDelegate.h"
#import "CompilerViewController.h"
#import "../Util/VersionCheck.h"
//#import "../Compiler/CompilerTools.h"

@implementation BuildOptionsActionSheet

- (id)initForViewController:(UIViewController*)viewCtrl
{
	self = [super initWithTitle:@"Build Options" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	if(self==nil)
	{
		return nil;
	}
	
	viewController = viewCtrl;
	
	[self setDelegate:self];
	
	int cancelIndex = 4;
	
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	ProjectType projType = ProjectData_getProjectType(appDelegate.projData);
	if(projType==PROJECTTYPE_APPLICATION || projType==PROJECTTYPE_CONSOLE)
	{
		buildIndex = 0;
		buildAndRunIndex = 1;
		cleanIndex = 2;
		resultsIndex = 3;
		cancelIndex= 4;
	}
	else if(projType==PROJECTTYPE_DYNAMICLIBRARY || projType==PROJECTTYPE_STATICLIBRARY)
	{
		buildIndex = 0;
		cleanIndex = 1;
		resultsIndex = 2;
		cancelIndex = 3;
		buildAndRunIndex = 4;
	}
	
	BOOL buttonIcons = YES;
	if(!SYSTEM_VERSION_GREATER_THAN(@"7.2.1"))
	{
		buttonIcons = NO;
	}
	
	[self addButtonWithTitle:@"Build"];
	if(buttonIcons)
	{
		[UIImageManager loadImage:@"Images/build.png"];
		[[[self valueForKey:@"_buttons"] objectAtIndex:buildIndex] setImage:[UIImageManager getImage:@"Images/build.png"] forState:UIControlStateNormal];
	}
	
	if(projType==PROJECTTYPE_APPLICATION || projType==PROJECTTYPE_CONSOLE)
	{
		[self addButtonWithTitle:@"Build and Run"];
		if(buttonIcons)
		{
			[UIImageManager loadImage:@"Images/buildandrun.png"];
			[[[self valueForKey:@"_buttons"] objectAtIndex:buildAndRunIndex] setImage:[UIImageManager getImage:@"Images/buildandrun.png"] forState:UIControlStateNormal];
		}
	}
	
	[self addButtonWithTitle:@"Clean"];
	if(buttonIcons)
	{
		[UIImageManager loadImage:@"Images/clean.png"];
		[[[self valueForKey:@"_buttons"] objectAtIndex:cleanIndex] setImage:[UIImageManager getImage:@"Images/clean.png"] forState:UIControlStateNormal];
	}
	
	[self addButtonWithTitle:@"Results"];
	if(buttonIcons)
	{
		[UIImageManager loadImage:@"Images/results.png"];
		[[[self valueForKey:@"_buttons"] objectAtIndex:resultsIndex] setImage:[UIImageManager getImage:@"Images/results.png"] forState:UIControlStateNormal];
	}
	
	[self addButtonWithTitle:@"Cancel"];
	self.cancelButtonIndex = cancelIndex;
	
	return self;
}

- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	if(appDelegate.compilerController!=nil && [appDelegate.compilerController isRunning])
	{
		return;
	}
	
	if(buttonIndex==buildIndex || buttonIndex==buildAndRunIndex || buttonIndex==resultsIndex)
	{
		CompilerViewController*viewCtrl = nil;
		BOOL needsRelease = NO;
		if(appDelegate.compilerController!=nil)
		{
			if(appDelegate.compilerController.navigationController==nil)
			{
				if(appDelegate.compilerController==viewController)
				{
					viewCtrl = (CompilerViewController*)viewController;
				}
				else
				{
					viewCtrl = appDelegate.compilerController;
					UINavigator* navigator = [[UINavigator alloc] initWithRootViewController:viewCtrl];
					[viewController presentModalViewController:navigator animated:YES];
					[navigator release];
				}
			}
			else if(appDelegate.compilerController.navigationController==viewController.navigationController)
			{
				viewCtrl = appDelegate.compilerController;
				[viewCtrl.navigationController popToViewController:appDelegate.compilerController animated:YES];
			}
			else
			{
				viewCtrl = appDelegate.compilerController;
				UINavigator* navigator = [[UINavigator alloc] initWithRootViewController:viewCtrl];
				[viewController presentModalViewController:navigator animated:YES];
				[navigator release];
			}
		}
		else
		{
			needsRelease = YES;
			viewCtrl = [[CompilerViewController alloc] initWithProjectData:appDelegate.projData];
			appDelegate.compilerController = viewCtrl;
			UINavigator* navigator = [[UINavigator alloc] initWithRootViewController:viewCtrl];
			[viewController presentModalViewController:navigator animated:YES];
			[navigator release];
		}
		
		if(buttonIndex==buildIndex) //Build
		{
			[viewCtrl build];
		}
		else if(buttonIndex==buildAndRunIndex) //Build and Run
		{
#if (TARGET_IPHONE_SIMULATOR)
			[viewCtrl build];
#else
			[viewCtrl buildAndRun];
#endif
		}
		
		if(needsRelease)
		{
			[viewCtrl release];
		}
	}
	else if(buttonIndex==cleanIndex)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		CompilerTools_cleanOutput(appDelegate.projData);
	}
}

@end
