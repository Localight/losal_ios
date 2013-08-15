//
//  LAParseManager.m
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAStoreManager.h"
#import <Parse/Parse.h>

@interface LAStoreManager ()

@property (nonatomic, strong) LAUser *thisUser;
@property (nonatomic, strong) NSMutableArray *likes;

@end

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
        [Parse setApplicationId:@"zFi294oXTVT6vj6Tfed5heeF6XPmutl0y1Rf7syg" clientKey:@"jyL9eoOizsJqQK5KtADNX5ILpjgSdP6jW9Lz1nAU"];
        
        //[PFUser enableAutomaticUser];
        
        PFACL *defaultACL = [PFACL ACL];
        // Enable public read access by default, with any newly created PFObjects belonging to the current user
        [defaultACL setPublicReadAccess:YES];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
        
        self.likes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)trackOpen:(NSDictionary *)launchOptions
{
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

- (void)getFeedWithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock
{
    [self getUserLikesWithCompletion:^(NSError *error) {
        if (error) {
            completionBlock(nil, error);
        } else {
            PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
            query.limit = 50;
            [query orderByDescending:@"postTime"];
            [query whereKey:@"status" equalTo:@"1"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error)
             {
                 NSMutableArray *messages = nil;
                 if (!error) {
                     messages = [[NSMutableArray alloc] init];
                     for (PFObject *post in posts) {
                         // This does not require a network access.
                         NSLog(@"post looks like %@", post);
                         LAPostItem *postItem = [[LAPostItem alloc] init];
                         postItem.postID = [post objectId];
                         postItem.postTime = [post objectForKey:@"postTime"];
                         postItem.socialNetwork = [post objectForKey:@"socialNetworkName"];
                         postItem.socialNetworkPostID = [post objectForKey:@"socialNetworkPostID"];
                         postItem.text = [post objectForKey:@"text"];
                         postItem.imageURLString = [post objectForKey:@"url"];
                         postItem.isLikedByThisUser = [self doesThisUserLike:post.objectId];
                         [messages addObject:postItem];
                     }
                 } else {
                     // Log details of the failure
                     NSLog(@"Error: %@ %@", error, [error userInfo]);
                 }
                 completionBlock(messages, error);
             }];
        }
    }];
}

- (BOOL)doesThisUserLike:(NSString *)postID {
    BOOL doesUserLikePost = [self.likes containsObject:postID];
    return doesUserLikePost;
}

- (LAUser *)getUser {
    if (self.thisUser == nil) {
        if ([PFUser currentUser]) {
            self.thisUser = [[LAUser alloc] init];
            PFQuery *query = [PFUser query];
            [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error)
             {
                 NSMutableArray *messages = nil;
                 if (!error) {
                     messages = [[NSMutableArray alloc] init];
                     for (PFObject *user in users) {
                         self.thisUser.twitterID = [user objectForKey:@"twitterID"];
                         self.thisUser.facebookID = [user objectForKey:@"facebookID"];
                         self.thisUser.instagramID = [user objectForKey:@"instagramID"];
                     }
                 }
             }];
        }
    }
    return self.thisUser;
}

- (void) getUserLikesWithCompletion:(void(^)(NSError *error))completionBlock {
    // Now get all likes for user
    PFQuery *likesQuery = [PFQuery queryWithClassName:@"Likes"];
    [likesQuery whereKey:@"userID" equalTo:[PFUser currentUser]];
    [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        if (!error) {
            for (PFObject *like in likes) {
                PFObject *post = [like objectForKey:@"postID"];
                [self.likes addObject:post.objectId];
            }
            completionBlock(error);
        }
    }];
     
}
- (void)saveUsersSocialIDs {
    
    if (self.thisUser.twitterID != nil) {
        [[PFUser currentUser] setObject:self.thisUser.twitterID forKey:@"twitterID"];
    }
    if (self.thisUser.facebookID != nil) {
        [[PFUser currentUser] setObject:self.thisUser.facebookID forKey:@"facebookID"];
    }
    if (self.thisUser.instagramID != nil) {
        [[PFUser currentUser] setObject:self.thisUser.instagramID forKey:@"instagramID"];
    }
    
    [[PFUser currentUser]saveEventually];
}

- (BOOL)loginWithPhoneNumber:(NSString *)phoneNumber pinNumber:(NSString *)pinNumber {
    
    NSError *error;
    [PFUser logInWithUsername:phoneNumber password:pinNumber error:&error];
    
    if(error) {
        return NO;
    } else {
        return YES;
    }
}

- (void)logout {
    [PFUser logOut];
}
@end
