//
//  IVSViewController.m
//  IVSWebViewController
//
//  Created by netcanis on 07/18/2017.
//  Copyright (c) 2017 netcanis. All rights reserved.
//

#import "IVSViewController.h"
#import <IVSWebViewController/IVSWebViewController.h>


@interface IVSViewController ()

@end

@implementation IVSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onOpenWebSite
{
    NSLog(@"");
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //IVSWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IVSWebViewController"];
    
    IVSWebViewController *vc = [[IVSWebViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc loadURLString:@"https://www.google.com"];
    vc.FIX_STATUSBAR_OVERLAPPING = YES;
    [self presentViewController:navi animated:YES completion:nil];
}

@end
