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
#import "LAStoreManager.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

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
    
    [[self navyItem]setTitle:@"More Options"];
    
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
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[LANoticeViewController class]]) {
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Notices"];
    }
    
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"MoreOptions" ofType:@"html" ]]];
	
	[self.webView loadRequest:req];
}

// TODO: create an entry UI point for this
- (IBAction)ReVerify:(id)sender{
    //PFUser *currentUser = [PFUser currentUser];
    // if user wants to enter phone number
    if (![[[LAStoreManager defaultStore]currentUser]userVerified])// if the user is not logged in.
    {
        UIAlertView *prompt = [[UIAlertView alloc]initWithTitle:@"Request for Text Message"
                                                        message:@"Would you like to re-enter your phone number and have the text message sent to you again? Please enter your phone number below or click NO to leave this screen."
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        
        [prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        [myTextField setBackgroundColor:[UIColor whiteColor]];
        [prompt addSubview:myTextField];
        CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
        [prompt setTransform:myTransform];
        [prompt show];
  
        [[LAStoreManager defaultStore]sendRegistrationRequestForPhoneNumber:[myTextField text]];

        
        //        // show the signup or login scren
        //        UIAlertView *prompt = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"You are already Validated. Would you like to reValidate and the text message send agai?" delegate:nil cancelButtonTitle:@"Yes" otherButtonTitles:"No", ];
    } else {
        UIAlertView *prompt = [[UIAlertView alloc]initWithTitle:@"Oops!"
                                                        message:@"It looks like you are already Verified and logged In."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [prompt show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *number = [[alertView textFieldAtIndex:0]text];
    NSLog(@"%@",number);
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin"
                                                                            accessGroup:nil];
    
    [keychainItem setObject:number forKey:(__bridge id)kSecValueData];
    
    [[LAStoreManager defaultStore]sendRegistrationRequestForPhoneNumber:[keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]];
        // name contains the entered value
}

#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // open the links outside of the app
	NSURL *loadURL = [request URL];
	if (([[loadURL scheme] isEqualToString: @"http"] || [[loadURL scheme] isEqualToString: @"mailto"])
		&& (navigationType == UIWebViewNavigationTypeLinkClicked)) {
		return ![[UIApplication sharedApplication] openURL:loadURL];
	}
    
    // intercept the re-verify link to handle in Objective-C native code, don't allow the URL request to start
    if ([[loadURL scheme] isEqualToString:@"localism"]) {
        [self ReVerify:nil];
        return NO;
    }
    
	return YES;
}

@end
