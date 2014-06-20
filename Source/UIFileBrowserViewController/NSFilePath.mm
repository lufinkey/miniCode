
#import "NSFilePath.h"

@interface NSFilePath()
@property (nonatomic, retain) NSMutableArray* path;
@end

@implementation NSFilePath

@synthesize path;

+ (NSFilePath*)pathWithString:(NSString*)path
{
	return [[[NSFilePath alloc] initWithString:path] autorelease];
}

+ (NSFilePath*)pathWithMembers:(NSString*)member, ...
{
	NSMutableFilePath* filePath = [[[NSMutableFilePath alloc] init] autorelease];
	
	id eachMember;
	va_list argumentList;
	if (member)
	{
		[filePath addMember:member];
		va_start(argumentList, member);
		BOOL keepChecking = YES;
		while(keepChecking)
		{
			eachMember = va_arg(argumentList, id);
			if(eachMember!=nil)
			{
				[filePath addMember:eachMember];
			}
			else
			{
				keepChecking = NO;
			}
		}
		va_end(argumentList);
	}
	
	return filePath;
}

+ (NSFilePath*)pathWithFilePath:(NSFilePath*)path
{
	return [[[NSFilePath alloc] initWithFilePath:path] autorelease];
}

+ (NSFilePath*)pathWithFilePaths:(NSFilePath*)path, ...
{
	NSMutableFilePath* filePath = [[[NSMutableFilePath alloc] init] autorelease];
	
	id eachMember;
	va_list argumentList;
	if (path)
	{
		[filePath appendPath:path];
		va_start(argumentList, path);
		BOOL keepChecking = YES;
		while(keepChecking)
		{
			eachMember = va_arg(argumentList, id);
			if(eachMember!=nil)
			{
				[filePath appendPath:eachMember];
			}
			else
			{
				keepChecking = NO;
			}
		}
		va_end(argumentList);
	}
	
	return filePath;
}

- (id)init
{
	[self release];
	return nil;
}

- (id)initWithString:(NSString*)fullPath
{
	if([super init]==nil)
	{
		return nil;
	}
	
	path = [[NSMutableArray alloc] init];
	
	NSMutableString* currentMember = [[NSMutableString alloc] init];
	for(unsigned int i=0; i<[fullPath length]; i++)
	{
		char c = [fullPath UTF8String][i];
		if(c=='/' || c=='\\')
		{
			if([currentMember length]>0)
			{
				NSString* member = [[NSString alloc] initWithString:currentMember];
				[path addObject:member];
				[member release];
				
				NSString*blank = [[NSString alloc] initWithUTF8String:""];
				[currentMember setString:blank];
				[blank release];
			}
		}
		else if(c==':' || c=='?')
		{
			[currentMember release];
			[self release];
			return nil;
		}
		else
		{
			char str[2] = {c, '\0'};
			NSString*character = [[NSString alloc] initWithUTF8String:str];
			[currentMember appendString:character];
			[character release];
		}
	}
	if([currentMember length]>0)
	{
		NSString* member = [[NSString alloc] initWithString:currentMember];
		[path addObject:member];
		[member release];
	}
	
	[currentMember release];
	return self;
}

- (id)initWithMembers:(NSString*)member, ...
{
	if([super init]==nil)
	{
		return nil;
	}
	
	path = [[NSMutableArray alloc] init];
	
	id eachMember;
	va_list argumentList;
	if (member)
	{
		[path addObject:member];
		va_start(argumentList, member);
		BOOL keepChecking = YES;
		while(keepChecking)
		{
			eachMember = va_arg(argumentList, id);
			if(eachMember!=nil)
			{
				[path addObject:eachMember];
			}
			else
			{
				keepChecking = NO;
			}
		}
		va_end(argumentList);
	}
	
	return self;
}

- (id)initWithFilePath:(NSFilePath*)fullPath
{
	if([super init]==nil)
	{
		return nil;
	}
	
	path = [[NSMutableArray alloc] init];
	
	for(unsigned int i=0; i<[fullPath count]; i++)
	{
		[path addObject:[fullPath memberAtIndex:i]];
	}
	
	return self;
}

- (id)initWithFilePaths:(NSFilePath*)member, ...
{
	if([super init]==nil)
	{
		return nil;
	}
	
	path = [[NSMutableArray alloc] init];
	
	id eachMember;
	va_list argumentList;
	if (member)
	{
		for(unsigned int i=0; i<[member count]; i++)
		{
			[path addObject:[member memberAtIndex:i]];
		}
		va_start(argumentList, member);
		BOOL keepChecking = YES;
		while(keepChecking)
		{
			eachMember = va_arg(argumentList, id);
			if(eachMember!=nil)
			{
				for(unsigned int i=0; i<[eachMember count]; i++)
				{
					[path addObject:[eachMember memberAtIndex:i]];
				}
			}
			else
			{
				keepChecking = NO;
			}
		}
		va_end(argumentList);
	}
	
	return self;
}

- (NSString*)pathAsString
{
	NSMutableString* str = [[NSMutableString alloc] initWithString:@"/"];
	for(unsigned int i=0; i<[path count]; i++)
	{
		[str appendString:[path objectAtIndex:i]];
		if(i!=([path count]-1))
		{
			[str appendString:@"/"];
		}
	}
	return [str autorelease];
}

- (NSUInteger)count
{
	return [path count];
}

- (NSString*)memberAtIndex:(NSUInteger)index
{
	return [path objectAtIndex:index];
}

- (NSString*)firstMember
{
	if([path count]>0)
	{
		return [path objectAtIndex:0];
	}
	return @"/";
}

- (NSString*)lastMember
{
	if([path count]>0)
	{
		return [path objectAtIndex:([path count]-1)];
	}
	return @"/";
}

- (NSFilePath*)pathAtIndex:(NSUInteger)index
{
	if(index>=[path count])
	{
		return nil;
	}
	
	NSMutableFilePath*filePath = [[NSMutableFilePath alloc] init];
	for(unsigned int i=0; i<=index; i++)
	{
		[filePath addMember:[path objectAtIndex:i]];
	}
	
	return [filePath autorelease];
}

- (NSFilePath*)pathRelativeTo:(NSFilePath *)rootPath
{
	if([path count]<[rootPath count])
	{
		return nil;
	}
	
	for(int i=0; i<[rootPath count]; i++)
	{
		if(![[path objectAtIndex:i] isEqual:[rootPath memberAtIndex:i]])
		{
			return nil;
		}
	}
	
	NSMutableFilePath* filePath = [[NSMutableFilePath alloc] init];
	
	for(int i=[rootPath count]; i<[path count]; i++)
	{
		[filePath addMember:[path objectAtIndex:i]];
	}
	
	return [filePath autorelease];
}

- (BOOL)isEqual:(NSFilePath*)object
{
	if([path count]==[object.path count])
	{
		for(unsigned int i=0; i<[path count]; i++)
		{
			if(![[path objectAtIndex:i] isEqual:[object.path objectAtIndex:i]])
			{
				return NO;
			}
		}
		return YES;
	}
	return NO;
}

- (BOOL)containsSubfoldersOf:(NSFilePath*)object
{
	if([path count] >= [object.path count])
	{
		for(unsigned int i=0; i<[object.path count]; i++)
		{
			if(![[path objectAtIndex:i] isEqual:[object.path objectAtIndex:i]])
			{
				return NO;
			}
		}
		return YES;
	}
	return NO;
}

- (void)dealloc
{
	[path release];
	[super dealloc];
}

@end

@implementation NSMutableFilePath

+ (NSMutableFilePath*)pathWithString:(NSString*)path
{
	return [[[NSMutableFilePath alloc] initWithString:path] autorelease];
}

+ (NSMutableFilePath*)pathWithMembers:(NSString*)member, ...
{
	NSMutableFilePath* filePath = [[[NSMutableFilePath alloc] init] autorelease];
	
	id eachMember;
	va_list argumentList;
	if (member)
	{
		[filePath addMember:member];
		va_start(argumentList, member);
		BOOL keepChecking = YES;
		while(keepChecking)
		{
			eachMember = va_arg(argumentList, id);
			if(eachMember!=nil)
			{
				[filePath addMember:eachMember];
			}
			else
			{
				keepChecking = NO;
			}
		}
		va_end(argumentList);
	}
	
	return filePath;
}

+ (NSMutableFilePath*)pathWithFilePath:(NSFilePath*)path
{
	return [[[NSMutableFilePath alloc] initWithFilePath:path] autorelease];
}

+ (NSMutableFilePath*)pathWithFilePaths:(NSFilePath*)path, ...
{
	NSMutableFilePath* filePath = [[[NSMutableFilePath alloc] init] autorelease];
	
	id eachMember;
	va_list argumentList;
	if (path)
	{
		[filePath appendPath:path];
		va_start(argumentList, path);
		BOOL keepChecking = YES;
		while(keepChecking)
		{
			eachMember = va_arg(argumentList, id);
			if(eachMember!=nil)
			{
				[filePath appendPath:eachMember];
			}
			else
			{
				keepChecking = NO;
			}
		}
		va_end(argumentList);
	}
	
	return filePath;
}

- (id)init
{
	if([super initWithString:@""]==nil)
	{
		return nil;
	}
	
	return self;
}

- (void)addMember:(NSString*)member
{
	[self.path addObject:member];
}

- (void)removeMemberAtIndex:(NSUInteger)index
{
	[self.path removeObjectAtIndex:index];
}

- (void)removeLastMember
{
	if([self.path count]>0)
	{
		[self.path removeLastObject];
	}
}

- (void)removeAllMembers
{
	[self.path removeAllObjects];
}

- (void)appendPath:(NSFilePath*)path
{
	for(unsigned int i=0; i<[path count]; i++)
	{
		[self.path addObject:[path memberAtIndex:i]];
	}
}

@end

