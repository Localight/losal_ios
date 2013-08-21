//
//  LAFeedViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

// all data is pulled from the store class.

#import "LAFeedViewController.h"

#import "LADetailViewController.h"

#import "LAStoreManager.h"
#import "LASocialManager.h"

#import "LAImageLoader.h"

#import "LAPostCell.h"

#import "LAPostItem.h"

#import "LAImage+Color.h"

#import "NSDate-Utilities.h"

#import "LASocialNetworksView.h"



@interface LAFeedViewController ()
{
    NSMutableArray *_objects;
}

@property (strong, nonatomic) LAStoreManager *storeManager;
@property (strong, nonatomic) LASocialManager *socialManager;
@property (strong, nonatomic) LAImageLoader *imageLoader;

- (IBAction)likeButtonTapped:(id)sender;

@end

@implementation LAFeedViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This is where you populate the table with data
    self.storeManager = [LAStoreManager sharedManager];
    self.socialManager = [LASocialManager sharedManager];
    self.socialManager.delegate = self;
    self.imageLoader = [LAImageLoader sharedManager];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(revealMenu:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;

    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    [[[self view]layer]setShadowOpacity:0.75f];
    [[[self view]layer]setShadowRadius:0.75f];
    [[[self view]layer]setShadowColor:(__bridge CGColorRef)([UIColor blackColor])];
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    // This was messing up the scrolling in the UI table view so need to figure out a way to add this back - Joaquin
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    if ([self.storeManager getUser] == nil) {
        UIStoryboard *storyboard = [UIApplication sharedApplication].delegate.window.rootViewController.storyboard;
        
        UIViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
        
        [self presentViewController:loginController animated:YES
                         completion:^{
                             NSLog(@"showing add friends");
                             //[self addFriends];
                         }];
    }

    // Set up splash to dimmed background animation
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
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self fetchEntries];
}
- (void)fetchEntries
{
    UIView *currentTitleView = [[self navigationItem] titleView];
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[self navigationItem] setTitleView:aiView];
    
    [aiView startAnimating];
    
    [[self navigationItem] setTitleView:currentTitleView];
    
    [self.storeManager getFeedWithCompletion:^(NSArray *posts, NSError *error)
    {
        NSLog(@"Completion block called!");
        if (!error)
        {
            _objects = [NSMutableArray arrayWithArray:posts];
            //[[self tableView] reloadData];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
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
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"postCell";
    
    LAPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[LAPostCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:cellIdentifier];
    }
    
    LAPostItem *postItem = [_objects objectAtIndex:indexPath.row];
    
    [[cell userNameLabel]setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [[cell messageArea] setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    [[cell dateAndGradeLabel] setFont:[UIFont fontWithName:@"Roboto-Light" size:11]];
    
    NSDate *timePosted = [postItem postTime];
    NSLog(@"%@", timePosted);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSLog(@"%@",[self fuzzyTime:[df stringFromDate:timePosted]]);
    
    [[cell messageArea] setText:[postItem text]];
    UIImage *coloredImage = [[UIImage imageNamed:@"Mustache"] imageWithOverlayColor:[UIColor redColor]];
    [cell.iconImage setImage:coloredImage];
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
    
    if ([postItem isLikedByThisUser]) {
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
    }else{
        if ([[postItem socialNetwork] isEqualToString:@"Facebook"])
        {
            UIImage *facebookIcon = [[UIImage imageNamed:@"facebook"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell socialMediaImage]setImage:facebookIcon];
            UIImage *thumbsup = [[UIImage imageNamed:@"facebooklike"]imageWithOverlayColor:[UIColor grayColor]];
            [[cell likeImage]setImage:thumbsup];
        } else if([[postItem socialNetwork] isEqualToString:@"Instagram"]){
            UIImage *instagramIcon = [[UIImage imageNamed:@"instagram"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell socialMediaImage]setImage:instagramIcon];
            UIImage *heart = [[UIImage imageNamed:@"instagramlike"]imageWithOverlayColor:[UIColor grayColor]];
            [[cell likeImage]setImage:heart];
        } else {
            UIImage *twitterIcon = [[UIImage imageNamed:@"twitter"]imageWithOverlayColor:[UIColor whiteColor]];
            [[cell socialMediaImage]setImage:twitterIcon];
            UIImage *star = [[UIImage imageNamed:@"twitterlike"]imageWithOverlayColor:[UIColor grayColor]];
            [[cell likeImage]setImage:star];
        }

    }

        if (![[postItem imageURLString] length] == 0)
    {
        // Set image to nil, in case the cell was reused.
        [cell.postImage setImage:nil];
        [self.imageLoader processImageDataWithURLString:postItem.imageURLString
                                                  forId:postItem.postObject.objectId
                                               andBlock:^(UIImage *image)
        {
            if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath])
            {
                [cell.postImage setImage:image];
            }}];
    } else {
        [[cell postImage]setImage:nil]; 
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // using postItem because cell hasn't been made yet.
    CGFloat size;
    LAPostItem *postItem = [_objects objectAtIndex:[indexPath row]];
    
    if ([postItem imageURLString] == 0) {
        size = 150;
    } else {
        UIImage *image = [self imageWithImage:[UIImage imageNamed:@"Instagram1"] scaledToWidth:370];
        
        size = image.size.height;
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
    return YES;
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
        
        if ([self.socialManager isSessionValidForNetwork:postItem.socialNetwork] == NO) {
            LASocialNetworksView *socialView = [[LASocialNetworksView alloc] initWithFrame:CGRectMake(20, 64, self.view.bounds.size.width - 40, 230)];
            [self.navigationController.view addSubview:socialView];
            [socialView show];
        } else {
            LAPostItem *postItem = [_objects objectAtIndex:indexPath.row];
            
            if (![postItem isLikedByThisUser])
            {
                [postItem setIsLikedByThisUser:YES];
                [self.socialManager likePostItem:postItem];
                [self.storeManager saveUsersLike:postItem.postObject];
                
            }else{
                [postItem setIsLikedByThisUser:NO];
                [self.socialManager unLikePostItem:postItem];
                [self.storeManager deleteUsersLike:postItem.postObject];
                
            }

        }
    }
    [[self tableView]reloadData];
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
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
