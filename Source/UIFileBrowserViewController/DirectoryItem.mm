
#import "DirectoryItem.h"

@implementation DirectoryItem

@synthesize name;
@synthesize type;

- (id)initWithName:(NSString *)itemName type:(DirectoryItemType)itemType
{
	self = [super init];
	if(self==nil)
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