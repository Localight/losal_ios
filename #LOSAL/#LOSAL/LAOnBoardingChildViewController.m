//
//  LAOnBoardingChildViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 9/2/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAOnBoardingChildViewController.h"

@interface LAOnBoardingChildViewController ()

@end

@implementation LAOnBoardingChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%d", self.index];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
