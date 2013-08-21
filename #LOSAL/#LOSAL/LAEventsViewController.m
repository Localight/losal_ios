//
//  LAEventsViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/20/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAEventsViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"
@interface LAEventsViewController ()

@end

@implementation LAEventsViewController

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
	[[self eventsView]setDelegate:self];
    NSURL *url = [NSURL URLWithString:@"http://losal.tandemcal.com"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [[self eventsView]loadRequest:requestURL];
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
