//
//  LAWebViewController.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/21/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAWebViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"

@interface LAWebViewController ()

@end

@implementation LAWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
{
    [_spinner startAnimating];
    return YES;
}

- (void)webViewDidFinishLoading:(UIWebView *)wv
{
    [_spinner stopAnimating];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [_spinner stopAnimating];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navyItem]setTitle:_titleName];
    
    [[self webview]setDelegate:self];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:_url];
    
    [[self webview]loadRequest:requestURL];

    UIButton *alertsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    alertsBtn.frame = CGRectMake(0, 0, 27, 27);
    [alertsBtn setBackgroundImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
    //[alertsBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self navyItem]setRightBarButtonItem:[[UIBarButtonItem alloc]
                                          initWithCustomView:alertsBtn]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:alertsBtn];

    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
}
- (IBAction)back:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
