//
//  LASocrativeViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/20/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASocrativeViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"
@interface LASocrativeViewController ()

@end

@implementation LASocrativeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)back:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self socrativeView]setDelegate:self];
    NSURL *url = [NSURL URLWithString:@"http://m.socrative.com/"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [[self socrativeView]loadRequest:requestURL];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
