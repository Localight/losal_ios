//
//  LAAlertsViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/7/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAAlertsViewController.h"

#import "LAStoreManager.h"

@interface LAAlertsViewController ()
{
     NSMutableArray *_objects;
}

@property (strong, nonatomic) LAStoreManager *storeManager;
@end

@implementation LAAlertsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(revealMenu:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAAlertsViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Alerts"];
    }
    
    // This was messing up the scrolling in the UI table view so need to figure out a way to add this back - Joaquin
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
