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
#import "LAUtilities.h"
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

- (void)updateEntries
{
    // we will change this method to update, with in it, we will make sure to check the dates of the posts
      PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    //[query orderByDescending:@"createAt"];
//    [query whereKey:@"startDate" lessThan:[NSDate date]];
//    [query whereKey:@"endDate" greaterThan:[NSDate date]];
    
    // PFObject *myNotices = [[PFObject alloc]init];
    [query orderByDescending:@"ad"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseNoticeArray, NSError *error)
     {
         if (!error)
         {
             for(PFObject *parseNoticeObject in parseNoticeArray)
             {
                 LANoticeItem *p = [[LANoticeItem alloc] initWithnoticeObject:parseNoticeObject
                                                                  NoticeTitle:[parseNoticeObject objectForKey:@"title"]
                                                                noticeContent:[parseNoticeObject objectForKey:@"description"]];
                
                 NSString *number = [parseNoticeObject objectForKey:@"ad"];
                 NSLog(@"%@", number);
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
                 
                                 //[item setThumbnailDataFromImage:image];
                 
                 // possible error will come from above.
                 // This does not require a network access.
                 NSLog(@"notices looks like %@", parseNoticeObject);
                 NSLog(@"image url %@", [parseNoticeObject objectForKey:@"image"]);
                 
                 [allItems addObject:p];
             }
         }else{
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
}

-(UIImage *) getImageFromURL:(NSString *)fileURL
{
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
}

-(void) saveImage:(UIImage *)image
     withFileName:(NSString *)imageName
           ofType:(NSString *)extension
      inDirectory:(NSString *)directoryPath
{
    if ([[extension lowercaseString] isEqualToString:@"png"])
    {
        [UIImagePNGRepresentation(image)writeToFile:[directoryPath
                                                     stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]]
                                            options:NSAtomicWrite
                                              error:nil];
        
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath
                                                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]]
                                                   options:NSAtomicWrite
                                                     error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

- (BOOL)saveChanges
{
    // returns success or failure
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allItems
                                       toFile:path];
}
-(UIImage *) loadImage:(NSString *)fileName
                ofType:(NSString *)extension
           inDirectory:(NSString *)directoryPath
{
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}
- (void)removeItem:(LANoticeItem *)p
{
    //NSString *key = [p imageKey];
   // [[LAImageStore defaultImageStore] deleteImageForKey:key];
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
