
#import <Foundation/Foundation.h>

@interface SyntaxDefinitionManager : NSObject

+ (NSDictionary*)loadSyntaxDefinitionsForFile:(NSString*)fileName;

@end
