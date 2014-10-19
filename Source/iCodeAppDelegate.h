
#import <UIKit/UIKit.h>
#import "ObjCBridge/ObjCBridge.h"
#import "Navigation/UINavigator.h"

#import "Homescreen/HomescreenViewController.h"

#import "ProjectLoad/LoadProjectViewController.h"
#import "ProjectLoad/CreateProjectViewController.h"
#import "ProjectLoad/SelectTemplateCategoryViewController.h"

#import "ProjectView/ProjectTreeViewController.h"
#import "ProjectView/CodeEditorViewController.h"
#import "ProjectView/ImageViewerViewController.h"
#import "ProjectView/PlistViewerViewController.h"

#import "CompilerView/CompilerViewController.h"

#import "PreferencesView/PreferencesViewController.h"

@interface iCodeAppDelegate : NSObject <UIApplicationDelegate>

- (void) loadScreens;

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) UINavigator* rootNavigator,
                                         * createProjectNavigator,
                                         * preferencesNavigator;

@property (nonatomic, retain) HomescreenViewController* homescreenController;

//ProjectLoad
@property (nonatomic, retain) CreateProjectViewController* createProjectController;
@property (nonatomic, retain) SelectTemplateCategoryViewController* selectTemplateCategoryController;
@property (nonatomic, retain) LoadProjectViewController* loadProjectController;

//ProjectView
@property (nonatomic, retain) ProjectTreeViewController* projectTreeController;
@property (nonatomic, retain) CodeEditorViewController* codeEditorController;
@property (nonatomic, retain) ImageViewerViewController* imageViewerController;
@property (nonatomic, retain) PlistViewerViewController* plistViewerController;

//CompilerView
@property (nonatomic, retain) CompilerViewController* compilerController;

//PreferencesView
@property (nonatomic, retain) PreferencesViewController* preferencesController;

//attributes
@property (nonatomic) ProjectData_struct* projData;

@end

