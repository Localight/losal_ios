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
@interface LAFeedViewController ()

#define  DEFAULT_ICON "\uE00C"

@property (strong, nonatomic) LASocialManager *socialManager;
@property (strong, nonatomic) LAImageLoader *imageLoader;

// The data source to be displayed in table ()
@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSArray *filteredObjects;
// The counter of fetch batch.
@property (nonatomic) int fetchBatch;
// Indicates whether the data is already loading.
// Don't load the next batch of data until this batch is finished.
// You MUST set loading = NO when the fetch of a batch of data is completed.
// See line 29 in DataLoader.m for example.
@property (nonatomic) BOOL loading;
// noMoreResultsAvail indicates if there are no more search results.
// Implement noMoreResultsAvail in your app.
// For demo purpsoses here, noMoreResultsAvail = NO.
@property (nonatomic) BOOL moreResultsAvail;

- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)revealMenu:(id)sender;
- (IBAction)revealNotices:(id)sender;
- (void)fetchEntries;
- (NSString *)fuzzyTime:(NSString *)datetime;

@end

@implementation LAFeedViewController


#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.socialManager = [LASocialManager sharedManager];
        self.socialManager.delegate = self;
        self.imageLoader = [LAImageLoader sharedManager];
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 0, 30, 30);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithCustomView:menuBtn];
        UIButton *noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        noticeBtn.frame = CGRectMake(0, 0, 27, 27);
        [noticeBtn setBackgroundImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
        [noticeBtn addTarget:self action:@selector(revealNotices:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:noticeBtn];
        UIButton *title = [UIButton buttonWithType:UIButtonTypeCustom];
        [title setTitle:@"#LOSAL" forState:UIControlStateNormal];
        title.frame = CGRectMake(0, 0, 70, 44);
        [title.titleLabel setFont:[UIFont fontWithName:@"Roboto-Medium" size:24]];
        [title addTarget:self action:@selector(titleTap:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = title;
        
        [[[self view]layer]setShadowOpacity:0.75f];
        [[[self view]layer]setShadowRadius:0.75f];
        [[[self view]layer]setShadowColor:(__bridge CGColorRef)([UIColor blackColor])];
        
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
        } completion:^(BOOL finished) {
            [backgroundImage setImage:[UIImage imageNamed:imageDark]];
            [backgroundImage setAlpha:1.0f];
        }];
        //come back to this updateEntries
       // [[LANoticesStore defaultStore]updateEntries];
       // this should be in store
        [self fetchEntries];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This is where you populate the table with data
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[LANoticeViewController class]])
    {
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Notices"];
    }
    
    // This was messing up the scrolling in the UI table view so need to figure out a way to add this back - Joaquin
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    if ([self firstTimeLaunched])
    {
        [self performSegueWithIdentifier:@"kIntroductionSegue" sender:self];
    }
    else if ([[LAStoreManager defaultStore]currentUser]) {
        UIStoryboard *storyboard = [UIApplication sharedApplication].delegate.window.rootViewController.storyboard;
        
        UIViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
        
        [self presentViewController:loginController animated:YES
                         completion:^{
            NSLog(@"showing login view");
        }];
    }

    // Set up splash to dimmed background animation
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)fetchEntries
{
//    self.moreResultsAvail = YES;
    
    [self setMoreResultsAvail:YES];
    
    UIView *currentTitleView = [[self navigationItem] titleView];
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[self navigationItem] setTitleView:aiView];
    
    [aiView startAnimating];
    
    [[self navigationItem] setTitleView:currentTitleView];
    
    [[LAStoreManager defaultStore]getFeedWithCompletion:^(NSArray *posts, NSError *error)
    {
        NSLog(@"Completion block called!");
        
        if (!error)
        {
            // going to need to fix this up as well.
            self.objects = [NSMutableArray arrayWithArray:posts];
            self.filteredObjects = [self filterObjects:self.objects];
            static BOOL firstTime = YES;
            
            if (firstTime) 
            {
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                                  withRowAnimation:UITableViewRowAnimationTop];
                    firstTime = NO;
                    [[self tableView] reloadData];
            } else {
                
            }
            //dispatch 
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
            NSLog(@"results are %@", posts);
        }
    }];
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
    LAHashtagViewController *hashtagController = [self.storyboard instantiateViewControllerWithIdentifier:@"Hashtags"];
    
    [self.navigationController pushViewController:hashtagController animated:NO];
}

- (void)loadRequest
{
    LADataLoader *loader = [[LADataLoader alloc] init];
    loader.delegate = self;
    LAPostItem *postItem = [self.objects lastObject];
    [loader loadDataFromDate:postItem.postTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//get rid of this later
- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_objects count] > 0) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.objects count] + 1;
}

- (UITableViewCell *)configureCell:(NSIndexPath *)indexPath {
    // This method might need to be wittled down, I think some of this stuff doesn't belong here.
    // mostly the color changing of the like posts
    
    NSString *cellIdentifier = @"postCell";
    
    LAPostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[LAPostCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                 reuseIdentifier:cellIdentifier];
    }
    LAPostItem *postItem = [_objects objectAtIndex:indexPath.row];
    
    [[cell userNameLabel]setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [[cell messageArea] setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    //[[cell messageArea]setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-text"]]];
    
    [[cell dateAndGradeLabel] setFont:[UIFont fontWithName:@"Roboto-Light" size:11]];
    
    NSDate *timePosted = [postItem postTime];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    //NSLog(@"%@",[self fuzzyTime:[df stringFromDate:timePosted]]);
    
    [[cell messageArea] setText:[postItem text]];
    
    // Set up users icon
    [cell.icon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
    
    if ([postItem.postUser.iconString length] > 0) {
        NSScanner *scanner = [NSScanner scannerWithString:postItem.postUser.iconString];
        unsigned int code;
        [scanner scanHexInt:&code];
        [[cell icon]setText:[NSString stringWithFormat:@"%C", (unsigned short)code]];
        [[cell icon]setTextColor:[self colorFromHexString:[[postItem postUser]iconStringColorFromParse]]];
    } else {
        cell.icon.text = [NSString stringWithUTF8String:DEFAULT_ICON];
        [cell.icon setTextColor:[UIColor whiteColor]];
    }
    
    UIImage *ago = [[UIImage imageNamed:@"clock"]imageWithOverlayColor:[UIColor whiteColor]];
    [[cell timeImage] setImage:ago];
    NSString *grade = @""; // set to blank in case there is no grade from post Item
    NSString *name = @""; // set to blank in case there is no name from post Item
    if (postItem.postUser != nil) {
        grade = postItem.postUser.grade;
        name = postItem.postUser.firstName;
    }
    [[cell dateAndGradeLabel]setText:[NSString stringWithFormat:@"%@ | %@", [self fuzzyTime:[df stringFromDate:timePosted]], grade]];
    [[cell userNameLabel] setText:name];
   
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
    if (![[postItem imageURLString] length] == 0)
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
                 [[cell messageArea]setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dark-gradient"]]];
                 //[UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient-text"]]
                 //[cell.postImage setImage:image];
             }}];
    } else {
        [[cell postImage]setImage:nil];
        [[cell messageArea]setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dark-gradient"]]];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If scrolled beyond two thirds of the table, load next batch of data.
    if (indexPath.row >= (self.objects.count/5 *4)) {
        if (!self.loading && self.moreResultsAvail) {
            self.loading = YES;
            // loadRequest is the method that loads the next batch of data.
            [self loadRequest];
        }
    }
    
    UITableViewCell *cell;
    
    if (indexPath.row < [self.objects count]) {
        cell = [self configureCell:indexPath];
    } else {
        NSString *cellIdentifier = @"moreCell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        // The currently requested cell is the last cell.
        if (self.moreResultsAvail) {
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

-(UIColor *)colorFromHexString:(NSString *)hexString {
    
    NSUInteger red, green, blue;
    sscanf([hexString UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    return (color);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size;
    if (indexPath.row < [self.objects count]) {
        // using postItem because cell hasn't been made yet.
        LAPostItem *postItem = [_objects objectAtIndex:[indexPath row]];
        
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

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_objects removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
        LAPostItem *postItem = [_objects objectAtIndex:indexPath.row];
        
        if ([self.socialManager isSessionValidForNetwork:postItem.socialNetwork] == NO)
        {
            LASocialNetworksView *socialView = [[LASocialNetworksView alloc] initWithFrame:CGRectMake(20, 64, self.view.bounds.size.width - 40, 230)];
           
            [self.navigationController.view addSubview:socialView];
            
            [socialView show];
        } else {
            LAPostItem *postItem = [_objects objectAtIndex:indexPath.row];
            
            if (![postItem isLikedByThisUser])
            {
                [postItem setIsLikedByThisUser:YES];
                [self.socialManager likePostItem:postItem];
                [[LAStoreManager defaultStore]saveUsersLike:[postItem postObject]];

                
            }else{
                [postItem setIsLikedByThisUser:NO];
                [self.socialManager unLikePostItem:postItem];
                [[LAStoreManager defaultStore]deleteUsersLike:[postItem postObject]];
            }
        }
    }
    [[self tableView]reloadData];
}

- (void)processArray:(NSArray *)array {
    if ([array count] > 0) {
        [self.objects addObjectsFromArray:array];
        //self.filteredObjects = [self filterObjects:self.objects];
    } else {
        self.moreResultsAvail = NO;
    }
    [self.tableView reloadData];
    // Always remember to set loading to NO whenever you finish loading the data.
    self.loading = NO;
}

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

- (void)instagramDidReceiveAnError {
    NSLog(@"Instagram Error");
}
- (void)instagramDidLoad:(id)result {
    NSLog(@"Received restul %@", result);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        //[[segue destinationViewController] setDetailItem:object];
    }
}


- (BOOL)firstTimeLaunched
{
#warning remove this before shipping!
    // debug
    return YES;
    
    static NSString *firsTTimeLaunchedKey = @"firsTTimeLaunchedKey";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasLaunched = [defaults boolForKey:firsTTimeLaunchedKey];
    
    if (!hasLaunched)
    {
        [defaults setBool:YES forKey:firsTTimeLaunchedKey];
        [defaults synchronize];
    }
    
    return !hasLaunched;
}

@end
