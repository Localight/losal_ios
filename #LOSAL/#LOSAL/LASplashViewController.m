//
//  LASplashViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASplashViewController.h"


//@interface LASplashViewController ()
//
//@end

@implementation LASplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Feed"];
    // this tells the splash screen which view to load after the app has loaded.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
