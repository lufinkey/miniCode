
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IconManager : NSObject

+ (void)reloadFromFile;

+ (void)setImage:(UIImage*)image forExtension:(NSString*)extension;
+ (UIImage*)imageForExtension:(NSString*)extension;

+ (void)setFolderImage:(UIImage*)image;
+ (UIImage*)imageForFolder;

+ (BOOL)extensionIsPackage:(NSString*)extension;

+ (NSString*)getExtensionForFilename:(NSString*)fileName;

+ (UIImage*)iconForApplication:(NSString*)path;

@end
