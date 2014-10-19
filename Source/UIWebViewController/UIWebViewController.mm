//  Copyright 2011 Vilea GmbH. All rights reserved.
//

#import "UIWebViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UIWebViewController ()
@property (nonatomic, retain) NSString *currentPageName;
@property (nonatomic, retain) NSString *currentPageDirectory;
//- (UIWebView*)webView;
@end

@implementation UIWebViewController
@synthesize currentPageName;// = _currentPageName;
@synthesize currentPageDirectory;// = _currentPageDirectory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[activityView setFrame:CGRectMake(0,0,20,20)];
		activityIndicator = [[UIBarButtonItem alloc] initWithCustomView:activityView];
		
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		webView.delegate = self;
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.webView.autoresizesSubviews = YES;
		self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:webView];
    }
    return self;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[activityView setFrame:CGRectMake(0,0,20,20)];
		activityIndicator = [[UIBarButtonItem alloc] initWithCustomView:activityView];
		
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		webView.delegate = self;
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.webView.autoresizesSubviews = YES;
		self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:webView];
	}
	return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
	[currentPageName release];
	[currentPageDirectory release];
	[activityIndicator release];
	[activityView release];
	[webView release];
	[super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dismissSelf
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Get&Set
- (UIWebView*)webView{
    return webView;
}

#pragma mark - Actions
- (void)loadPageNamed:(NSString*)name inSubdirectory:(NSString*)subdirectory{
#ifdef DEBUG
    NSLog(@"[%@] Loading page named: '%@' in directory: '%@'", NSStringFromClass([self class]), name, subdirectory);
#endif	
    self.currentPageName = name;
    self.currentPageDirectory = subdirectory;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name 
                                                     ofType:@"html" 
                                                inDirectory:subdirectory];
    
    [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}


- (void)loadExternalPage:(NSString*)urlAddress {
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
    [[self webView] loadRequest:requestObj];
}


#pragma mark -
#pragma UIWebView Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
#ifdef DEBUG
	NSLog(@"[UIWebViewController] Load failed: %@", error);
#endif
	if([activityView isAnimating])
	{
		[activityView stopAnimating];
	}
	[self.navigationItem setRightBarButtonItem:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
#ifdef DEBUG
	NSLog(@"[UIWebViewController] Loading %@", [request URL]);
#endif
	if (navigationType == UIWebViewNavigationTypeLinkClicked){
        
        NSURL *url = [request URL];
        NSString *customScheme = @"vilea";
        
        if ([[url scheme] isEqualToString:customScheme]){
            NSString *action = [[[url absoluteString] componentsSeparatedByString:@"/"] lastObject];
			
            if ([self respondsToSelector:NSSelectorFromString(action)]){
                [self performSelector:NSSelectorFromString(action)];
            }
            else
            {
                // try the selector with arguments
                NSLog(@"[%@] ERROR: no method '%@' found", NSStringFromClass([self class]), action);
            }
            return NO;		
        }
        else
        {
            return YES;
        }
	}
	else {
		return YES;
	}
    
}

- (void)webViewDidFinishLoad:(UIWebView *)view
{
	if([activityView isAnimating])
	{
		[activityView stopAnimating];
	}
	[self.navigationItem setRightBarButtonItem:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if(![activityView isAnimating])
	{
		[activityView startAnimating];
	}
	[self.navigationItem setRightBarButtonItem:activityIndicator];
}

@end
