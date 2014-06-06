
#import <Foundation/Foundation.h>
#import "../UITreeView/UITreeViewCell.h"

typedef enum
{
	PROJECTTREECELL_FILE,
	PROJECTTREECELL_FOLDER,
	PROJECTTREECELL_CATEGORY,
	PROJECTTREECELL_INCLUDEDIR,
	PROJECTTREECELL_LIBDIR,
	PROJECTTREECELL_DYNAMICFOLDER,
	PROJECTTREECELL_FRAMEWORK,
} ProjectTreeCellType;

@interface ProjectTreeViewCell : UITreeViewCell
{
	ProjectTreeCellType type;
	NSString* identifier;
	NSString* categoryName;
	
	NSString* extension;
}

- (id)initWithType:(ProjectTreeCellType)type identifier:(NSString*)identifier;

+ (void)applyFileThumbnailToCell:(UITreeViewCell*)cell extension:(NSString*)extension;

- (NSMutableString*)getPath;
- (NSString*)getCategory;
- (BOOL)storedUnderType:(ProjectTreeCellType)type;

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* categoryName;
@property (nonatomic, retain) NSString* extension;
@property (nonatomic) ProjectTreeCellType type;

@end
