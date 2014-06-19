//  Copyright 2011 Vilea GmbH. All rights reserved.
//

#import "UIWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FlipsideViewController.h"

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
	[super dealloc];
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
	UIWebView* webview = [[UIWebView alloc] init];
	webview.delegate = self;
    self.view = webview;
	[webview release];
    self.view.autoresizesSubviews = YES;
    self.view.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self webView] setDelegate:self];	
    
    //Disable web view bounce
    [(UIScrollView*)[[[self webView] subviews] objectAtIndex:0] setBounces:NO];
}

- (void)viewDidUnload
{
    [[self webView] setDelegate:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return NO;
}

#pragma mark -
#pragma mark Get&Set
- (UIWebView*)webView{
    if (!webView){
        webView = (UIWebView*)self.view;
    }
    return webView;
}

#pragma mark -
#pragma mark Actions
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

#pragma -
#pragma Actions
- (void)showFlipSide{
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
}

#pragma -
#pragma FlipSideViewDelegateProtocol
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller{
    [self dismissModalViewControllerAnimated:YES];
}

@end
