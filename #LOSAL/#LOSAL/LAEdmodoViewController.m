//
//  LAEdmodoViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/20/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAEdmodoViewController.h"

@interface LAEdmodoViewController ()

@end

@implementation LAEdmodoViewController

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
	[[self edmodoView]setDelegate:self];
    NSURL *url = [NSURL URLWithString:@"https://www.edmodo.com/m]"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [[self edmodoView]loadRequest:requestURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
