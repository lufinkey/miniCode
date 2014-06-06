
#import <UIKit/UIKit.h>
#import "iCodeAppDelegate.h"
#import "ObjCBridge/ObjCBridge.h"
#import <unistd.h>

int main(int argc, char *argv[])
{
	//setuid(0);
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	init_ObjCBridge(argc, argv);
	int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([iCodeAppDelegate class]));
	[pool release];
	return retVal;
}
