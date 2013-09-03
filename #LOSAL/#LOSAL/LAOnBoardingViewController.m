//
//  LAOnBoardingViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 9/2/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAOnBoardingViewController.h"
#import "LAOnBoardingChildViewController.h"
@interface LAOnBoardingViewController ()

@end

@implementation LAOnBoardingViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(LAOnBoardingChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(LAOnBoardingChildViewController *)viewController index];
    
    index++;
    
    if (index == 5) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (LAOnBoardingChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    LAOnBoardingChildViewController *childViewController = [[LAOnBoardingChildViewController alloc] initWithNibName:@"APPChildViewController" bundle:nil];
    childViewController.index = index;
    
    return childViewController;
}
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}
@end
