//
//  IVSWebViewController.h
//  Pods
//
//  Created by Sung Hwan Cho on 18/07/2017.
//
//

#import <UIKit/UIKit.h>

@interface IVSWebViewController : UIViewController


- (void)loadURL:(NSURL *)URL;
- (void)loadURLString:(NSString *)urlString;
- (void)loadHTMLFile:(NSString *)fileName;
- (void)loadHTMLString:(NSString *)htmlContent;

@end
