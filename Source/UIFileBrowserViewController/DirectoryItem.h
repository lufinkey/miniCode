
#import <Foundation/Foundation.h>

typedef enum
{
	DIRECTORYITEM_UNKNOWN,
	DIRECTORYITEM_FILE,
	DIRECTORYITEM_FOLDER,
	DIRECTORYITEM_LINK_FILE,
	DIRECTORYITEM_LINK_FOLDER
} DirectoryItemType;

@interface DirectoryItem : NSObject
{
	DirectoryItemType type;
	NSString* name;
}

- (id)initWithName:(NSString*)name type:(DirectoryItemType)type;

@property (nonatomic) DirectoryItemType type;
@property (nonatomic, retain) NSString* name;

@end
