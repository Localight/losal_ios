//
//  LANoticesStore.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LANoticesStore.h"
#import "LANoticeItem.h"
#import "LAImageStore.h"
#import <Parse/Parse.h>
@implementation LANoticesStore

+(LANoticesStore *)defaultStore
{
    static LANoticesStore *defaultStore = nil;
    if(!defaultStore)
        defaultStore = [[super allocWithZone:nil] init];
    
    return defaultStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

- (id)init
{
    self = [super init];
    if(self) {
        NSString *path = [self itemArchivePath];
        allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If the array hadn't been saved previously, create a new empty one
        if(!allItems)
            allItems = [[NSMutableArray alloc] init];
    }
    return self;
}
- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}
- (void)fetchEntries
{
    // we will change this method to update, with in it, we will make sure to check the dates of the posts
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    [query orderByDescending:@"createAt"];
    
   // PFObject *myNotices = [[PFObject alloc]init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseNoticeArray, NSError *error)
     {
         if (!error)
         {
             for (PFObject *parseNoticeObject in parseNoticeArray)
             {
                 LANoticeItem *p = [[LANoticeItem alloc] initWithnoticeObject:parseNoticeObject
                                                                  NoticeTitle:[parseNoticeObject objectForKey:@"title"]
                                                                noticeContent:[parseNoticeObject objectForKey:@"description"]];
                 // not sure what having a parse object is going to do.
                // [p setPostObject:parseNoticeObject];
                 
                 // This does not require a network access.
                 NSLog(@"notices looks like %@", parseNoticeObject);
//                 [p setNoticeTitle:[parseNoticeObject objectForKey:@"title"]];
//                 [p setNoticeContent:[parseNoticeObject objectForKey:@"description"]];
                 [p setNoticeImageUrl:[parseNoticeObject objectForKey:@"image"]];
                 [allItems addObject:p];
             }
         }else{
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
}
//    self.moreResultsAvail = YES;
//    
//    UIView *currentTitleView = [[self navigationItem] titleView];
//    
//    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]
//                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    [[self navigationItem] setTitleView:aiView];
//    
//    [aiView startAnimating];
//    
//    [[self navigationItem] setTitleView:currentTitleView];
//    
//    [self.storeManager getFeedWithCompletion:^(NSArray *posts, NSError *error)
//     {
//         NSLog(@"Completion block called!");
//         if (!error)
//         {
//             self.objects = [NSMutableArray arrayWithArray:posts];
//             
//             static BOOL firstTime = YES;
//             if (firstTime) {
//                 [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
//                 firstTime = NO;
//             } else {
//                 [[self tableView] reloadData];
//             }
//             
//             NSLog(@"error is %@", error);
//             
//         } else {
//             // If things went bad, show an alert view
//             NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@",
//                                      [error localizedDescription]];
//             
//             // Create and show an alert view with this error displayed
//             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                          message:errorString
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//             [av show];
//             // If you come here you got the array
//             NSLog(@"results are %@", posts);
//         }
//     }];

- (BOOL)saveChanges
{
    // returns success or failure
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allItems
                                       toFile:path];
}

- (void)removeItem:(LANoticeItem *)p
{
    NSString *key = [p imageKey];
    [[LAImageStore defaultImageStore] deleteImageForKey:key];
    [allItems removeObjectIdenticalTo:p];
}

- (NSArray *)allItems
{
    return allItems;
}
- (void)moveItemAtIndex:(int)from
                toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved so we can re-insert it
    LANoticeItem *p = [allItems objectAtIndex:from];
    
    // Remove p from array
    [allItems removeObjectAtIndex:from];
    
    // Insert p in array at new location
    [allItems insertObject:p atIndex:to];
}
//
//- (LANoticeItem *)createItem
//{
//    LANoticeItem *p = [[LANoticeItem alloc] init];
//    
//    [allItems addObject:p];
//    
//    return p;
//}

@end
