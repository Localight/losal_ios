//
//  LASplashViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASplashViewController.h"

@interface LASplashViewController ()

@end

@implementation LASplashViewController

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
	
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Feed"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
