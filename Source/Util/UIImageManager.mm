
#import "UIImageManager.h"
#import "../ObjCBridge/ObjCBridge.h"

@implementation UIImageManager

static NSMutableArray* images = [[NSMutableArray alloc] init];
static NSMutableArray* imageNames = [[NSMutableArray alloc] init];

+ (BOOL)isImageLoaded:(NSString*)path
{
	if(path==nil)
	{
		return NO;
	}
	else
	{
		for(int i=0; i<[imageNames count]; i++)
		{
			BOOL eq = [path isEqualToString:[imageNames objectAtIndex:i]];
			if(eq)
			{
				return YES;
			}
		}
	}
	return NO;
}

+ (BOOL)loadImage:(NSString*)path
{
	return [UIImageManager loadImage:path logError:YES];
}

+ (BOOL)loadImage:(NSString*)path logError:(BOOL)log
{
	UIImage* img = nil;
	if(path==nil)
	{
		return NO;
	}
	else if([UIImageManager isImageLoaded:path])
	{
		return YES;
	}
	
	if([path characterAtIndex:0]=='/')
	{
		img = [UIImage imageWithContentsOfFile:path];
	}
	else
	{
		img = [UIImage imageNamed:path];
	}
	
	if(img!=nil)
	{
		[images addObject:img];
		[imageNames addObject:path];
		return YES;
	}
	if(log)
	{
		NSMutableString*str = [[NSMutableString alloc] initWithString:@"Error loading image "];
		[str appendString:path];
		Console_Log([str UTF8String]);
		[str release];
	}
	return NO;
}

+ (UIImage*)loadUnstoredImage:(NSString*)path
{
	return [UIImageManager loadUnstoredImage:path logError:YES];
}

+ (UIImage*)loadUnstoredImage:(NSString*)path logError:(BOOL)log
{
	if([UIImageManager isImageLoaded:path])
	{
		return [UIImageManager getImage:path];
	}
	else
	{
		if([UIImageManager loadImage:path logError:log])
		{
			UIImage* tmpImage = [UIImageManager getImage:path];
			[tmpImage retain];
			[UIImageManager unloadImage:path];
			return [tmpImage autorelease];
		}
	}
	return nil;
}

+ (UIImage*)getImage:(NSString*)path
{
	for(int i=0; i<[imageNames count]; i++)
	{
		BOOL eq = [path isEqualToString:[imageNames objectAtIndex:i]];
		if(eq)
		{
			return [images objectAtIndex:i];
		}
	}
	return nil;
}

+ (BOOL)unloadImage:(NSString*)path
{
	for(int i=0; i<[imageNames count]; i++)
	{
		BOOL eq = [path isEqualToString:[imageNames objectAtIndex:i]];
		if(eq)
		{
			[images removeObjectAtIndex:i];
			[imageNames removeObjectAtIndex:i];
			return YES;
		}
	}
	return NO;
}

@end
