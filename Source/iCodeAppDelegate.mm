
#import "iCodeAppDelegate.h"
#import "ObjCBridge/ObjCBridge.h"
#import "IconManager/IconManager.h"
#import "PreferencesView/GlobalPreferences.h"

@implementation iCodeAppDelegate

@synthesize window;
@synthesize rootNavigator;
@synthesize createProjectNavigator;
@synthesize preferencesNavigator;

@synthesize homescreenController;

@synthesize createProjectController;
@synthesize selectTemplateCategoryController;
@synthesize loadProjectController;

@synthesize projectTreeController;
@synthesize codeEditorController;
@synthesize imageViewerController;
@synthesize plistViewerController;

@synthesize compilerController;

@synthesize preferencesController;

@synthesize projData;

- (void)loadScreens
{
	createProjectController = [[CreateProjectViewController alloc] init];
	
	createProjectNavigator = [[UINavigator alloc] initWithRootViewController:self.createProjectController];
	[createProjectNavigator.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[createProjectNavigator.navigationBar setBarStyle:UIBarStyleBlack];
	
	loadProjectController = [[LoadProjectViewController alloc] init];
	selectTemplateCategoryController = [[SelectTemplateCategoryViewController alloc] init];
	
	projectTreeController = [[ProjectTreeViewController alloc] init];
	codeEditorController = [[CodeEditorViewController alloc] init];
	imageViewerController = [[ImageViewerViewController alloc] init];
	plistViewerController = [[PlistViewerViewController alloc] init];
	
	compilerController = nil;
	
	preferencesController = [[PreferencesViewController alloc] init];
	preferencesNavigator = [[UINavigator alloc] initWithRootViewController:preferencesController];
	[preferencesNavigator.navigationBar setBarStyle:UIBarStyleBlack];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create Window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//[window setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	
	// Initialize Variables
	self.projData = NULL;
	
	// Window bounds.
	CGRect bounds = window.bounds;
	
	[IconManager reloadFromFile];
	GlobalPreferences_load();
	
	// Create root UIViewController
	homescreenController = [[HomescreenViewController alloc] init];
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


#pragma mark -
#pragma mark Memory management

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
