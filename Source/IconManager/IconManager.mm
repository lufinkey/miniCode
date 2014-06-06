
#import "IconManager.h"
#import "../Util/UIImageManager.h"
#import "../ProjectLoad/ProjLoadTools.h"

@implementation IconManager

static UIImage* folderImage = nil;
static UIImage* fileImage = nil;

static NSMutableArray* fileImages = [[NSMutableArray alloc] init];
static NSMutableArray* extensions = [[NSMutableArray alloc] init];

static NSMutableArray* packages = [[NSMutableArray alloc] init];

+ (void)reloadFromFile
{
	[fileImages removeAllObjects];
	[extensions removeAllObjects];
	[packages removeAllObjects];
	[fileImage release];
	fileImage = nil;
	[folderImage release];
	folderImage = nil;
	
	NSDictionary*dict = (NSDictionary*)ProjLoad_loadAllocatedPlist("Images/icons/icons.plist");
	if(dict!=nil)
	{
		NSDictionary* icons = [dict objectForKey:@"icons"];
		if(icons!=nil)
		{
			NSArray* keys = [icons allKeys];
			for(int i=0; i<[keys count]; i++)
			{
				NSString*extension = [keys objectAtIndex:i];
				NSString*file = [icons objectForKey:extension];
				if(file!=nil)
				{
					NSMutableString* path = [[NSMutableString alloc] initWithUTF8String:"Images/icons/"];
					[path appendString:file];
					if([UIImageManager loadImage:path])
					{
						UIImage*image = [UIImageManager getImage:path];
						[fileImages addObject:image];
						[extensions addObject:extension];
					}
					[path release];
				}
			}
		}
		
		NSString* fileFile = [dict objectForKey:@"file"];
		if(fileFile!=nil)
		{
			NSMutableString* path = [[NSMutableString alloc] initWithUTF8String:"Images/icons/"];
			[path appendString:fileFile];
			if([UIImageManager loadImage:path])
			{
				fileImage = [UIImageManager getImage:path];
				[fileImage retain];
			}
			[path release];
		}
		
		NSString* folderFile = [dict objectForKey:@"folder"];
		if(fileFile!=nil)
		{
			NSMutableString* path = [[NSMutableString alloc] initWithUTF8String:"Images/icons/"];
			[path appendString:folderFile];
			if([UIImageManager loadImage:path])
			{
				folderImage = [UIImageManager getImage:path];
				[folderImage retain];
			}
			[path release];
		}
		
		NSArray*pkgs = [dict objectForKey:@"packages"];
		if(pkgs!=nil)
		{
			for(int i=0; i<[pkgs count]; i++)
			{
				[packages addObject:[pkgs objectAtIndex:i]];
			}
		}
	}
	else
	{
		NSLog(@"failed getting dict");
	}
	
	[dict release];
}

+ (void)setImage:(UIImage*)image forExtension:(NSString*)extension
{
	if(image==nil || extension==nil)
	{
		return;
	}
	else if([extension isEqual:@""])
	{
		[fileImage release];
		fileImage = image;
		[fileImage retain];
		return;
	}
	
	for(int i=0; i<[extensions count]; i++)
	{
		NSString*cmpExt = [extensions objectAtIndex:i];
		if([extension isEqual:cmpExt])
		{
			[fileImages replaceObjectAtIndex:i withObject:image];
			return;
		}
	}
	
	[fileImages addObject:image];
	[extensions addObject:extension];
}

+ (UIImage*)imageForExtension:(NSString*)extension
{
	if(extension==nil)
	{
		return nil;
	}
	else if([extension isEqual:@""])
	{
		return fileImage;
	}
	else if([extension UTF8String][0]=='.')
	{
		if([extension length]==1)
		{
			return fileImage;
		}
		extension = [extension substringFromIndex:1];
	}
	
	for(int i=0; i<[extensions count]; i++)
	{
		NSString* cmpExt = [extensions objectAtIndex:i];
		if([extension isEqual:cmpExt])
		{
			return [fileImages objectAtIndex:i];
		}
	}
	
	return fileImage;
}

+ (void)setFolderImage:(UIImage*)image
{
	if(image==nil)
	{
		return;
	}
	[folderImage release];
	folderImage = image;
	[folderImage retain];
}

+ (UIImage*)imageForFolder
{
	return folderImage;
}

+ (BOOL)extensionIsPackage:(NSString*)extension
{
	if(extension==nil)
	{
		return NO;
	}
	
	for(int i=0; i<[packages count]; i++)
	{
		NSString*cmpExt = [packages objectAtIndex:i];
		if([extension isEqual:cmpExt])
		{
			return YES;
		}
	}
	return NO;
}

+ (NSString*)getExtensionForFilename:(NSString*)fileName
{
	if(fileName==nil)
	{
		return @"";
	}
	
	NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location==NSNotFound || range.location==([fileName length]-1))
	{
		return @"";
	}
	return [[fileName substringFromIndex:(range.location+1)] lowercaseString];
}

+ (UIImage*)iconForApplication:(NSString*)appPath
{
	NSMutableString* infoPlistPath = [[NSMutableString alloc] initWithString:appPath];
	[infoPlistPath appendString:@"/Info.plist"];
	NSDictionary* appInfoPlist = [[NSDictionary alloc] initWithContentsOfFile:infoPlistPath];
	[infoPlistPath release];
	if(appInfoPlist!=nil)
	{
		NSString* iconFile = [appInfoPlist objectForKey:@"CFBundleIconFile"];
		if(iconFile!=nil && [iconFile length]!=0)
		{
			NSMutableString* iconFullPath = [[NSMutableString alloc] initWithString:appPath];
			[iconFullPath appendString:@"/"];
			[iconFullPath appendString:iconFile];
			UIImage* iconImage = [UIImageManager loadUnstoredImage:iconFullPath logError:NO];
			if(iconImage!=nil)
			{
				[appInfoPlist release];
				[iconFullPath release];
				return iconImage;
			}
			else
			{
				[appInfoPlist release];
				[iconFullPath release];
				iconFullPath = [[NSMutableString alloc] initWithString:appPath];
				[iconFullPath appendString:@"/Icon.png"];
				iconImage = [UIImageManager loadUnstoredImage:iconFullPath logError:NO];
				if(iconImage!=nil)
				{
					[iconFullPath release];
					return iconImage;
				}
				else
				{
					[iconFullPath release];
					iconFullPath = [[NSMutableString alloc] initWithString:appPath];
					[iconFullPath appendString:@"/icon.png"];
					iconImage = [UIImageManager loadUnstoredImage:iconFullPath logError:NO];
					if(iconImage!=nil)
					{
						[iconFullPath release];
						return iconImage;
					}
					else
					{
						[iconFullPath release];
						return [IconManager imageForExtension:@"app"];
					}
					
				}
			}
		}
		else
		{
			[appInfoPlist release];
			NSMutableString* iconFullPath = [[NSMutableString alloc] initWithString:appPath];
			[iconFullPath appendString:@"/Icon.png"];
			UIImage* iconImage = [UIImageManager loadUnstoredImage:iconFullPath logError:NO];
			if(iconImage!=nil)
			{
				[iconFullPath release];
				return iconImage;
			}
			else
			{
				[iconFullPath release];
				iconFullPath = [[NSMutableString alloc] initWithString:appPath];
				[iconFullPath appendString:@"/icon.png"];
				iconImage = [UIImageManager loadUnstoredImage:iconFullPath logError:NO];
				if(iconImage!=nil)
				{
					[iconFullPath release];
					return iconImage;
				}
				else
				{
					[iconFullPath release];
					return [IconManager imageForExtension:@"app"];
				}
			}
		}
	}
	else
	{
		[appInfoPlist release];
		NSMutableString* iconFullPath = [[NSMutableString alloc] initWithString:appPath];
		[iconFullPath appendString:@"/Icon.png"];
		UIImage* iconImage = [UIImageManager loadUnstoredImage:iconFullPath logError:NO];
		if(iconImage!=nil)
		{
			[iconFullPath release];
			return iconImage;
		}
		else
		{
			[iconFullPath release];
			iconFullPath = [[NSMutableString alloc] initWithString:appPath];
			[iconFullPath appendString:@"/icon.png"];
			iconImage = [UIImageManager loadUnstoredImage:iconFullPath logError:NO];
			if(iconImage!=nil)
			{
				[iconFullPath release];
				return iconImage;
			}
			else
			{
				[iconFullPath release];
				return [IconManager imageForExtension:@"app"];
			}
		}
	}
}

@end
