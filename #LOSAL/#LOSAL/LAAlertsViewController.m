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
	// Do any additional setup after loading the view, typically from a nib.
    
    //grabbing left bar button from libary
    //    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    menuBtn.frame = CGRectMake(10, 10, 30, 21);
    //    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menuBtn.png"] forState:UIControlStateNormal];
    //    [menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(revealMenu:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
    
    //    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //    self.navigationItem.rightBarButtonItem = addButton;
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    // This was messing up the scrolling in the UI table view so need to figure out a way to add this back - Joaquin
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    [self fetchEntries];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fetchEntries
{
    
    UIView *currentTitleView = [[self navigationItem] titleView];
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[self navigationItem] setTitleView:aiView];
    
    [aiView startAnimating];
    
    // This is where you populate the table with data
    self.storeManager = [LAStoreManager sharedManager];
    
    [[self navigationItem] setTitleView:currentTitleView];
    
    [self.storeManager getFeedWithCompletion:^(NSArray *alertMessages, NSError *error)
     {
         NSLog(@"Completion block called!");
         if (!error)
         {
             _objects = [NSMutableArray arrayWithArray:alertMessages];
             [[self tableView] reloadData];
             NSLog(@"error is %@", error);
             
         } else {
             // If things went bad, show an alert view
             NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@",
                                      [error localizedDescription]];
             
             // Create and show an alert view with this error displayed
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:errorString
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
             [av show];
             // If you come here you got the array
             NSLog(@"results are %@", alertMessages);
         }
     }];
    
    
}

@end
