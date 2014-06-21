
#import "NSObjectDeprecationFix.h"

@implementation NSObject (DeprecationFix)

- (void*)performSelector:(SEL)selector withValue:(void*)value
{
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
	[invocation setSelector:selector];
	[invocation setTarget:self];
	[invocation setArgument:value atIndex:2];

	[invocation invoke];
	
	NSUInteger length = [[invocation methodSignature] methodReturnLength];
	
	// If method is non-void:
	if (length > 0)
	{
		void *buffer = (void *)malloc(length);
		[invocation getReturnValue:buffer];
		return buffer;
	}
	
	// If method is void:
	return NULL;
}

@end
