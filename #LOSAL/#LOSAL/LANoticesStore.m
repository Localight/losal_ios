//
//  LANoticesStore.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LANoticesStore.h"
#import "LANoticeItem.h"
#import "LAUtilities.h"
#import "LAStoreManager.h"
#import <Parse/Parse.h>

@implementation LANoticesStore

+ (LANoticesStore *)defaultStore
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
    if (self) {
        NSString *path = [self itemArchivePath];
        _allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If the array hadn't been saved previously, create a new empty one
        if(!_allItems)
            _allItems = [[NSMutableArray alloc] init];
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

- (void)updateEntries
{
    // empty the entries in case this gets re-fired
    [self.allItems removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    
    /* note: kept for #REFERENCE, in case we throttle notices by date on the iOS side
     [query orderByDescending:@"createAt"];
     [query whereKey:@"startDate" lessThan:[NSDate date]];
     [query whereKey:@"endDate" greaterThan:[NSDate date]];
     */
    
    [query orderByDescending:@"ad"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseNoticeArray, NSError *error) {
        if (!error) {
            for (PFObject *parseNoticeObject in parseNoticeArray)
            {
                LANoticeItem *p = [[LANoticeItem alloc] initWithnoticeObject:parseNoticeObject
                                                                 NoticeTitle:[parseNoticeObject objectForKey:@"title"]
                                                               noticeContent:[parseNoticeObject objectForKey:@"description"]];
                
                NSString *number = [parseNoticeObject objectForKey:@"ad"];
                [p setIsAnAd:[number boolValue]];
                [p setInterestField:[parseNoticeObject objectForKey:@"audienceInterests"]];
                [p setAudienceTypes:[parseNoticeObject objectForKey:@"audienceTypes"]];
                [p setTeaserText:[parseNoticeObject objectForKey:@"teaser"]];
                [p setStartDate:[parseNoticeObject objectForKey:@"startDate"]];
                [p setEndDate:[parseNoticeObject objectForKey:@"endDate"]];
                [p setButtonLink:[parseNoticeObject objectForKey:@"buttonLink"]];
                [p setButtonText:[parseNoticeObject objectForKey:@"buttonText"]];
                
                NSString *rawNoticeImageURL = [parseNoticeObject objectForKey:@"image"];
                
                [p setNoticeImageUrl:[LAUtilities cleanedURLStringFromString:rawNoticeImageURL]];
                
                if (![p isAnAd])
                    // if this is not an ad, always add the object to the array
                    [self.allItems addObject:p];
                else {
                    // if this is an ad, determine if it's the correct targeted audience according
                    // to current user type
                    BOOL targetedAudienceMatch = NO;
                    NSString *userCategory = [[[LAStoreManager defaultStore] currentUser] userCategory];
                    
                    if (([[p audienceTypes] isEqualToString:@"Students"]) &&
                        ([userCategory isEqualToString:@"Student"]))
                        targetedAudienceMatch = YES;
                    
                    if ((![[p audienceTypes] isEqualToString:@"Students"]) &&
                        (![userCategory isEqualToString:@"Student"]))
                        targetedAudienceMatch = YES;
                    
                    if (targetedAudienceMatch)
                        [self.allItems addObject:p];
                }
            }
        }
        else
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
    }];
}

@end
