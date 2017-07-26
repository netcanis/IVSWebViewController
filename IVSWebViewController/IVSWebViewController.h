//
//  IVSWebViewController.h
//  Pods
//
//  Created by Sung Hwan Cho on 18/07/2017.
//
//

#import <UIKit/UIKit.h>

@interface IVSWebViewController : UIViewController

@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL statusBarOverlapping;

- (void)loadURL:(NSURL *)URL;
- (void)loadURLString:(NSString *)urlString;
- (void)loadHTMLFile:(NSString *)fileName;
- (void)loadHTMLString:(NSString *)htmlContent;

@end
