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
#import "LAAboutViewController.h"
#import "LAUser.h"
@interface LAMenuViewController ()
#define  DEFAULT_ICON "\uE00C"
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
-(void)receivedUpdateNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    if ([[notification name] isEqualToString:@"updateUserDisplay"])
    {
        NSLog(@"%@",[[[LAStoreManager defaultStore]currentUser]userCategory]);
        if ( [[[[LAStoreManager defaultStore]currentUser]userCategory] isEqualToString:@"Student"])
        {
            NSString * newLastNameString = [[[[LAStoreManager defaultStore]currentUser]lastName] substringWithRange:NSMakeRange(0, 1)];
            NSString *newName = [NSString stringWithFormat:@"%@ %@.", [[[LAStoreManager defaultStore]currentUser]firstName], newLastNameString];
            [_userNameLabel setText:newName];
        }else{
            NSString *newDisplayName = [NSString stringWithFormat:@"%@ %@",[[[LAStoreManager defaultStore]currentUser]prefix], [[[LAStoreManager defaultStore]currentUser]lastName]];
            [_userNameLabel setText:newDisplayName];
        }
        [_userIcon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
        NSLog(@"this is the users's first name: %@", [[[LAStoreManager defaultStore]currentUser]firstName]);
        NSScanner *scanner = [NSScanner scannerWithString:[[[LAStoreManager defaultStore]currentUser]iconString]];
        unsigned int code;
        [scanner scanHexInt:&code];
        [_userIcon setText:[NSString stringWithFormat:@"%C", (unsigned short)code]];
        [_userIcon setTextColor:[[[LAStoreManager defaultStore]currentUser]iconColor]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedUpdateNotification:)
                                                 name:@"updateUserDisplay"
                                               object:nil];

    [[self slidingViewController] setAnchorRightRevealAmount:240.f];
    [[self slidingViewController] setUnderLeftWidthLayout:ECFullWidth];
    //[[self view] setBackgroundColor:[UIColor whiteColor]];
    //[[self view]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [[self tableView]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    //[[self tableView]setSeparatorColor:[UIColor colorWithWhite:0.15f alpha:0.2f]];
    _sitesList = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSURL URLWithString:@"http://m.socrative.com/student/#joinRoom"],@"Socrative",
                  [NSURL URLWithString:@"https://www.edmodo.com/m/"], @"Edmodo",
//                  [NSURL URLWithString:@"webcal://losal.tandemcal.com/index.php?type=export&action=ical&export_type=now_to_infinity&schools=6&activities=15&event_status_types=1&limit=none&date_start=2013-08-28&page=2"] , @"Calendar",
                  [NSURL URLWithString:@"https://abi.losal.org/abi/LoginHome.asp"], @"Aeries Portal",
                  nil];
    // the calendar will ask you if you want to subscribe.
    _menuItems = @[@"Feed", @"Links", @"Aeries Portal",@"Socrative",@"Edmodo",@"About"];
  
    NSLog(@"this is the users's first name: %@", [[[LAStoreManager defaultStore]currentUser]firstName]);

        [_userIcon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
        NSScanner *scanner = [NSScanner scannerWithString:[[[LAStoreManager defaultStore]currentUser]iconString]];
        unsigned int code;
        [scanner scanHexInt:&code];
        [_userIcon setText:[NSString stringWithFormat:@"%C", (unsigned short)code]];
        [_userIcon setTextColor:[[[LAStoreManager defaultStore]currentUser]iconColor]];
    
//        [_userNameLabel setText:@"Non-Verified User"];
//        [_userIcon setText:[NSString stringWithUTF8String:DEFAULT_ICON]];
//        [_userIcon setTextColor:[UIColor whiteColor]];
//    }
        [_userNameLabel setText:[[[LAStoreManager defaultStore]currentUser]displayName]];
    //[_userNameLabel setTextColor:[UIColor whiteColor]];
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
    // this method was intended to change from view to view.
    NSString *cellName = [[self menuItems] objectAtIndex:[indexPath row]];
    UIViewController *anotherTopViewController;
    
    if ([cellName isEqualToString:@"Feed"]) {
        
         anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:cellName];
        
    }else if([cellName isEqualToString:@"Aeries Portal"]){
        NSString *identifier = @"WebView";
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

    } else if([cellName isEqualToString:@"Socrative"]){
        NSString *identifier = @"WebView";
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if([cellName isEqualToString:@"Edmodo"]){
        NSString *identifier = @"WebView";
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else if([cellName isEqualToString:@"About"]){
        
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:cellName];
        
    } else{
        anotherTopViewController = [[self storyboard]instantiateViewControllerWithIdentifier:cellName];
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = anotherTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}
- (IBAction)toSite:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://www.losal.org/lahs"]];

}
@end