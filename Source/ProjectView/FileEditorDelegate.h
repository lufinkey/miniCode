
#import <Foundation/Foundation.h>

@protocol FileEditorDelegate <NSObject>

- (BOOL)loadWithFile:(NSString*)filePath;
- (void)setFileLocked:(BOOL)locked;

@end
