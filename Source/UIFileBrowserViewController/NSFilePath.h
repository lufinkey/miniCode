
#import <Foundation/Foundation.h>

@class NSFilePath;
@class NSMutableFilePath;

@interface NSFilePath : NSObject
{
	@private
	NSMutableArray* path;
}

+ (NSFilePath*)pathWithString:(NSString*)path;
+ (NSFilePath*)pathWithMembers:(NSString*)member, ...;
+ (NSFilePath*)pathWithFilePath:(NSFilePath*)path;
+ (NSFilePath*)pathWithFilePaths:(NSFilePath*)path, ...;

- (id)initWithString:(NSString*)path;
- (id)initWithMembers:(NSString*)member, ...;
- (id)initWithFilePath:(NSFilePath*)path;
- (id)initWithFilePaths:(NSFilePath*)path, ...;

- (NSUInteger)count;
- (NSString*)memberAtIndex:(NSUInteger)index;
- (NSString*)firstMember;
- (NSString*)lastMember;

- (NSFilePath*)pathAtIndex:(NSUInteger)index;
- (NSFilePath*)pathRelativeTo:(NSFilePath*)path;

- (NSString*)pathAsString;

- (BOOL)isEqual:(NSFilePath*)object;
- (BOOL)containsSubfoldersOf:(NSFilePath*)object;

@end

@interface NSMutableFilePath : NSFilePath

+ (NSMutableFilePath*)pathWithString:(NSString*)path;
+ (NSMutableFilePath*)pathWithMembers:(NSString*)member, ...;
+ (NSMutableFilePath*)pathWithFilePath:(NSFilePath*)path;
+ (NSMutableFilePath*)pathWithFilePaths:(NSFilePath*)path, ...;

- (id)init;

- (void)addMember:(NSString*)member;
- (void)removeMemberAtIndex:(NSUInteger)index;
- (void)removeLastMember;
- (void)removeAllMembers;

- (void)appendPath:(NSFilePath*)path;

@end