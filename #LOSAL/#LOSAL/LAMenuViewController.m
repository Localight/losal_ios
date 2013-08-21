//
//  LAMenuViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAMenuViewController.h"
#import "LAStoreManager.h"
#import "ECSlidingViewController.h"
#import "LAWebViewController.h"

@interface LAMenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) LAStoreManager *storeManager;
//@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation LAMenuViewController

//- (void)awakeFromNib
//{
//    
//    self.menuItems = [NSArray arrayWithObjects:@"Feed", @"Alerts", nil];
//}

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
	
    [[self slidingViewController] setAnchorRightRevealAmount:180.f];
    [[self slidingViewController] setUnderLeftWidthLayout:ECFullWidth];
    //[[self view] setBackgroundColor:[UIColor whiteColor]];
    [[self view]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [[self tableView]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [[self tableView]setSeparatorColor:[UIColor colorWithWhite:0.15f alpha:0.2f]];

    _menuItems = @[@"Feed", @"Alerts", @"WebView", @"Schedule",@"Socrative",@"Edmodo",@"Events",@"Grades",@"Logout"];
    
    //self.storeManager = [LAStoreManager sharedManager];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [[self menuItems]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [[self menuItems] objectAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    [[cell textLabel]setFont:[UIFont fontWithName:@"Roboto-Regular" size:20]];
    [[cell textLabel]setBackgroundColor:[UIColor whiteColor]];
    
    //cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    
    return cell;
   }
-(void)openView:(NSString *)uid{
    
    NSString *identifier = uid;
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
    
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    // If this is the logout cell, then logout and redisplay Feed view
    if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"Logout"])
    {
        [[LAStoreManager sharedManager]logout];
        identifier = [NSString stringWithFormat:@"Feed"];
    } else {
        identifier = [NSString stringWithFormat:@"%@", [self.menuItems objectAtIndex:indexPath.row]];
    }
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    if ([identifier isEqualToString:@"WebView"]) {
        LAWebViewController *webView = (LAWebViewController *)newTopViewController;
        webView.url = [NSURL URLWithString:@"http://losal.tandemcal.com"];
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end