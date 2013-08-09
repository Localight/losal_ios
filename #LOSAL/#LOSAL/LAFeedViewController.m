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

#import "LAImageLoader.h"

#import "LAPostCell.h"

#import "LAPostItem.h"

@interface LAFeedViewController ()
{
    NSMutableArray *_objects;
}

@property (strong, nonatomic) LAStoreManager *storeManager;
@property (strong, nonatomic) LAImageLoader *imageLoader;

@end

@implementation LAFeedViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(revealMenu:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;

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

-(void)fetchEntries
{
    UIView *currentTitleView = [[self navigationItem] titleView];
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[self navigationItem] setTitleView:aiView];
    
    [aiView startAnimating];
    
    // This is where you populate the table with data
    self.storeManager = [LAStoreManager sharedManager];
    
    self.imageLoader = [LAImageLoader sharedManager];
    
    [[self navigationItem] setTitleView:currentTitleView];
    
    [self.storeManager getFeedWithCompletion:^(NSArray *posts, NSError *error)
    {
        NSLog(@"Completion block called!");
        if (!error)
        {
            _objects = [NSMutableArray arrayWithArray:posts];
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
    return 1;
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
    [[cell messageArea] setFont:[UIFont fontWithName:@"Roboto-Light" size: 15]];
    [[cell dateLabel] setFont:[UIFont fontWithName:@"Roboto-Light" size:11]];
    [[cell gradeLabel] setFont:[UIFont fontWithName:@"Roboto-Light" size:11]];
    
    NSDate *timePosted = [postItem postTime];
    NSDate *timeNow = [[NSDate alloc]init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                               fromDate:timePosted
                                                 toDate:timeNow
                                                options:0];
   //TODO: work on fraction to figure out time.
   // working on time algorithm
    NSLog(@"%@",timePosted);

    NSLog(@"it's been %i, %i, %i, %i, since your post:", [components day], [components hour], [components minute], [components second]);
    
    if ([[postItem imageURLString] length] == 0)
    {
        [[cell messageArea]setText:[postItem text]];
        [[cell postImage]setImage:nil];
        [[cell dateLabel]setText:[NSString stringWithFormat:@"%@|", [postItem postTime]]];
        [[cell socialLabel]setText:@"facebook"];
        [cell setBackgroundColor:[UIColor blackColor]];
        [cell setAutoresizesSubviews:NO];
        
        
        
    } else{
        
        [self.imageLoader processImageDataWithURLString:postItem.imageURLString
                                                  forId:postItem.postID
                                               andBlock:^(UIImage *image)
    {[cell.postImage setImage:image];}];
        
        [[cell messageArea] setText:[postItem text]];
        [[cell dateLabel]setText:[NSString stringWithFormat:@"%@|", [postItem postTime]]];
        [[cell socialLabel]setText:@"facebook"];
    }
    //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:MyURL]]];
    //cell.postImage = postItem.postImage;
    //[cell.imageView setImageWithURL:[NSURL URLWithString:postItem.imageURLString] placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
   
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Resize to fit in 320 width
    UIImage *image = [self imageWithImage:[UIImage imageNamed:@"Instagram1"] scaledToWidth:320];
    return image.size.height;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
