
#import <UIKit/UIKit.h>

typedef struct
{
	unsigned int tabs;
	unsigned int spaces;
} TabOffset;

TabOffset TabOffsetMake(unsigned int tabs, unsigned int spaces);

@interface UICodeEditorView : UITextView
{
	BOOL autotabbingEnabled;
	BOOL codeCompletionEnabled;
	BOOL syntaxHighlightingEnabled;
}

- (NSRange)deleteTabInFront:(NSUInteger)location;
- (NSRange)deleteTabBehind:(NSUInteger)location;
- (NSRange)deleteTabFromLine:(NSUInteger)location;

- (NSRange)insertTab:(NSUInteger)location;
- (NSRange)insertTabInLine:(NSUInteger)location;

- (TabOffset)tabOffsetForLine:(NSUInteger)location;

- (void)tabLeft:(NSRange)range;
- (void)tabRight:(NSRange)range;

- (void)overwriteRange:(NSRange)range withText:(NSString*)text;
- (void)insertText:(NSString*)text atPoint:(NSUInteger)location;

@property (nonatomic) BOOL autotabbingEnabled;
@property (nonatomic) BOOL codeCompletionEnabled;
@property (nonatomic) BOOL syntaxHighlightingEnabled;
@end
