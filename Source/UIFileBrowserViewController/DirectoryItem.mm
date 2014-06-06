
#import "DirectoryItem.h"

@implementation DirectoryItem

@synthesize name;
@synthesize type;

- (id)initWithName:(NSString *)itemName type:(DirectoryItemType)itemType
{
	if([super init]==nil)
	{
		return nil;
	}
	
	self.name = itemName;
	self.type = itemType;
	
	return self;
}

- (void)dealloc
{
	[name release];
	[super dealloc];
}

@end