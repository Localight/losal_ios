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
#import "LAUser.h"

@interface LAMenuViewController ()

#define DEFAULT_ICON "\uE00C"

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) LAStoreManager *storeManager;
@property (nonatomic, strong) NSDictionary *sitesList;

@property (nonatomic, weak) IBOutlet UILabel *userIcon;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@end

@implementation LAMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)receivedUpdateNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"updateUserDisplay"]) {
        if ( [[[[LAStoreManager defaultStore]currentUser]userCategory] isEqualToString:@"Student"]) {
            NSString * newLastNameString = [[[[LAStoreManager defaultStore]currentUser]lastName] substringWithRange:NSMakeRange(0, 1)];
            NSString *newName = [NSString stringWithFormat:@"%@ %@.", [[[LAStoreManager defaultStore]currentUser]firstName], newLastNameString];
            [self.userNameLabel setText:newName];
            [self.userNameLabel setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:24]];
        }
        else {
            NSString *newDisplayName = [NSString stringWithFormat:@"%@ %@",[[[LAStoreManager defaultStore]currentUser]prefix], [[[LAStoreManager defaultStore]currentUser]lastName]];
            [self.userNameLabel setText:newDisplayName];
            [self.userNameLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:24]];
        }
        
        [self.userIcon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
        
        NSScanner *scanner = [NSScanner scannerWithString:[[[LAStoreManager defaultStore]currentUser]iconString]];
        unsigned int code;
        [scanner scanHexInt:&code];
        [self.userIcon setText:[NSString stringWithFormat:@"%C", (unsigned short)code]];
        [self.userIcon setTextColor:[[[LAStoreManager defaultStore]currentUser]iconColor]];
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

    [[self tableView]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];

    _sitesList = @{
                   @"Socrative": [NSURL URLWithString:@"http://m.socrative.com/student/#joinRoom"],
                   @"Edmodo": [NSURL URLWithString:@"https://www.edmodo.com/m/"],
                   @"Calendar": [NSURL URLWithString:@"http://losal.tandemcal.com/"],
                   @"Grades": [NSURL URLWithString:@"https://abi.losal.org/abi/LoginHome.asp"]
                   };

    _menuItems = @[@"Feed", @"Links", @"Grades", @"Calendar", @"Socrative", @"Edmodo", @"About"];
  
    [self.userNameLabel setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:24]];
    [self.userIcon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
    
    NSScanner *scanner = [NSScanner scannerWithString:[[[LAStoreManager defaultStore]currentUser]iconString]];
    unsigned int code;
    [scanner scanHexInt:&code];
    [self.userIcon setText:[NSString stringWithFormat:@"%C", (unsigned short)code]];
    [self.userIcon setTextColor:[[[LAStoreManager defaultStore]currentUser]iconColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [[self menuItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [[self menuItems] objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:20]];
    [[cell textLabel] setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
}

- (void)openView:(NSString *)uid
{
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:uid];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this method was intended to change from view to view.
    NSString *cellName = [[self menuItems] objectAtIndex:[indexPath row]];
    UIViewController *anotherTopViewController;
    
    if ([cellName isEqualToString:@"Feed"]) {
         anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:cellName];
    }
    else if ([cellName isEqualToString:@"Grades"]) {
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([cellName isEqualToString:@"Calendar"]) {
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([cellName isEqualToString:@"Socrative"]) {
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([cellName isEqualToString:@"Edmodo"]) {
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        
        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
        
        [webView setTitleName:cellName];
        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([cellName isEqualToString:@"About"]) {
        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:cellName];
    }
    else {
        // call method that would grab data from parse and fill mainpost items.
        anotherTopViewController = [[self storyboard]instantiateViewControllerWithIdentifier:cellName];
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = anotherTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (IBAction)toSite:(id)sender
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://www.losal.org/lahs"]];
}

@end