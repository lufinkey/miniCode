
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UITreeView;

@interface UITreeViewCell : UIControl
{
	UITreeView* tree;
	UITreeViewCell* supercell;
	NSString* text;
	NSMutableArray* cells;
	
	@private
	UIView* bgView;
	UIImageView* carrotView;
	UIImageView* iconView;
	UILabel* label;
	UIButton* button;
	BOOL isBranch;
	BOOL branchOpened;
	BOOL isSelected;
}

- (id)initWithText:(NSString*)text;

- (NSUInteger)getCurrentLevel;

- (BOOL)isSetAsBranch;
- (void)setAsBranch:(BOOL)toggle;
- (void)setBranchOpen:(BOOL)toggle;
- (BOOL)isBranchOpen;

- (NSUInteger)count;
- (void)addMember:(UITreeViewCell*)cell;
- (void)insertMember:(UITreeViewCell*)cell atIndex:(NSUInteger)index;
- (void)removeMember:(UITreeViewCell*)cell;
- (void)removeMemberAtIndex:(NSUInteger)index;
- (UITreeViewCell*)memberAtIndex:(NSUInteger)index;
- (NSInteger)indexOfMember:(UITreeViewCell*)cell;
- (void)moveMemberAtIndex:(NSUInteger)srcIndex toIndex:(NSUInteger)dstIndex;
- (void)removeAllMembers;

- (void)setIcon:(UIImage*)icon;
- (void)setButtonShown:(BOOL)toggle;
- (void)setButtonImage:(UIImage*)image forState:(UIControlState)state;

- (void)deselect;

@property (nonatomic, assign, readonly) UITreeView* tree;
@property (nonatomic, assign, readonly) UITreeViewCell* supercell;
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSArray* cells;

@end
