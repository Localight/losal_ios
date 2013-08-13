//
//  LASocialAccessViewController.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/13/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASocialAccessViewController.h"
#import "LAAppDelegate.h"

@interface LASocialAccessViewController ()

@property (strong, nonatomic) LAAppDelegate* appDelegate;

-(IBAction)igLogin:(id)sender;

@end

@implementation LASocialAccessViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.appDelegate = (LAAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    self.appDelegate.instagram.sessionDelegate = self;
    if ([self.appDelegate.instagram isSessionValid]) {
        //IGListViewController* viewController = [[IGListViewController alloc] init];
        //[self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self.appDelegate.instagram authorize:[NSArray arrayWithObjects:@"likes", nil]];
    }
}

-(IBAction)igLogin:(id)sender {
    self.appDelegate = (LAAppDelegate*)[UIApplication sharedApplication].delegate;
    [self.appDelegate.instagram authorize:[NSArray arrayWithObjects:@"likes", nil]];
}

#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    // here i can store accessToken
    [[NSUserDefaults standardUserDefaults] setObject:self.appDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self", @"method", nil];
    [self.appDelegate.instagram requestWithParams:params
                                    delegate:self];
    
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSLog(@"Instagram did load: %@", result);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
