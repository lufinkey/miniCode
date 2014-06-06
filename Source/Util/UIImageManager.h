
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageManager : NSObject
{
	//
}

+ (BOOL)isImageLoaded:(NSString*)path;

+ (BOOL)loadImage:(NSString*)path;
+ (BOOL)loadImage:(NSString*)path logError:(BOOL)log;

+ (UIImage*)loadUnstoredImage:(NSString*)path;
+ (UIImage*)loadUnstoredImage:(NSString*)path logError:(BOOL)log;

+ (UIImage*)getImage:(NSString*)path;

+ (BOOL)unloadImage:(NSString*)path;

@end
