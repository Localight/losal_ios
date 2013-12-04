
//
//  LAFeedViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAFeedViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"
#import "LANoticeViewController.h"
#import "LAStoreManager.h"
#import "LAImageLoader.h"
#import "LAPostCell.h"
#import "LAImage+Color.h"
#import "NSDate-Utilities.h"
#import "LASocialNetworksView.h"
#import "LALikesStore.h"
#import "LACalendarSyncView.h"

@interface LAFeedViewController ()

#define DEFAULT_ICON "\uE017"

@property (strong, nonatomic) LASocialManager *socialManager;
@property (strong, nonatomic) LAImageLoader *imageLoader;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSString *currentHashtagFilter;

@end

@implementation LAFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[LAStoreManager defaultStore] fetchFromDate:nil matchingHashtagFilter:nil];
    [[LAStoreManager defaultStore] getHashTags];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstTimeLaunchedKey"]) {
        [self performSegueWithIdentifier:@"kIntroductionSegue" sender:self];
        UIStoryboard *storyboard = [UIApplication sharedApplication].delegate.window.rootViewController.storyboard;
        
        UIViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
        
        [self presentViewController:loginController animated:YES
                         completion:^{
                             NSLog(@"showing login view");
                         }];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstTimeLaunchedKey"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else {
        [[LAStoreManager defaultStore]loginWithPhoneNumber];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedReloadNotification:)
                                                 name:@"Reload"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissLogin:)
                                                 name:@"didDismissLogin"
                                               object:nil];
    
    // Set up splash to dimmed background animation

    self.socialManager = [LASocialManager sharedManager];
    self.socialManager.delegate = self;
    self.imageLoader = [LAImageLoader sharedManager];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 30, 30);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self
                action:@selector(revealMenu:)
      forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithCustomView:menuBtn];
    UIButton *noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noticeBtn.frame = CGRectMake(0, 0, 27, 27);
    [noticeBtn setBackgroundImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
    [noticeBtn addTarget:self
                  action:@selector(revealNotices:)
        forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:noticeBtn];

    UIView *titleViewContainer = [[UIView alloc] initWithFrame:CGRectMake(80, 0, 160, 44)];
    titleViewContainer.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 1, 110, 40)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"LOSAL";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont fontWithName:@"RobotoSlab-Regular" size:24];
    titleLabel.textColor = [UIColor whiteColor];
    
    UIImageView *selectorImage = [[UIImageView alloc] initWithFrame:CGRectMake(29, 14, 20, 20)];
    [selectorImage setImage:[UIImage imageNamed:@"hashfilter"]];
    
    [titleViewContainer addSubview:titleLabel];
    [titleViewContainer addSubview:selectorImage];
    
    UITapGestureRecognizer *titleGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTap:)];
    [titleViewContainer addGestureRecognizer:titleGR];
    
    self.navigationItem.titleView = titleViewContainer;

    [[[self view]layer] setShadowOpacity:0.75f];
    [[[self view]layer] setShadowRadius:0.75f];
    [[[self view]layer] setShadowColor:(__bridge CGColorRef)([UIColor blackColor])];
    
    NSString *imageLight;
    NSString *imageDark;
    
    if (self.view.frame.size.height > 480) {
        imageLight = @"griffin-dance-bg-1";
        imageDark = @"dark-griffin-dance-bg-1";
    } else {
        imageLight = @"griffin-dance-bg-2";
        imageDark = @"dark-griffin-dance-bg-2";
    }
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageLight]];
    [[self tableView]setBackgroundView:backgroundImage];
    
    [UIView animateWithDuration:1.0f animations:^{
        [[self tableView] setBackgroundColor:[UIColor blackColor]];
        [backgroundImage setAlpha:0.3f];
    } completion:^(BOOL finished){
        [backgroundImage setImage:[UIImage imageNamed:imageDark]];
        [backgroundImage setAlpha:1.0f];
    }];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]])
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[LANoticeViewController class]]) {
        LANoticeViewController *noticeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Notices"];
        noticeVC.delegate = self;
        
        self.slidingViewController.underRightViewController = noticeVC;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)revealNotices:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

- (IBAction)titleTap:(id) sender
{
    if (!self.actionSheet) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Filter by Hashtag"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
        
        [self.actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
        
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        [self.actionSheet addSubview:pickerView];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 7.0f, 50.0f, 30.0f)];
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeThisActionSheet) forControlEvents:UIControlEventTouchUpInside];
        
        [self.actionSheet addSubview:closeButton];
    }
    
    [self.actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (void)closeThisActionSheet
{
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)dismissActionSheet:(id)sender
{
    UIActionSheet *actionSheet =  (UIActionSheet *)[(UIView *)sender superview];
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)receivedReloadNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"Reload"])
        [[self tableView]reloadData];
}

- (void)didDismissLogin:(NSNotification *)notification
{
    // if we haven't presented the calendar sync option before, do so now
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"presentedCalendarSync"]) {
        BOOL loginSuccess = ([[[LAStoreManager defaultStore] currentUser] userVerified]);
        
        LACalendarSyncView *calendarSyncView = [[LACalendarSyncView alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width - 40, 340)
                                                                            loginSuccess:loginSuccess];
        [self.navigationController.view addSubview:calendarSyncView];
        [calendarSyncView show];
        
        // mark it such that this view won't be displayed again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"presentedCalendarSync"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[LAStoreManager defaultStore]clearAllMainPostItems];
    [[[LAStoreManager defaultStore]currentUser]setIsFilteredArray:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[[LAStoreManager defaultStore]allMainPostItems]count] > 0)
        return 1;

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LAStoreManager defaultStore]allMainPostItems]count] + 1;
}

- (UITableViewCell *)configureCell:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"postCell";
    LAPostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[LAPostCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                 reuseIdentifier:cellIdentifier];
    
    // this sets up the image if an image is present
    
    LAPostItem *postItem = [[[LAStoreManager defaultStore]allMainPostItems]objectAtIndex:[indexPath row]];
    
    if (![[postItem imageURLString]length] == 0) {
        // Set image to nil, in case the cell was reused.
        [cell.postImage setImage:nil];
        [self.imageLoader processImageDataWithURLString:postItem.imageURLString
                                                  forId:postItem.postObject.objectId
                                               andBlock:^(UIImage *image) {
             if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                 [[cell postImage]setImage:image];
                 [[cell messageArea]setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-iphone4"]]];
             }}];
    }
    else {
        [[cell postImage]setImage:nil];
        
        // ensure no gradient image appears on the no-image tweet
        [cell.messageArea setBackgroundColor:[UIColor clearColor]];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:[postItem iconString]];
    unsigned int code;
    [scanner scanHexInt:&code];
    [[cell icon]setText:[NSString stringWithFormat:@"%C",(unsigned short)code]];
    [[cell icon]setTextColor:[postItem userColorChoice]];
    [[cell icon]setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];

    // TODO: create NSUserdefaults?
    [[cell userNameLabel]setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [[cell messageArea] setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    [[cell dateAndGradeLabel] setFont:[UIFont fontWithName:@"Roboto-Light" size:11]];
    
    UIImage *ago = [[UIImage imageNamed:@"clock"]imageWithOverlayColor:[UIColor whiteColor]];
    [[cell timeImage] setImage:ago];
    
    // TODO: convert this date formatter to static usage
    NSDate *timePosted = [postItem postTime];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

    [[cell messageArea] setText:[postItem text]];
    [[cell messageArea] setTextColor:[UIColor whiteColor]];
    
    // set up the icons for users of type students
    if ([postItem userFirstName] == nil) {
        [[cell userNameLabel]setText:@"Unknown"];
        [[cell userNameLabel]setTextColor:[UIColor whiteColor]];
        [[cell icon]setText:@DEFAULT_ICON];
        [[cell icon]setTextColor:[UIColor whiteColor]];
        [[cell dateAndGradeLabel] setText:[NSString stringWithFormat:@"%@", [self fuzzyTime:[df stringFromDate:timePosted]]]];
    }
    else if ([[postItem userCategory]isEqualToString:@"Student"]) {
        NSString * newLastNameString = [[postItem userLastName] substringWithRange:NSMakeRange(0, 1)];
        NSString *newName = [NSString stringWithFormat:@"%@ %@.", [postItem userFirstName], newLastNameString];
        [[cell userNameLabel]setText:newName];
        [[cell dateAndGradeLabel]setText:[NSString stringWithFormat:@"%@ | %@", [self fuzzyTime:[df stringFromDate:timePosted]], [postItem gradeLevel]]];
    }
    else {
        NSString *newDisplayName = [NSString stringWithFormat:@"%@ %@", [postItem prefix], [postItem userLastName]];
        
        [[cell userNameLabel]setText:newDisplayName];
        [[cell dateAndGradeLabel]setText:[NSString stringWithFormat:@"%@ | %@", [self fuzzyTime:[df stringFromDate:timePosted]], [postItem userCategory]]];
    }
    
    if (![[[LAStoreManager defaultStore]currentUser]userVerified]) {
        [[cell icon]setHidden:YES];
        [[cell timeImage]setHidden:YES];
        [[cell userNameLabel]setHidden:YES];
        [[cell socialLabel]setHidden:YES];
        [[cell socialMediaImage]setHidden:YES];
        [[cell likeImage]setHidden:YES];
        [[cell dateAndGradeLabel]setText:[NSString stringWithFormat:@"%@_______________________", [self fuzzyTime:[df stringFromDate:timePosted]]]];
    }
    
    if (![[[[LAStoreManager defaultStore]currentUser]userCategory] isEqualToString:@"Student"]) {
        [[cell socialMediaImage]setHidden:YES];
        [[cell likeImage]setHidden:YES];
    }
    
    if ([[postItem socialNetwork] isEqualToString:@"Facebook"]) {
        UIImage *facebookIcon = [[UIImage imageNamed:@"facebook"]imageWithOverlayColor:[UIColor whiteColor]];
        [[cell socialMediaImage]setImage:facebookIcon];
        UIImage *thumbsup = [[UIImage imageNamed:@"facebooklike"]imageWithOverlayColor:[UIColor whiteColor]];
        [[cell likeImage]setImage:thumbsup];
    }
    else if([[postItem socialNetwork] isEqualToString:@"Instagram"]) {
        UIImage *instagramIcon = [[UIImage imageNamed:@"instagram"]imageWithOverlayColor:[UIColor whiteColor]];
        [[cell socialMediaImage]setImage:instagramIcon];
        UIImage *heart = [[UIImage imageNamed:@"instagramlike"]imageWithOverlayColor:[UIColor whiteColor]];
        [[cell likeImage]setImage:heart];
    }
    else {
        UIImage *twitterIcon = [[UIImage imageNamed:@"twitter"]imageWithOverlayColor:[UIColor whiteColor]];
        [[cell socialMediaImage]setImage:twitterIcon];
        UIImage *star = [[UIImage imageNamed:@"twitterlike"]imageWithOverlayColor:[UIColor whiteColor]];
        [[cell likeImage]setImage:star];
    }
    
    if ([postItem isLikedByThisUser]){
        if ([[postItem socialNetwork] isEqualToString:@"Facebook"]) {
            UIImage *thumbsup = [[UIImage imageNamed:@"facebooklike"]imageWithOverlayColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];/*#40c7f2*/
            [[cell likeImage]setImage:thumbsup];
        }
        else if([[postItem socialNetwork] isEqualToString:@"Instagram"]){
            UIImage *heart = [[UIImage imageNamed:@"instagramlike"]imageWithOverlayColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];/*#40c7f2*/
            [[cell likeImage]setImage:heart];
        }
        else {
            UIImage *star = [[UIImage imageNamed:@"twitterlike"]imageWithOverlayColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];/*#40c7f2*/
            [[cell likeImage]setImage:star];
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If scrolled beyond two thirds of the table, load next batch of data..
    if ([indexPath row] >= (([[[LAStoreManager defaultStore]allMainPostItems]count]/5) *4))
        [[LAStoreManager defaultStore]fetchFromDate:[[[LAStoreManager defaultStore]lastPostInArray]postTime]
                              matchingHashtagFilter:self.currentHashtagFilter];
    
    UITableViewCell *cell;

    if ([indexPath row] < [[[LAStoreManager defaultStore]allMainPostItems]count]) {
        cell = [self configureCell:indexPath];
    }
    else {
        NSString *cellIdentifier = @"moreCell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        
        // The currently requested cell is the last cell.
        if ([[LAStoreManager defaultStore]moreResultsAvail]) {
            // If there are results available, display @"Loading More..." in the last cell
            cell.textLabel.text = @"Loading More Posts...";
            cell.textLabel.font = [UIFont systemFontOfSize:18];
            cell.textLabel.textColor = [UIColor colorWithRed:0.65f
                                                       green:0.65f
                                                        blue:0.65f
                                                       alpha:1.00f];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            // If there are no results available, display @"No More Results Available" in the last cell
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.text = @"No More Posts Available";
            cell.textLabel.textColor = [UIColor colorWithRed:0.65f
                                                       green:0.65f
                                                        blue:0.65f
                                                       alpha:1.00f];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size;
    if (indexPath.row < [[[LAStoreManager defaultStore]allMainPostItems]count]) {
        // using postItem because cell hasn't been made yet.
        LAPostItem *postItem =[[[LAStoreManager defaultStore]allMainPostItems]objectAtIndex:[indexPath row]];

        if ([postItem imageURLString] == nil) {
            size = 105;
        } else {
            UIImage *image = [self imageWithImage:[UIImage imageNamed:@"Instagram1"] scaledToWidth:370];
            size = image.size.height;
        }
    } else {
        size = 50; // For the Loading more... row
    }
    return size;
}

// TODO: either static-ize this date formatter or switch to GitHub package
- (NSString *)fuzzyTime:(NSString *)datetime
{
    NSString *formatted;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    NSDate *date = [formatter dateFromString:datetime];
    NSDate *today = [NSDate date];
    NSInteger minutes = [today minutesAfterDate:date];
    NSInteger hours = [today hoursAfterDate:date];
    NSInteger days = [today daysAfterDate:date];
    NSString *period;
    
    if (days >= 365) {
        float years = round(days / 365) / 2.0f;
        period = (years > 1) ? @"years" : @"year";
        formatted = [NSString stringWithFormat:@"about %f %@ ago", years, period];
    } else if(days < 365 && days >= 30) {
        float months = round(days / 30) / 2.0f;
        period = (months > 1) ? @"months" : @"month";
        formatted = [NSString stringWithFormat:@"about %f %@ ago", months, period];
    } else if(days < 30 && days >= 2) {
        period = @"days";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", days, period];
    } else if(days == 1){
        period = @"day";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", days, period];
    } else if(days < 1 && minutes > 60) {
        period = (hours > 1) ? @"hours" : @"hour";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", hours, period];
    } else {
        period = (minutes < 60 && minutes > 1) ? @"minutes" : @"minute";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", minutes, period];
        if(minutes < 1){
            formatted = @"a moment ago";
        }
    }
    return formatted;
}

// TODO: move this to a utility class or category
- (UIImage*)imageWithImage:(UIImage*)sourceImage
            scaledToWidth:(float)i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)likeButtonTapped:(id)sender
{
    // by default the isLikedByThisUser should be set to NO;
    // on click it should change the flag and color of the like buttons.
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

    if (indexPath) {
        LAPostItem *postItem = [[[LAStoreManager defaultStore]allMainPostItems]objectAtIndex:[indexPath row]];
        
        if (![self.socialManager isSessionValidForNetwork:postItem.socialNetwork]) {
            SocialNetworkType socialNetworkType = SocialNetwork_Twitter;
            if ([postItem.socialNetwork isEqualToString:@"Twitter"])
                socialNetworkType = SocialNetwork_Twitter;
            else if ([postItem.socialNetwork isEqualToString:@"Instagram"])
                socialNetworkType = SocialNetwork_Instagram;
            
            LASocialNetworksView *socialView = [[LASocialNetworksView alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width - 40, 250) socialNetworkType:socialNetworkType];

            [self.navigationController.view addSubview:socialView];
            
            [socialView show];
        } else {
            if (![postItem isLikedByThisUser]) {
                [postItem setIsLikedByThisUser:YES];
                [self.socialManager likePostItem:postItem];
                [[LALikesStore defaultStore]saveUsersLike:[postItem postObject]];
            } else {
                [postItem setIsLikedByThisUser:NO];
                [self.socialManager unLikePostItem:postItem];
                [[LALikesStore defaultStore]deleteUsersLike:[postItem postObject]];
            }
        }
    }
    
    [[self tableView] reloadData];
}

#pragma mark - Social Manager Delegates

- (void)twitterDidReceiveAnError:(NSString *)errorMessage
{
    dispatch_queue_t callerQueue = dispatch_get_main_queue();
    dispatch_async(callerQueue, ^{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:errorMessage
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [[self tableView] reloadData];
    });
}

#pragma mark NoticeViewController delegate
- (void)showDetailViewItem:(LANoticeItem *)ourItem
{
    [self performSegueWithIdentifier:@"toDetailView" sender:self];
    
    LADetailNoticeViewController *dtv = [self.storyboard instantiateViewControllerWithIdentifier:@"detailNotices"];
    
    dtv.item = ourItem;
    
    [self presentViewController:dtv animated:YES completion:^{
        NSLog(@"showing detailView");
    }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if (row > 0)
        title = [[LAStoreManager defaultStore] allUniqueHashtagsItems][row - 1];
    
    self.currentHashtagFilter = title;
    
    // user has selected a hashtag from the picker, so clear the feed and re-query from Parse with
    // hashtag filter applied, or a nil-filter applied for all posts
    [[LAStoreManager defaultStore] clearAllMainPostItems];
    [[LAStoreManager defaultStore] fetchFromDate:nil matchingHashtagFilter:title];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 200;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
        return @"#LOSAL";
    
    return [[LAStoreManager defaultStore] allUniqueHashtagsItems][row - 1];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[LAStoreManager defaultStore] allUniqueHashtagsItems] count] + 1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

@end
