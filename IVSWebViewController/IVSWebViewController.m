//
//  IVSWebViewController.m
//  Pods
//
//  Created by netcanis on 18/07/2017.
//
//

#import "IVSWebViewController.h"
#import <WebKit/WebKit.h>


@interface IVSWebViewController ()
<
 WKNavigationDelegate
,WKUIDelegate
,WKScriptMessageHandler
,UIAlertViewDelegate
,UIScrollViewDelegate
>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end


@implementation IVSWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Hiding top bar of navigation controller
    if (nil != self.navigationController && YES == self.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    if (NO == self.statusBarHidden && NO == self.navigationBarHidden && NO == self.statusBarOverlapping) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
        [statusBarBackground setBackgroundColor:[UIColor colorWithRed:0.90 green:0.89 blue:0.90 alpha:1.00]];
        statusBarBackground.tag = 13;
        [self.navigationController.view addSubview:statusBarBackground];
        [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
    }
    
    [self createRefreshControl];
}

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

- (void)viewWillLayoutSubviews
{
    if (NO == self.statusBarHidden && NO == self.navigationBarHidden && NO == self.statusBarOverlapping) {
        self.view.clipsToBounds = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = 0.0;
        UIDeviceOrientation statusBarOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        if(UIDeviceOrientationIsPortrait(statusBarOrientation))
            screenHeight = screenRect.size.height;
        else
            screenHeight = screenRect.size.width;
        CGRect screenFrame = CGRectMake(0, 20, self.view.frame.size.width,screenHeight-20);
        CGRect viewFr = [self.view convertRect:self.view.frame toView:nil];
        if (!CGRectEqualToRect(screenFrame, viewFr))
        {
            self.view.frame = screenFrame;
            self.view.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (nil != self.navigationController) {
        [self.navigationController.navigationBar addSubview:self.progressView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    if (nil != self.progressView) {
        [self.progressView removeFromSuperview];
    }
}

- (void)dealloc
{
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
    if ([self isViewLoaded]) {
        [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
}



/*
 #pragma mark -
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark -
#pragma mark - User Functions

- (void)loadURL:(NSURL *)URL
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    [self loadURL:url];
}

- (void)loadHTMLFile:(NSString *)fileName
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"" inDirectory:@"www"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    [self loadURL:url];
}

- (void)loadHTMLString:(NSString *)htmlContent
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:htmlContent baseURL:baseURL];
}


#pragma mark -
#pragma mark - WKWebView

- (WKWebView *)webView
{
    if (nil == _webView) {
        _webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:self.configuration];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:NULL];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.multipleTouchEnabled = YES;
        _webView.autoresizesSubviews = YES;
        _webView.scrollView.alwaysBounceVertical = YES;
        
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (WKWebViewConfiguration *)configuration
{
    if (!_configuration) {
        _configuration = [[WKWebViewConfiguration alloc]init];
        _configuration.allowsInlineMediaPlayback = YES;
        _configuration.allowsPictureInPictureMediaPlayback = YES;
        _configuration.dataDetectorTypes = UIDataDetectorTypeAll;
        _configuration.requiresUserActionForMediaPlayback = NO;
        
        // ex) window.webkit.messageHandlers.[appId].postMessage({"message":"Hello there"});
        NSString *appId = [[NSBundle mainBundle] bundleIdentifier];
        [_configuration.userContentController addScriptMessageHandler:self name:appId];
    }
    return _configuration;
}


#pragma mark -
#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *sentData = (NSDictionary *)message.body;
    NSLog(@"%@", sentData);
    NSString *messageString = sentData[@"message"];
    NSLog(@"Message received: %@", messageString);
}


#pragma mark -
#pragma mark - UIProgressView

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _progressView.trackTintColor = [UIColor whiteColor];
        _progressView.progressTintColor = [UIColor lightGrayColor];
        _progressView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, _progressView.frame.size.height);
    }
    return _progressView;
}


#pragma mark -
#pragma mark - Key,Value Observer Event

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    WKWebView *webView = (WKWebView *)object;
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:webView.estimatedProgress animated:animated];
        
        if(webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = webView.title;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)closeAction
{
    WKBackForwardList *backForwardList = self.webView.backForwardList;
    if (backForwardList.backList.count > 0) {
        WKBackForwardListItem *item = [backForwardList itemAtIndex:-1];
        NSLog(@"%@ ----- %@",item.title,item.URL);
        [self.webView goToBackForwardListItem:item];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
    NSURL *URL = navigationAction.request.URL;
    NSLog(@"%@", URL.absoluteString);
    
    
    if([URL.absoluteString isEqualToString:@""] || [URL.absoluteString isEqualToString:@"about:blank"])
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    
    if(NO == [self externalAppRequiredToOpenURL:URL])
    {
        if(nil == navigationAction.targetFrame) {
            [self loadURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    else if(YES == [[UIApplication sharedApplication] canOpenURL:URL])
    {
        [[UIApplication sharedApplication] openURL:URL];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


#pragma mark -
#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (NO == navigationAction.targetFrame.isMainFrame) {
        [self createNewWebview:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alert.textFields[0].text);
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark -
#pragma mark - Pull to refresh

- (void)createRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.webView.scrollView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTable
{
    [self.refreshControl endRefreshing];
    [self.webView reload];
}


#pragma mark -
#pragma mark - window.open()

- (WKWebView *)createNewWebview:(NSURLRequest *)request
{
    // Create new WKWebView
    WKWebView *newWebView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:self.configuration];
    newWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [newWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:NULL];
    [newWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    newWebView.navigationDelegate = self;
    newWebView.UIDelegate = self;
    newWebView.multipleTouchEnabled = YES;
    newWebView.autoresizesSubviews = YES;
    newWebView.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:newWebView];
    [newWebView loadRequest:request];
    
    
    // Create close button
    CGFloat btnSize = 24.0f;
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 20, btnSize, btnSize);
    closeBtn.layer.cornerRadius = btnSize / 2.0f;
    closeBtn.layer.borderWidth = 1;
    closeBtn.layer.borderColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0].CGColor;
    [closeBtn setTitleColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [newWebView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    return newWebView;
}

- (void)webViewDidClose:(WKWebView *)webView
{
    [webView setNavigationDelegate:nil];
    [webView setUIDelegate:nil];
    if ([self isViewLoaded]) {
        [webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
        [webView removeObserver:self forKeyPath:@"title"];
    }
    [webView removeFromSuperview];
}

-(void)onDone:(id)sender
{
    UIButton *button = (UIButton *)sender;
    WKWebView *newWebView = (WKWebView *)button.superview;
    
    if (nil != newWebView) {
        [newWebView setNavigationDelegate:nil];
        [newWebView setUIDelegate:nil];
        if ([self isViewLoaded]) {
            [newWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
            [newWebView removeObserver:self forKeyPath:@"title"];
        }
        [newWebView removeFromSuperview];
    }
}


#pragma mark -
#pragma mark - util

- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL
{
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https"]];
    return ![validSchemes containsObject:URL.scheme];
}

- (BOOL)isModal
{
    if([self presentingViewController])
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    return NO;
}

@end
