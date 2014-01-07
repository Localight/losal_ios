//
//  LAAboutViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/28/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAAboutViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"
#import "LANoticeViewController.h"

@interface LAAboutViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navyItem;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LAAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)revealNotices:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

- (void)back:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navyItem] setTitle:@"More Options"];
    
    // TODO: use Roboto Regular/Bold for HTML text?
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 30, 30);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [_navyItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:menuBtn]];
    
    UIButton *noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noticeBtn.frame = CGRectMake(0, 0, 27, 27);
    [noticeBtn setBackgroundImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
    [noticeBtn addTarget:self action:@selector(revealNotices:) forControlEvents:UIControlEventTouchUpInside];
    
    [_navyItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:noticeBtn]];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]])
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[LANoticeViewController class]])
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Notices"];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"MoreOptions" ofType:@"html" ]]];
	
	[self.webView loadRequest:req];
}

#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // open the links outside of the app
	NSURL *loadURL = [request URL];

    return !(([[loadURL scheme] isEqualToString: @"http"] || [[loadURL scheme] isEqualToString: @"mailto"])
    && (navigationType == UIWebViewNavigationTypeLinkClicked)) || ![[UIApplication sharedApplication] openURL:loadURL];
}

@end
