
//
//  LAFeedViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

// all data is pulled from the store class.

#import "LAFeedViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"
#import "LANoticeViewController.h"
#import "LAHashtagViewController.h"

#import "LAStoreManager.h"
#import "LASocialManager.h"

#import "LAImageLoader.h"

#import "LAPostCell.h"

#import "LAPostItem.h"

#import "LAImage+Color.h"

#import "NSDate-Utilities.h"

#import "LASocialNetworksView.h"

#import "LADataLoader.h"
#import "LANoticesStore.h"
#import "KeychainItemWrapper.h"
#import "LANoticeViewController.h"
#import "LALikesStore.h"
#import "LADetailNoticeViewController.h"
#import <Security/Security.h>
@interface LAFeedViewController ()

#define  DEFAULT_ICON "\uE017"

@property (strong, nonatomic) LASocialManager *socialManager;
@property (strong, nonatomic) LAImageLoader *imageLoader;

// The data source to be displayed in table ()
//@property (strong, nonatomic) NSMutableArray *objects;
//@property (strong, nonatomic) NSArray *filteredObjects;
// The counter of fetch batch.
@property (nonatomic) int fetchBatch;
// Indicates whether the data is already loading.
// Don't load the next batch of data until this batch is finished.
// You MUST set loading = NO when the fetch of a batch of data is completed.
// See line 29 in DataLoader.m for example.

// noMoreResultsAvail indicates if there are no more search results.
// Implement noMoreResultsAvail in your app.
// For demo purpsoses here, noMoreResultsAvail = NO.

@property (nonatomic, strong) UIActionSheet *actionSheet;


- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)revealMenu:(id)sender;
- (IBAction)revealNotices:(id)sender;
- (NSString *)fuzzyTime:(NSString *)datetime;

@end

@implementation LAFeedViewController



#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[LAStoreManager defaultStore] fetchFromDate:nil];
    [[LAStoreManager defaultStore] getHashTags];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstTimeLaunchedKey"])
    {
        [self performSegueWithIdentifier:@"kIntroductionSegue" sender:self];
        UIStoryboard *storyboard = [UIApplication sharedApplication].delegate.window.rootViewController.storyboard;
        
        UIViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
        
        [self presentViewController:loginController animated:YES
                         completion:^{
                             NSLog(@"showing login view");
                         }];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstTimeLaunchedKey"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } else {
        [[LAStoreManager defaultStore]loginWithPhoneNumber];
       
        // call login in method used stored password and pin numbers
        // keep user logged in.
        
        NSLog(@"you should be showing nothing");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedReloadNotification:)
                                                 name:@"Reload"
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
    UIButton *title = [UIButton buttonWithType:UIButtonTypeCustom];
    [title setTitle:@"#LOSAL" forState:UIControlStateNormal];
    title.frame = CGRectMake(0, 0, 70, 44);
    [title.titleLabel setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:24]];
    
    [title addTarget:self
              action:@selector(titleTap:)
    forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = title;
    
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
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[LANoticeViewController class]])
    {
        LANoticeViewController *noticeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Notices"];
        
        noticeVC.delegate = self;
        
        self.slidingViewController.underRightViewController = noticeVC;
    }
    //TODO: big TODO!! get the user to stay logged in. and store all his data.
    
    // This was messing up the scrolling in the UI table view so need to figure out a way to add this back - Joaquin
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    // I like the way this works. Neat pattern.
    // basically you count on something not being created, and you call expect nil or false.
    // then you tell the if statement to count on that fact that it will be false or nil.
    // if it is false or nil then, present the "thing"(view in our case) and create the statement I was checking for.
    // therefore at all times in history the statment will be true, because you saved it in the user defaults.
}
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//   
//   // [[self tableView] reloadData];
//}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)revealNotices:(id)sender
{
    NSLog(@"%lu", (unsigned long)[[[LANoticesStore defaultStore]allItems]count]);
    
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

- (IBAction) titleTap:(id) sender
{
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
    
    [self.actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    
//    
//    LAHashtagViewController *hashtagController = [self.storyboard instantiateViewControllerWithIdentifier:@"Hashtags"];
//    
//    [self.navigationController pushViewController:hashtagController animated:YES];
}

- (void)closeThisActionSheet
{
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)dismissActionSheet:(id)sender
{
    
    UIActionSheet *actionSheet =  (UIActionSheet *)[(UIView *)sender superview];
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)receivedReloadNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    if ([[notification name] isEqualToString:@"Reload"])
    {
        [[self tableView]reloadData];
    }
}
- (void)loadRequest
{
  //  LADataLoader *loader = [[LADataLoader alloc] init];
   // loader.delegate = self;
    //LAPostItem *postItem = [[[LAStoreManager defaultStore]allMainPostItems]lastObject];
    NSLog(@"This gets called when the tableiview reaches 2/3s of it's size.");
    // I think my error is here.
    // this block doesn't come back to this call. 
    }
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//get rid of this later
//- (void)insertNewObject:(id)sender
//{
//    if (![[LAStoreManager defaultStore]allMainPostItems]) {
//       
//    }
//    [[LAStoreManager defaultStore]allMainPostItems]inse
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath]
//                          withRowAnimation:UITableViewRowAnimationAutomatic];
//}
- (void)viewWillDisappear:(BOOL)animated
{
    [[LAStoreManager defaultStore]clearAllMainPostItems];
    [[[LAStoreManager defaultStore]currentUser]setIsFilteredArray:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[[LAStoreManager defaultStore]allMainPostItems]count] > 0) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[LAStoreManager defaultStore]allMainPostItems]count] + 1;
}

- (UITableViewCell *)configureCell:(NSIndexPath *)indexPath
{
    // This method might need to be wittled down, I think some of this stuff doesn't belong here.
    // mostly the color changing of the like posts
    
    NSString *cellIdentifier = @"postCell";
    
    LAPostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[LAPostCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                 reuseIdentifier:cellIdentifier];
    }
    
    // this sets up the image if an image is present
    
    LAPostItem *postItem = [[[LAStoreManager defaultStore]allMainPostItems]objectAtIndex:[indexPath row]];
    
    if (![[postItem imageURLString]length] == 0)
    {
        // Set image to nil, in case the cell was reused.
        [cell.postImage setImage:nil];
        [self.imageLoader processImageDataWithURLString:postItem.imageURLString
                                                  forId:postItem.postObject.objectId // why do we need to object ID?
                                               andBlock:^(UIImage *image)
         {
             if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath])
             {
                 [[cell postImage]setImage:image];
                 [[cell messageArea]setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-iphone4"]]];
                 //[UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-text"]]
                 //[cell.postImage setImage:image];
             }}];
        // if it's  tweet set the message image to nil
    } else {
        [[cell postImage]setImage:nil];
//        [[cell messageArea]setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-iphone4"]]];
    }
    NSScanner *scanner = [NSScanner scannerWithString:[postItem iconString]];
    unsigned int code;
    [scanner scanHexInt:&code];
    [[cell icon]setText:[NSString stringWithFormat:@"%C",(unsigned short)code]];
    [[cell icon]setTextColor:[postItem userColorChoice]];
    [[cell icon]setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];

    //TODO: create NSUserdefaults
    [[cell userNameLabel]setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [[cell messageArea] setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    [[cell dateAndGradeLabel] setFont:[UIFont fontWithName:@"Roboto-Light" size:11]];
    UIImage *ago = [[UIImage imageNamed:@"clock"]imageWithOverlayColor:[UIColor whiteColor]];
    [[cell timeImage] setImage:ago];
    NSDate *timePosted = [postItem postTime];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    //NSLog(@"%@",[self fuzzyTime:[df stringFromDate:timePosted]]);
    
    // the following sets up the user's icons.
    
    [[cell messageArea] setText:[postItem text]];
    [[cell messageArea]setTextColor:[UIColor whiteColor]];
//    [[cell messageArea]sizeToFit];
    
    // Set up users icon[cell.icon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
    NSLog(@"%@", [postItem userFirstName]);
    
    // set up the icons for users of type students
    if ([postItem userFirstName] == nil){
        [[cell userNameLabel]setText:@"Unknown"];
        [[cell userNameLabel]setTextColor:[UIColor whiteColor]];
        [[cell icon]setText:@DEFAULT_ICON];
        [[cell icon]setTextColor:[UIColor whiteColor]];
        
        
    }else if([[postItem userCategory]isEqualToString:@"Student"])
    {
        NSString * newLastNameString = [[postItem userLastName] substringWithRange:NSMakeRange(0, 1)];
        NSString *newName = [NSString stringWithFormat:@"%@ %@.", [postItem userFirstName], newLastNameString];
        [[cell userNameLabel]setText:newName];
        [[cell dateAndGradeLabel]setText:[NSString stringWithFormat:@"%@ | %@", [self fuzzyTime:[df stringFromDate:timePosted]], [postItem gradeLevel]]];
    }else{
        NSString *newDisplayName = [NSString stringWithFormat:@"%@ %@", [postItem prefix], [postItem userLastName]];
        
        [[cell userNameLabel]setText:newDisplayName];
        [[cell dateAndGradeLabel]setText:[NSString stringWithFormat:@"%@ | %@", [self fuzzyTime:[df stringFromDate:timePosted]], [postItem userCategory]]];
        
    }
    
    if (![[[LAStoreManager defaultStore]currentUser]userVerified])
    {
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
//    }else if(![[[[LAStoreManager defaultStore]currentUser]userCategory] isEqualToString:@"student"]){
//        [[cell socialLabel]setHidden:YES];
//        [[cell socialMediaImage]setHidden:YES];
//    }else{
//        //do nothing..
//    }
    
    if ([[postItem socialNetwork] isEqualToString:@"Facebook"])
        {
            UIImage *facebookIcon = [[UIImage imageNamed:@"facebook"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell socialMediaImage]setImage:facebookIcon];
            UIImage *thumbsup = [[UIImage imageNamed:@"facebooklike"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell likeImage]setImage:thumbsup];
        } else if([[postItem socialNetwork] isEqualToString:@"Instagram"]){
            UIImage *instagramIcon = [[UIImage imageNamed:@"instagram"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell socialMediaImage]setImage:instagramIcon];
            UIImage *heart = [[UIImage imageNamed:@"instagramlike"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell likeImage]setImage:heart];
        } else {
            UIImage *twitterIcon = [[UIImage imageNamed:@"twitter"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell socialMediaImage]setImage:twitterIcon];
            UIImage *star = [[UIImage imageNamed:@"twitterlike"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell likeImage]setImage:star];
        }
        
        // by default we want the
        if ([postItem isLikedByThisUser])
        {
            if ([[postItem socialNetwork] isEqualToString:@"Facebook"])
            {
                UIImage *thumbsup = [[UIImage imageNamed:@"facebooklike"]imageWithOverlayColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];/*#40c7f2*/
                [[cell likeImage]setImage:thumbsup];
            } else if([[postItem socialNetwork] isEqualToString:@"Instagram"]){
                UIImage *heart = [[UIImage imageNamed:@"instagramlike"]imageWithOverlayColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];/*#40c7f2*/
                [[cell likeImage]setImage:heart];
            } else {
                UIImage *star = [[UIImage imageNamed:@"twitterlike"]imageWithOverlayColor:[UIColor colorWithRed:0.251 green:0.78 blue:0.949 alpha:1]];/*#40c7f2*/
                [[cell likeImage]setImage:star];
            }
        }
        
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"the current index path is %ld", (long)[indexPath row]);
    NSLog(@"the current size of the array is %lu",(unsigned long)[[[LAStoreManager defaultStore]allMainPostItems]count]);
    
    // this possibly the method where we use the flag
    int a = ([[[LAStoreManager defaultStore]allMainPostItems]count]/5)*4;
    
    NSLog(@"the row number has to be greater than than or equal to %d inorder to call for more data" ,a);
    // If scrolled beyond two thirds of the table, load next batch of data..
    if ([indexPath row] >= (([[[LAStoreManager defaultStore]allMainPostItems]count]/5) *4))
    {
        [[LAStoreManager defaultStore]fetchFromDate:[[[LAStoreManager defaultStore]lastPostInArray]postTime]];
    }
    
    UITableViewCell *cell;
    
    NSLog(@"the cell count is %lu", (unsigned long)[[[LAStoreManager defaultStore]allMainPostItems]count]);
    
    if ([indexPath row] < [[[LAStoreManager defaultStore]allMainPostItems]count]) {
        cell = [self configureCell:indexPath];
    } else {
        NSString *cellIdentifier = @"moreCell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        // The currently requested cell is the last cell.
        if ([[LAStoreManager defaultStore]moreResultsAvail])
        {
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


-(CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size;
    if (indexPath.row < [[[LAStoreManager defaultStore]allMainPostItems]count]) {
        // using postItem because cell hasn't been made yet.
        LAPostItem *postItem =[[[LAStoreManager defaultStore]allMainPostItems]objectAtIndex:[indexPath row]];
        //[_objects objectAtIndex:[indexPath row]];
        
        if ([postItem imageURLString] == 0) {
            size = 150;
        } else {
            UIImage *image = [self imageWithImage:[UIImage imageNamed:@"Instagram1"] scaledToWidth:370];
            
            size = image.size.height;
        }
    } else {
        size = 50; // For the Loading more... row
    }
    return size;
}
//still working on
-(NSString *)fuzzyTime:(NSString *)datetime;
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
    if(days >= 365){
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

-(UIImage*)imageWithImage:(UIImage*)sourceImage
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
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
// don't think this get's called either
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"someones's trying to delete cells that's not right.");
        
        //[_objects removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (IBAction)likeButtonTapped:(id)sender
{
    // by default the isLikedByThisUser should be set to NO;
    // on click it should change the flag and color of the like buttons.
    
    // what does this do? -James
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

    if (indexPath != nil)
    {
        // Get postitem and pass it to the like method in the social managher
        
        LAPostItem *postItem = [[[LAStoreManager defaultStore]allMainPostItems]objectAtIndex:[indexPath row]];
        
        if ([self.socialManager isSessionValidForNetwork:postItem.socialNetwork] == NO) {
            
            SocialNetworkType socialNetworkType = SocialNetwork_Twitter;
            if ([postItem.socialNetwork isEqualToString:@"Twitter"])
                socialNetworkType = SocialNetwork_Twitter;
            else if ([postItem.socialNetwork isEqualToString:@"Instagram"])
                socialNetworkType = SocialNetwork_Instagram;
            
            LASocialNetworksView *socialView = [[LASocialNetworksView alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width - 40, 250) socialNetworkType:socialNetworkType];

            [self.navigationController.view addSubview:socialView];
            
            [socialView show];
        } else {
            LAPostItem *postItem = [[[LAStoreManager defaultStore]allMainPostItems]objectAtIndex:[indexPath row]];
            
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
// not even sure this does anything
- (NSArray *)filterObjects:(NSArray *)objects
{
    NSMutableArray *filteredObjects = [[NSMutableArray alloc] init];
    
    for (LAPostItem *post in objects) {
        // Determine if postID is filters
        [filteredObjects addObject:post];
    }
    return [NSArray arrayWithArray:filteredObjects];
}

#pragma mark - Social Manager Delegates

- (void)twitterDidReceiveAnError:(NSString *)errorMessage {
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
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    // TODO: special-case handling for index 0, which is a no-filter
    if (row == 0) {
        [[[LAStoreManager defaultStore] currentUser] setIsFilteredArray:NO];
        
        
        return;
    }
    
    // I'm thinking that i'll create an array fill it with the post that have the hashtag associate with them.
    // I'm thinking I will load the postarray with a new array, then clear it. each time a new hashtag is selected a new array
    // is created and the old one is destroyed
    // I need to make sure that the main post itmes comes back some how though. for now, lets try to load an array of different items
//    [[LAStoreManager defaultStore]clearAllMainPostItems];
    [[[LAStoreManager defaultStore]currentUser]setIsFilteredArray:YES];
    // clear the curent array call another method to load the filtered array.
    
    NSString *title = [[[LAStoreManager defaultStore]allUniqueHashtagsItems] objectAtIndex:row];
    NSLog(@"Selected Row %d", row);
    NSLog(@"%@",[[[LAStoreManager defaultStore]allUniqueHashtagsItems] objectAtIndex:row]);
    // 1. clear the current array.
    // from here you are going to send the string of whatever the cell was to the
    // void(something.)..
    // might get an error when converting object to title. not sure right now though
    [[LAStoreManager defaultStore]sortHashTagsWithFilter:title];
    
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 200;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (row == 0)
        return @"All Hashtags";
    
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
