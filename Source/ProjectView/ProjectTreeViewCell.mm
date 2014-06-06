
#import "ProjectTreeViewCell.h"
#import "../IconManager/IconManager.h"
#import "../Util/UIImageManager.h"

@implementation ProjectTreeViewCell

@synthesize identifier;
@synthesize categoryName;
@synthesize type;
@synthesize extension;

- (id)initWithType:(ProjectTreeCellType)typ identifier:(NSString*)identify
{
	switch(typ)
	{
		default:
		{
			[self release];
			return nil;
		}
		break;
			
		case PROJECTTREECELL_FILE:
		{
			NSString* name = identify;
			NSRange range = [identify rangeOfString:@"/" options:NSBackwardsSearch];
			if(range.location!=NSNotFound)
			{
				while(range.location==([identify length]-1) && [identify length]!=0)
				{
					identify = [identify substringToIndex:range.location];
					range = [identify rangeOfString:@"/" options:NSBackwardsSearch];
				}
				
				if([identify length]==0)
				{
					[self release];
					return nil;
				}
				
				if(range.location==NSNotFound)
				{
					name = identify;
				}
				else
				{
					name = [identify substringFromIndex:(range.location+1)];
				}
			}
			
			if([super initWithText:name]==nil)
			{
				return nil;
			}
			self.extension = [IconManager getExtensionForFilename:identify];
			[ProjectTreeViewCell applyFileThumbnailToCell:self extension:extension];
			
		}
		break;
		
		case PROJECTTREECELL_DYNAMICFOLDER:
		case PROJECTTREECELL_FOLDER:
		{
			NSString* name = identify;
			NSRange range = [identify rangeOfString:@"/" options:NSBackwardsSearch];
			if(range.location!=NSNotFound)
			{
				while(range.location==([identify length]-1) && [identify length]!=0)
				{
					identify = [identify substringToIndex:range.location];
					range = [identify rangeOfString:@"/" options:NSBackwardsSearch];
				}
				
				if([identify length]==0)
				{
					[self release];
					return nil;
				}
				
				if(range.location==NSNotFound)
				{
					name = identify;
				}
				else
				{
					name = [identify substringFromIndex:(range.location+1)];
				}
			}
			
			if([super initWithText:name]==nil)
			{
				return nil;
			}
			[self setIcon:[UIImageManager getImage:@"Images/icons/folder_small.png"]];
			[self setAsBranch:YES];
			self.extension = @"";
		}
		break;
		
		case PROJECTTREECELL_INCLUDEDIR:
		case PROJECTTREECELL_LIBDIR:
		case PROJECTTREECELL_CATEGORY:
		{
			if([super initWithText:identify]==nil)
			{
				return nil;
			}
			[self setIcon:[UIImageManager getImage:@"Images/icons/folder_small.png"]];
			[self setAsBranch:YES];
			self.extension = @"";
		}
		break;
		
		case PROJECTTREECELL_FRAMEWORK:
		{
			if([super initWithText:identify]==nil)
			{
				return nil;
			}
			[self setIcon:[IconManager imageForExtension:@"framework"]];
			[self setAsBranch:YES];
			self.extension = @"";
		}
		break;
	}
	
	self.type = typ;
	self.identifier = identify;
	self.categoryName = @"";
	
	return self;
}

+ (void)applyFileThumbnailToCell:(UITreeViewCell*)cell extension:(NSString*)extension
{
	UIImage* image = [IconManager imageForExtension:extension];
	if(image!=nil)
	{
		[cell setIcon:image];
	}
}

- (NSMutableString*)getPath
{
	switch(type)
	{
		default:
		return [[[NSMutableString alloc] initWithString:identifier] autorelease];
		
		case PROJECTTREECELL_FILE:
		{
			NSMutableString*str = nil;
			if([supercell isKindOfClass:[ProjectTreeViewCell class]])
			{
				str = [((ProjectTreeViewCell*)supercell) getPath];
			}
			else
			{
				str = [[[NSMutableString alloc] initWithString:@""] autorelease];
			}
			[str appendString:identifier];
			return str;
		}
		
		case PROJECTTREECELL_FOLDER:
		{
			NSMutableString*str = nil;
			if([supercell isKindOfClass:[ProjectTreeViewCell class]])
			{
				str = [((ProjectTreeViewCell*)supercell) getPath];
			}
			else
			{
				str = [[[NSMutableString alloc] initWithString:@""] autorelease];
			}
			[str appendString:identifier];
			[str appendString:@"/"];
			return str;
		}
		
		case PROJECTTREECELL_DYNAMICFOLDER:
		{
			NSMutableString* str = [[[NSMutableString alloc] initWithString:identifier] autorelease];
			if([str UTF8String][[str length]-1]!='/')
			{
				[str appendString:@"/"];
			}
			return str;
		}
		
		case PROJECTTREECELL_CATEGORY:
		case PROJECTTREECELL_INCLUDEDIR:
		case PROJECTTREECELL_LIBDIR:
		return [[[NSMutableString alloc] initWithString:@""] autorelease];
		
		case PROJECTTREECELL_FRAMEWORK:
		return [[[NSMutableString alloc] initWithString:@""] autorelease];
	}
}

- (NSString*)getCategory
{
	if(type==PROJECTTREECELL_CATEGORY)
	{
		return categoryName;
	}
	else
	{
		if(supercell!=nil)
		{
			return [((ProjectTreeViewCell*)supercell) getCategory];
		}
		return @"";
	}
}

- (BOOL)storedUnderType:(ProjectTreeCellType)typ
{
	if(type==typ)
	{
		return YES;
	}
	else
	{
		if(supercell!=nil && [supercell isKindOfClass:[ProjectTreeViewCell class]])
		{
			return [((ProjectTreeViewCell*)supercell) storedUnderType:typ];
		}
		return NO;
	}
}

- (void)dealloc
{
	[identifier release];
	[categoryName release];
	[extension release];
	[super dealloc];
}

@end
