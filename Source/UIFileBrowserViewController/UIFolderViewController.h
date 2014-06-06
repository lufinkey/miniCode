
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSFilePath.h"

@class UIFileBrowserViewController;

@interface UIFolderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSString* folder;
	
	NSMutableArray* folders;
	NSMutableArray* files;
	NSMutableArray* links;
	
	NSMutableArray* appNames;
	NSMutableArray* appIcons;
	
	UITableView* fileTable;
	
	UIFileBrowserViewController* navigator;
	
	@private
	BOOL firstOpen;
}

- (id)initWithName:(NSString*)name entries:(NSArray*)entries navigator:(UIFileBrowserViewController*)navigator;

- (void)resetFrame;
- (void)refreshWithEntries:(NSArray*)entries;
- (BOOL)itemIsLink:(NSString*)item;
- (NSFilePath*)getPath;

@property (nonatomic, retain, readonly) NSString* folder;
@property (nonatomic, retain, readonly) NSArray* folders;
@property (nonatomic, retain, readonly) NSArray* files;
@property (nonatomic, retain, readonly) NSArray* links;
@property (nonatomic, retain, readonly) UITableView* fileTable;
@property (nonatomic, retain, readonly) UIFileBrowserViewController* navigator;

@end
