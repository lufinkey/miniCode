
#import <Foundation/Foundation.h>

@interface NSObject (DeprecationFix)
- (void*)performSelector:(SEL)aSelector withValue:(void*)value;
- (void*)performSelector:(SEL)aSelector withValue:(void*)value withValue:(void*)value2;
- (void*)performSelector:(SEL)aSelector withValue:(void*)value withValue:(void*)value2 withValue:(void*)value3;
@end
