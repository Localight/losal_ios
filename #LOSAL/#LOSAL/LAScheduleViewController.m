//
//  LAScheduleViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/20/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAScheduleViewController.h"

@interface LAScheduleViewController ()

@end

@implementation LAScheduleViewController

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
    [[self scheduleView]setDelegate:self];
    NSURL *url = [NSURL URLWithString:@"https://demo.aeries.net/ParentPortal/m/parents?demo=True&user=parent%40aeries.com&pwd=1234"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [[self scheduleView]loadRequest:requestURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
