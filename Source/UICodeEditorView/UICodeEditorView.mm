
#import "UICodeEditorView.h"
#import <UIKit/UITextInput.h>

TabOffset TabOffsetMake(unsigned int tabs, unsigned int spaces)
{
	TabOffset tabOffset;
	tabOffset.tabs = tabs;
	tabOffset.spaces = spaces;
	return tabOffset;
}

NSRange NSRangeTrim(NSRange range, NSRange trim)
{
	NSUInteger rangeStart = range.location;
	NSUInteger rangeEnd = range.location + range.length;
	NSUInteger trimStart = trim.location;
	NSUInteger trimEnd = trim.location + trim.length;
	
	if(trimEnd <= rangeEnd)
	{
		if(trimEnd < rangeStart)
		{
			return NSMakeRange(rangeStart - trim.length, range.length);
		}
		else
		{
			if(trimStart>=rangeStart)
			{
				return NSMakeRange(rangeStart, range.length-trim.length);
			}
			else
			{
				return NSMakeRange(trimStart, rangeEnd - trimEnd);
			}
		}
	}
	else
	{
		if(trimStart >= rangeStart)
		{
			return NSMakeRange(rangeStart, trimStart - rangeStart);
		}
		else
		{
			return NSMakeRange(trimStart, 0);
		}
	}
}

NSRange NSRangePush(NSRange range, NSRange push)
{
	NSUInteger rangeStart = range.location;
	NSUInteger rangeEnd = range.location + range.length;
	if(push.location <= rangeStart)
	{
		return NSMakeRange(rangeStart + push.length, range.length);
	}
	else if(push.location < rangeEnd)
	{
		return NSMakeRange(rangeStart, range.length + push.length);
	}
	return NSMakeRange(range.location, range.length);
}

UITextRange* UITextRange_createFromNSRange(NSRange range, id<UITextInput> textInput)
{
	UITextPosition *beginning = [textInput beginningOfDocument];
	UITextPosition *start = [textInput positionFromPosition:beginning offset:range.location];
	UITextPosition *end = [textInput positionFromPosition:start offset:range.length];
	return [textInput textRangeFromPosition:start toPosition:end];
}

static unsigned int tabSpaces = 8;

@implementation UICodeEditorView

@synthesize autotabbingEnabled;
@synthesize codeCompletionEnabled;
@synthesize syntaxHighlightingEnabled;

- (id)initWithFrame:(CGRect)frame
{
	autotabbingEnabled = YES;
	codeCompletionEnabled = YES;
	syntaxHighlightingEnabled = YES;
	
	if([super initWithFrame:frame]==nil)
	{
		return nil;
	}
	
	return self;
}

- (void)overwriteRange:(NSRange)range withText:(NSString*)text
{
	BOOL wasFirstResponder = [self isFirstResponder];
	NSRange oldSelectedRange = self.selectedRange;
	
	BOOL scrollWasEnabled = self.scrollEnabled;
	id<UITextInput> textInput = (id<UITextInput>)self;
	UITextRange* textRange = UITextRange_createFromNSRange(range, textInput);
	[textInput replaceRange:textRange withText:text];
	
	if(wasFirstResponder)
	{
		if(range.length>[text length])
		{
			oldSelectedRange = NSRangeTrim(oldSelectedRange, NSMakeRange(range.location+[text length], range.length-[text length]));
		}
		else if(range.length<[text length])
		{
			oldSelectedRange = NSRangePush(oldSelectedRange, NSMakeRange(range.location+range.length, [text length]-range.length));
		}
		self.selectedRange = oldSelectedRange;
		[self becomeFirstResponder];
	}
	[self setScrollEnabled:scrollWasEnabled];
}

- (void)insertText:(NSString*)text atPoint:(NSUInteger)location
{
	[self overwriteRange:NSMakeRange(location, 0) withText:text];
}

- (NSRange)deleteTabInFront:(NSUInteger)location
{
	unsigned int totalLength = [self.text length];
	if(totalLength==0)
	{
		return NSMakeRange(location, 0);
	}
	
	unsigned int currentPoint = location;
	const char* text = [self.text UTF8String];
	BOOL hitEnd = NO;
	
	int totalSlots = 0;
	
	while(currentPoint<totalLength && !hitEnd)
	{
		if(text[currentPoint]==' ')
		{
			totalSlots++;
			if(totalSlots>=tabSpaces)
			{
				hitEnd = YES;
			}
		}
		else if(text[currentPoint]=='\t')
		{
			totalSlots++;
			hitEnd = YES;
		}
		else if(text[currentPoint]=='\n')
		{
			hitEnd = YES;
		}
	}
	
	if(totalSlots>0)
	{
		NSRange deleteRange = NSMakeRange(location, totalSlots);
		[self overwriteRange:deleteRange withText:@""];
		return deleteRange;
	}
	return NSMakeRange(location, 0);
}

- (NSRange)deleteTabBehind:(NSUInteger)location
{
	unsigned int totalLength = [self.text length];
	if(totalLength==0)
	{
		return NSMakeRange(location, 0);
	}
	
	unsigned int currentPoint = location-1;
	unsigned int startPoint = 0;
	const char* currentText = [self.text UTF8String];
	
	BOOL hitEnd = NO;
	
	while(!hitEnd)
	{
		if(currentText[currentPoint]!=' ' && currentText[currentPoint]!='\t')
		{
			hitEnd = YES;
			startPoint = currentPoint+1;
		}
		
		if(!hitEnd)
		{
			if(currentPoint==0)
			{
				startPoint = 0;
				hitEnd = YES;
			}
			else
			{
				currentPoint--;
			}
		}
	}
	
	unsigned int totalSlots = 0;
	
	for(unsigned int i=startPoint; i<location; i++)
	{
		if(currentText[i]==' ')
		{
			totalSlots++;
			if(totalSlots>=tabSpaces)
			{
				if(i!=(location-1))
				{
					totalSlots = 0;
				}
			}
		}
		else if(currentText[i]=='\t')
		{
			totalSlots++;
			if(i!=(location-1))
			{
				totalSlots = 0;
			}
		}
	}
	
	if(totalSlots>0)
	{
		NSRange deleteRange = NSMakeRange(location-totalSlots, totalSlots);
		[self overwriteRange:deleteRange withText:@""];
		return deleteRange;
	}
	return NSMakeRange(location, 0);
}

- (NSRange)deleteTabFromLine:(NSUInteger)location
{
	unsigned int totalLength = [self.text length];
	if(totalLength==0)
	{
		return NSMakeRange(location, 0);
	}
	
	unsigned int currentPoint = location;
	unsigned int startPoint = 0;
	const char* currentText = [self.text UTF8String];
	
	BOOL hitEnd = NO;
	
	while(!hitEnd)
	{
		if(currentText[currentPoint]=='\n')
		{
			hitEnd = YES;
			startPoint = currentPoint+1;
		}
		
		if(!hitEnd)
		{
			if(currentPoint==0)
			{
				startPoint = 0;
				hitEnd = YES;
			}
			else
			{
				currentPoint--;
			}
		}
	}
	
	unsigned int lastIndex = totalLength-1;
	
	unsigned int lastSlotStart = startPoint;
	unsigned int lastTotalSlots = 0;
	unsigned int slotStart = startPoint;
	unsigned int totalSlots = 0;
	
	hitEnd = NO;
	
	currentPoint = startPoint;
	while(!hitEnd)
	{
		if(currentText[currentPoint]==' ')
		{
			totalSlots++;
			if(totalSlots>=tabSpaces)
			{
				lastTotalSlots = totalSlots;
				lastSlotStart = slotStart;
				totalSlots = 0;
				slotStart = currentPoint+1;
			}
		}
		else if(currentText[currentPoint]=='\t')
		{
			totalSlots++;
			
			lastTotalSlots = totalSlots;
			lastSlotStart = slotStart;
			totalSlots = 0;
			slotStart = currentPoint+1;
		}
		else
		{
			hitEnd = YES;
		}
		
		if(!hitEnd)
		{
			if(currentPoint>=lastIndex)
			{
				hitEnd = YES;
			}
			else
			{
				currentPoint++;
			}
		}
	}
	
	if(totalSlots==0)
	{
		totalSlots = lastTotalSlots;
		slotStart = lastSlotStart;
	}
	
	if(totalSlots>0)
	{
		NSRange deleteRange = NSMakeRange(slotStart, totalSlots);
		[self overwriteRange:deleteRange withText:@""];
		return deleteRange;
	}
	return NSMakeRange(location, 0);
}

- (NSRange)insertTab:(NSUInteger)location
{
	[self overwriteRange:NSMakeRange(location, 0) withText:@"\t"];
	return NSMakeRange(location, 1);
}

- (NSRange)insertTabInLine:(NSUInteger)location
{
	unsigned int totalLength = [self.text length];
	if(totalLength==0)
	{
		return [self insertTab:location];
	}
	
	unsigned int currentPoint = location;
	unsigned int startPoint = 0;
	const char* currentText = [self.text UTF8String];
	
	BOOL hitEnd = NO;
	
	while(!hitEnd)
	{
		if(currentText[currentPoint]=='\n')
		{
			hitEnd = YES;
			startPoint = currentPoint+1;
		}
		
		if(!hitEnd)
		{
			if(currentPoint==0)
			{
				startPoint = 0;
				hitEnd = YES;
			}
			else
			{
				currentPoint--;
			}
		}
	}
	
	unsigned int lastIndex = totalLength-1;
	
	hitEnd = NO;
	
	currentPoint = startPoint;
	while(!hitEnd)
	{
		if(currentText[currentPoint]!=' ' && currentText[currentPoint]!='\t')
		{
			hitEnd = YES;
			return [self insertTab:currentPoint];
		}
		
		if(!hitEnd)
		{
			if(currentPoint>=lastIndex)
			{
				hitEnd = YES;
				return [self insertTab:lastIndex+1];
			}
			else
			{
				currentPoint++;
			}
		}
	}
	return NSMakeRange(location, 0);
}

- (void)tabLeft:(NSRange)range
{
	if(range.length==0)
	{
		if(range.location==0)
		{
			[self deleteTabInFront:0];
		}
		else
		{
			NSRange deleteRange = [self deleteTabBehind:range.location];
			if(deleteRange.length==0)
			{
				deleteRange = [self deleteTabInFront:range.location];
				if(deleteRange.length==0)
				{
					[self deleteTabFromLine:range.location];
				}
			}
		}
	}
	else
	{
		NSRange deleteRange = [self deleteTabFromLine:range.location];
		range = NSRangeTrim(range, deleteRange);
		
		NSRange currentPoint = NSMakeRange(range.location, range.length);
		for(currentPoint.location = range.location; currentPoint.location < (range.location+range.length); currentPoint.location++)
		{
			if([self.text UTF8String][currentPoint.location]=='\n')
			{
				if(currentPoint.location != ((range.location+range.length)-1))
				{
					deleteRange = [self deleteTabFromLine:currentPoint.location+1];
					currentPoint = NSRangeTrim(currentPoint, deleteRange);
					range = NSRangeTrim(range, deleteRange);
				}
			}
		}
	}
}

- (void)tabRight:(NSRange)range
{
	if(range.length==0)
	{
		[self insertTab:range.location];
	}
	else
	{
		NSRange pushRange = [self insertTabInLine:range.location];
		range = NSRangePush(range, pushRange);
		
		NSRange currentPoint = NSMakeRange(range.location, range.length);
		for(currentPoint.location = range.location; currentPoint.location < (range.location+range.length); currentPoint.location++)
		{
			if([self.text UTF8String][currentPoint.location]=='\n')
			{
				if(currentPoint.location != ((range.location+range.length)-1))
				{
					pushRange = [self insertTabInLine:currentPoint.location+1];
					currentPoint = NSRangePush(currentPoint, pushRange);
					range = NSRangePush(range, pushRange);
				}
			}
		}
	}
}

- (TabOffset)tabOffsetForLine:(NSUInteger)location
{
	unsigned int totalLength = [self.text length];
	if(totalLength==0)
	{
		return TabOffsetMake(0, 0);
	}
	
	unsigned int currentPoint = location;
	unsigned int startPoint = 0;
	const char* currentText = [self.text UTF8String];
	
	BOOL hitEnd = NO;
	
	while(!hitEnd)
	{
		if(currentText[currentPoint]=='\n')
		{
			hitEnd = YES;
			startPoint = currentPoint+1;
		}
		
		if(!hitEnd)
		{
			if(currentPoint==0)
			{
				startPoint = 0;
				hitEnd = YES;
			}
			else
			{
				currentPoint--;
			}
		}
	}
	
	unsigned int lastIndex = totalLength-1;
	
	unsigned int tabs = 0;
	unsigned int spaces = 0;
	
	hitEnd = NO;
	
	currentPoint = startPoint;
	while(!hitEnd)
	{
		if(currentText[currentPoint]==' ')
		{
			spaces++;
			if(spaces>=tabSpaces)
			{
				spaces = 0;
				tabs++;
			}
		}
		else if(currentText[currentPoint]=='\t')
		{
			spaces = 0;
			tabs++;
		}
		else
		{
			hitEnd = YES;
		}
		
		if(!hitEnd)
		{
			if(currentPoint>=lastIndex)
			{
				hitEnd = YES;
			}
			else
			{
				currentPoint++;
			}
		}
	}
	
	return TabOffsetMake(tabs, spaces);
}

@end
