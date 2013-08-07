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
	// Do any additional setup after loading the view, typically from a nib.

    //grabbing left bar button from libary
//    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    menuBtn.frame = CGRectMake(10, 10, 30, 21);
//    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menuBtn.png"] forState:UIControlStateNormal];
//    [menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(revealMenu:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
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
    //this is were you populate reload the data
    //TODO: enter in the postitem to pull data from
    
//    LAPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCellIdentifier"];
//    if(cell == nil)
//    {
//        cell = [[LAPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postCellIdentifier"];
//              
//    }
//    
//    [[cell userNameLabel] setText:@"James Hall"];
//    
//    [[cell gradeLabel] setText:@"Senior"];
//    
//    [[cell socialLabel] setText:@"Facebook here"];
//    
//    [[cell dateLabel] setText:@"today"];
//    UIImage *i = [UIImage imageNamed:@"photo1.jpg"];
//    
//    [[cell imageView] setImage:i];
    
    //NSDate *date = [[NSDate alloc] init];
    
    // NSDate *object = _objects[indexPath.row];
    //cell.textLabel.text = [object description];
    //[[self tableView] reloadData];
    
    NSString *cellIdentifier = @"postCell";
    
    LAPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[LAPostCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                 reuseIdentifier:cellIdentifier];
    }
    
    LAPostItem *postItem = [_objects objectAtIndex:indexPath.row];
    
    [cell.userNameLabel setText:postItem.text];
    [self.imageLoader processImageDataWithURLString:postItem.imageURLString forId:postItem.postID andBlock:^(UIImage *image) {
        UITableViewCell *cellExists = [tableView cellForRowAtIndexPath:indexPath];
        if (cellExists) {
            [cell.postImage setImage:image];
        }
    }];

    //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:MyURL]]];
    //cell.postImage = postItem.postImage;
    //[cell.imageView setImageWithURL:[NSURL URLWithString:postItem.imageURLString] placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    [[cell userNameLabel]setText:postItem.text];
    [[cell dateLabel]setText:@"today"];
    [[cell socialLabel]setText:@"facebook"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Resize to fit in 320 width
    UIImage *image = [self imageWithImage:[UIImage imageNamed:@"Instagram1"] scaledToWidth:320];
    return image.size.height;
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
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
