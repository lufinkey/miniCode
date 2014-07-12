
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef struct
{
	unsigned int tabs;
	unsigned int spaces;
} TabOffset;

TabOffset TabOffsetMake(unsigned int tabs, unsigned int spaces);

NSRange NSRangeTrim(NSRange range, NSRange trim);
NSRange NSRangePush(NSRange range, NSRange push);
UITextRange* UITextRange_createFromNSRange(NSRange range, id<UITextInput> textInput);

NSString* NSString_alloc_initWithSubstringOfString(NSString*str, unsigned int fromIndex, unsigned int toIndex);
CGFloat fontCharacterWidth(UIFont* font, char c);

@interface UICodeEditorView : UITextView//RegexHighlightView
{
	BOOL autotabbingEnabled;
	BOOL codeCompletionEnabled;
	BOOL highlightingEnabled;
	
	NSDictionary* highlightColor;
	NSDictionary* highlightDefinition;
	
	NSMutableAttributedString* mutableAttributedString;
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
@property (nonatomic) BOOL highlightingEnabled;
@property (nonatomic, retain) NSDictionary* highlightColor;
@property (nonatomic, retain) NSDictionary* highlightDefinition;
@property (nonatomic, retain) NSMutableAttributedString* mutableAttributedString;
@end
