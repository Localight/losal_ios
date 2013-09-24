//
//  LANoticeViewController.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/23/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LANoticeViewController.h"
#import "ECSlidingViewController.h"
#import "LANoticeItemCell.h"
#import "LANoticeItem.h"
#import "LANoticesStore.h"
#import "LANoticeItemCell.h"
//#import "LAImageStore.h"
#import "LAImageLoader.h"


@implementation LANoticeViewController

- (void)viewDidLoad
{ 
    [super viewDidLoad];
    [_navyItem setTitle:@"Notices"];
    
    // Load the NIB files
   // UINib *nib = [UINib nibWithNibName:@"LANoticeItemCell" bundle:nil];
    //Register this NIB which contains the cell
   // [[self tableView]registerNib:nib forCellReuseIdentifier:@"LANoticeItemCell"];

    
    self.peekLeftAmount = 50.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
    
    [[self tableView]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
//    [[self view]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
//    [[self tableView]setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
//    [[self tableView]setSeparatorColor:[UIColor colorWithWhite:0.15f alpha:0.2f]];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    [titleLabel setText:@"Notices"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:25]];
    }
- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int i;
    if ([[[LANoticesStore defaultStore]allItems]count] > 0) {
        i = 1;
    } else {
        i = 0;
    }
    return i;
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[LANoticesStore defaultStore]fetchEntries];
    
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[LANoticesStore defaultStore]allItems]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LANoticeItem *p = [[[LANoticesStore defaultStore]allItems]objectAtIndex:[indexPath row]];
    
    // Get the new or recycled Cell
    // notes might need to alter the item to store different dates as strings
    

    LANoticeItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoticeCell"];
    if (cell == nil)
    {
        cell = [[LANoticeItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                 reuseIdentifier:@"NoticeCell"];
    }
    [cell setController:self];
    [cell setTableView:tableView];
    
    // Configure the cell..
//    if ([p isAnAd]==1) {
//        [cell setTitleLabel:nil];
//        [cell setBriefDescriptionLabel:nil];
//        PFImageView *creature = [[PFImageView alloc] init];
//        creature.image = [UIImage imageNamed:@"1.jpg"]; // placeholder image
//        creature.file = (PFFile *)file;
//        [creature loadInBackground];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:@"Default"];
//        imageView.frame = CGRectMake(6.5, 6.5, 65., 65.);
//        [cell addSubview:imageView];
//        
//    }
    [[cell titleLabel]setText:[p noticeTitle]];
    [[cell titleLabel]setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    [[cell briefDescriptionLabel]setText:[p noticeContent]];
    [[cell briefDescriptionLabel]setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
//    [[cell dateLabel]setText:[NSString stringWithFormat:@"%@", [p startDate]]];//[NSString stringWithFormat:@"$%d", [p valueInDollars]]];
//    // need to format date
//    [[cell dateLabel]setFont:[UIFont fontWithName:@"Roboto-Light" size:15]];
    
    if (![[p noticeImageUrl] length] == 0)
    {
        // Set image to nil, in case the cell was reused.
        [cell setThumbnailImage:nil];
        [[LAImageLoader sharedManager]processImageDataWithURLString:[p noticeImageUrl]
                                                              forId:[[p postObject]objectId]
                                                           andBlock:^(UIImage *image)
        {
             if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath])
             {
                 [[cell thumbnailImage]setImage:image];
                 
             }}];
    } else {
        [[cell thumbnailImage]setImage:nil];
    }
return cell;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //test the placement of this a little bit
        //[[self tableView] reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)aTableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    LADetailNoticeViewController *detailViewController = [[LADetailNoticeViewController alloc]init];
    
    NSArray *items = [[LANoticesStore defaultStore]allItems];
    
    LANoticeItem *selectedItem = [items objectAtIndex:[indexPath row]];
    
    // Give detail view controller a pointer to the item object in row
    [detailViewController setItem:selectedItem];
    
    // Push it onto the top of the navigation controller's stack
    [[self navigationController]pushViewController:detailViewController
                                          animated:YES];
    //[[self storyboard]instantiateViewControllerWithIdentifier:@"detailNotices"];
    
//    if (!([cellName isEqualToString:@"Feed"]))//||[cellName isEqualToString:@"Logout"]
//    {
//        NSString *identifier = @"WebView";
//        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
//        
//        LAWebViewController *webView = (LAWebViewController *)anotherTopViewController;
//        
//        [webView setTitleName:cellName];
//        [webView setUrl:[_sitesList objectForKey:[[self menuItems]objectAtIndex:[indexPath row]]]];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//    }else if([cellName isEqualToString:@"Feed"]){
//        
//        anotherTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:cellName];
//        
//    } else {
//        //[[LAStoreManager sharedManager]logout];
//    }
//    
//    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
//        CGRect frame = self.slidingViewController.topViewController.view.frame;
//        self.slidingViewController.topViewController = anotherTopViewController;
//        self.slidingViewController.topViewController.view.frame = frame;
//        [self.slidingViewController resetTopView];
//    }];
//
}

@end
