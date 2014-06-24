
#import "BuildOptionsActionSheet.h"
#import "../Util/UIImageManager.h"
#import "../iCodeAppDelegate.h"
#import "CompilerViewController.h"
//#import "../Compiler/CompilerTools.h"

@implementation BuildOptionsActionSheet

- (id)initForViewController:(UIViewController*)viewCtrl
{
	if([super initWithTitle:@"Build Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Build", @"Build and Run", @"Clean", @"Results", nil]==nil)
	{
		return nil;
	}
	
	viewController = viewCtrl;
	
	[self setDelegate:self];
	
	[UIImageManager loadImage:@"Images/build.png"];
	[[[self valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImageManager getImage:@"Images/build.png"] forState:UIControlStateNormal];
	
	[UIImageManager loadImage:@"Images/buildandrun.png"];
	[[[self valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImageManager getImage:@"Images/buildandrun.png"] forState:UIControlStateNormal];
	
	[UIImageManager loadImage:@"Images/clean.png"];
	[[[self valueForKey:@"_buttons"] objectAtIndex:2] setImage:[UIImageManager getImage:@"Images/clean.png"] forState:UIControlStateNormal];
	
	[UIImageManager loadImage:@"Images/results.png"];
	[[[self valueForKey:@"_buttons"] objectAtIndex:3] setImage:[UIImageManager getImage:@"Images/results.png"] forState:UIControlStateNormal];
	
	return self;
}

- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
	if(appDelegate.compilerController!=nil && [appDelegate.compilerController isRunning])
	{
		return;
	}
	
	if(buttonIndex==0 || buttonIndex==1 || buttonIndex==3)
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
		
		if(buttonIndex==0) //Build
		{
			[viewCtrl build];
		}
		else if(buttonIndex==1) //Build and Run
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
	else if(buttonIndex==2)
	{
		iCodeAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
		CompilerTools_cleanOutput(appDelegate.projData);
	}
}

@end
