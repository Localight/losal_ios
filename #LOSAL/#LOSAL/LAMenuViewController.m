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
@property (nonatomic, strong) NSDictionary *sitesList;
//@property (nonatomic, strong) LAUser *user;
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
- (void)viewWillAppear:(BOOL)animated
{
//    [super viewWillAppear:animated];
//    PFUser *currentUser = [PFUser currentUser];
//    
//    [_userNameLabel setText:[NSString stringWithFormat:@"%@", [currentUser username]]];
//    [_userNameLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:17]];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [[self slidingViewController] setAnchorRightRevealAmount:240.f];
    [[self slidingViewController] setUnderLeftWidthLayout:ECFullWidth];
    //[[self view] setBackgroundColor:[UIColor whiteColor]];
    //[[self view]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [[self tableView]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    //[[self tableView]setSeparatorColor:[UIColor colorWithWhite:0.15f alpha:0.2f]];
    _sitesList = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSURL URLWithString:@"http://m.socrative.com/student/#joinRoom"],@"Socrative",
                  [NSURL URLWithString:@"https://www.edmodo.com/m/"], @"Edmodo",
                  [NSURL URLWithString:@"webcal://losal.tandemcal.com/index.php?type=export&action=ical&export_type=now_to_infinity&schools=6&activities=15&event_status_types=1&limit=none&date_start=2013-08-28&page=2"] , @"Calendar",
                  [NSURL URLWithString:@"https://abi.losal.org/abi/LoginHome.asp"], @"Aeries Portal",
                  nil];
    // the calendar will ask you if you want to subscribe.
    _menuItems = @[@"Feed",@"Calendar",@"Aeries Portal",@"Socrative",@"Edmodo",@"About"];
  
    [_userIcon setFont:[UIFont fontWithName:@"iconmoon" size:30.0f]];
    
    // Set up users icon
//    [cell.icon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
//    
//    if ([postItem.postUser.icon length] > 0) {
//        NSScanner *scanner = [NSScanner scannerWithString:postItem.postUser.icon];
//        unsigned int code;
//        [scanner scanHexInt:&code];
//        cell.icon.text  = [NSString stringWithFormat:@"%C", (unsigned short)code];
//        [cell.icon setTextColor:[self colorFromHexString:postItem.postUser.iconColor]];
//    } else {
//        cell.icon.text = [NSString stringWithUTF8String:DEFAULT_ICON];
//        [cell.icon setTextColor:[UIColor whiteColor]];
//    }
    

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

- (IBAction)toSite:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://www.losal.org/lahs"]];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this method was intended to change from view to view.
    NSString *cellName = [[self menuItems] objectAtIndex:[indexPath row]];
    UIViewController *anotherTopViewController;
    
    if (!([cellName isEqualToString:@"Feed"]))//||[cellName isEqualToString:@"Logout"]
    {
        NSString *identifier = @"WebView";
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else if([cellName isEqualToString:@"Feed"]){
        
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:cellName];
        
    } else {
        //[[LAStoreManager sharedManager]logout];
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = anotherTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}
@end