//
//  LAMenuViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAMenuViewController.h"
#import "LAStoreManager.h"
#import "LAMenuCell.h"
#import "LAImage+Color.h"
@interface LAMenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) LAStoreManager *storeManager;
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
    [[self slidingViewController] setAnchorRightRevealAmount:150.f];
    [[self slidingViewController] setUnderLeftWidthLayout:ECFullWidth];
    //[[self view] setBackgroundColor:[UIColor whiteColor]];
    
    self.menuItems = [NSArray arrayWithObjects:@"Feed", @"Alerts",@"Events",@"Grades",@"Schedule",@"Socrative",@"Edmodo", @"Logout", nil];
    
    self.storeManager = [LAStoreManager sharedManager];
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:self.storeManager.settings.backgroundImage];
    //[backgroundImage setAlpha:.50f];
    [[self tableView]setBackgroundColor:[UIColor darkGrayColor]];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [[self menuItems]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"menuCell";
    
    LAMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[LAMenuCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    [[cell menuLabels]setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    
    UIImage *coloredImage = [[UIImage imageNamed:@"Mustache"] imageWithOverlayColor:[UIColor redColor]];
    [[cell menuIcons]setImage:coloredImage];
    [[cell menuLabels]setText:[self.menuItems objectAtIndex:[indexPath row]]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    // If this is the logout cell, then logout and redisplay Feed view
    if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"Logout"]) {
        [self.storeManager logout];
        identifier = [NSString stringWithFormat:@"Feed"];
    } else {
        identifier = [NSString stringWithFormat:@"%@", [[self menuItems] objectAtIndex:[indexPath row]]];
    }
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end