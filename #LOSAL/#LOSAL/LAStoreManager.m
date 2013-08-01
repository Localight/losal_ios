//
//  LAParseManager.m
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAStoreManager.h"
#import <Parse/Parse.h>

@implementation LAStoreManager

#pragma mark Singleton Methods

+ (id)sharedManager
{
    static LAStoreManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    if (self = [super init]) {
        // Parse initialization
        [Parse setApplicationId:@"jqFXMdZ9RPlTUXUDWHWD4xw2QwJQDF0Ym3JpC7aO" clientKey:@"O8OkZplDkcCmukrD37rM2kVQVDZzecIzaG5X0llN"];
        
        [PFUser enableAutomaticUser];
        
        PFACL *defaultACL = [PFACL ACL];
        // Enable public read access by default, with any newly created PFObjects belonging to the current user
        [defaultACL setPublicReadAccess:YES];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    }
    return self;
}

- (void)trackOpen:(NSDictionary *)launchOptions
{
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

- (void)getFeedWithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error)
    {
        NSMutableArray *messages = nil;
         if (!error) {
             messages = [[NSMutableArray alloc] init];
             for (PFObject *post in posts) {
                 // This does not require a network access.
                 NSString *text = [post objectForKey:@"Text"];
                 [messages addObject:text];
             }
         } else {
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
        completionBlock(messages, error);
     }];
}

@end
