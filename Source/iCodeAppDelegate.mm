
#import "iCodeAppDelegate.h"
#import "ObjCBridge/ObjCBridge.h"
#import "IconManager/IconManager.h"
#import "PreferencesView/GlobalPreferences.h"

@implementation iCodeAppDelegate
{
	UIWindow* window;
	UINavigator*rootNavigator;
	UINavigator*createProjectNavigator;
	UINavigator*preferencesNavigator;
	
	HomescreenViewController* homescreenController;
	
	//ProjectLoad
	CreateProjectViewController* createProjectController;
	SelectTemplateCategoryViewController* selectTemplateCategoryController;
	LoadProjectViewController* loadProjectController;
	
	//ProjectView
	ProjectTreeViewController* projectTreeController;
	CodeEditorViewController* codeEditorController;
	ImageViewerViewController* imageViewerController;
	PlistViewerViewController* plistViewerController;
	
	//CompilerView
	CompilerViewController* compilerController;
	
	//PreferencesView
	PreferencesViewController* preferencesController;
	
	//attributes
	ProjectData_struct*projData;
}

@synthesize window, rootNavigator, createProjectNavigator, preferencesNavigator, homescreenController, createProjectController, selectTemplateCategoryController, loadProjectController, projectTreeController, codeEditorController, imageViewerController, plistViewerController, compilerController, preferencesController, projData;

- (void)loadScreens
{
	createProjectController = [CreateProjectViewController new];
	
	createProjectNavigator = [UINavigator.alloc initWithRootViewController:self.createProjectController];
	[createProjectNavigator.view setBackgroundColor:UIColor.groupTableViewBackgroundColor];
	[createProjectNavigator.navigationBar setBarStyle:UIBarStyleBlack];
	[createProjectNavigator setModalPresentationStyle:UIModalPresentationFormSheet];
	
  loadProjectController            = [LoadProjectViewController            new];
  selectTemplateCategoryController = [SelectTemplateCategoryViewController new];
  projectTreeController            = [ProjectTreeViewController            new];
  codeEditorController             = [CodeEditorViewController             new];
  imageViewerController            = [ImageViewerViewController            new];
  plistViewerController            = [PlistViewerViewController            new];
  preferencesController            = [PreferencesViewController            new];

  compilerController               = nil;
	(preferencesNavigator = [UINavigator.alloc initWithRootViewController:preferencesController])
                                      .navigationBar.barStyle = UIBarStyleBlack;
}

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create Window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//[window setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	// Initialize Variables
	self.projData = NULL;
	
	[IconManager reloadFromFile];
	GlobalPreferences_load();
	
	// Create root UIViewController
	homescreenController = [HomescreenViewController new];
	rootNavigator = [[UINavigator alloc] initWithRootViewController:homescreenController];
	//[rootNavigator.view setContentMode:UIViewContentModeScaleAspectFit];
	//[rootNavigator.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
	[window setRootViewController:rootNavigator];
	
	// Create main UIView
	UIView*mainView = self.window.rootViewController.view;
	[mainView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	[self.rootNavigator.navigationBar setBarStyle:UIBarStyleBlack];
	
	[self loadScreens];
	
	[self.window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
	 */
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of	transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
	 */
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 See also applicationDidEnterBackground:.
	 */
}


#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	/*
	 Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
	 */
}

- (void)dealloc
{
	[homescreenController release];
	
	[selectTemplateCategoryController release];
	[createProjectController release];
	[loadProjectController release];
	
	[projectTreeController release];
	[codeEditorController release];
	[imageViewerController release];
	[plistViewerController release];
	
	[preferencesController release];
	
	[rootNavigator release];
	[createProjectNavigator release];
	[preferencesNavigator release];
	
	//attributes
	if(projData!=NULL)
	{
		ProjectData_destroyInstance(projData);
		projData = NULL;
	}
	
	[window release];
	[super dealloc];
}


@end


#import "ObjCBridge/ObjCBridge.h"
#import <unistd.h>

int main(int argc, char *argv[])
{
	//setuid(0);
  int retVal = EXIT_FAILURE;
  @autoreleasepool {
    init_ObjCBridge(argc, argv);
    retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([iCodeAppDelegate class]));
  }
	return retVal;
}
