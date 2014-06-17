//  Copyright 2011 Vilea GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipsideViewController.h"

@interface UIWebViewController : UIViewController <UIWebViewDelegate, FlipsideViewControllerDelegate> {
    NSString *_currentPageName, *_currentPageDirectory; 
    UIWebView *webView;
}

- (void)loadPageNamed:(NSString*)name inSubdirectory:(NSString*)subdirectory;
- (void)loadExternalPage:(NSString*)url;
- (UIWebView*)webView;
@end
