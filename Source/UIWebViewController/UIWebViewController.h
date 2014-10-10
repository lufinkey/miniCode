//  Copyright 2011 Vilea GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebViewController : UIViewController <UIWebViewDelegate> {
    NSString *_currentPageName, *_currentPageDirectory; 
    UIWebView *webView;
	
	@private
	UIActivityIndicatorView* activityView;
	UIBarButtonItem* activityIndicator;
}

- (void)loadPageNamed:(NSString*)name inSubdirectory:(NSString*)subdirectory;
- (void)loadExternalPage:(NSString*)url;
- (UIWebView*)webView;
- (void)dismissSelf;
@end
