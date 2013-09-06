//
//  LAParseManager.m
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//
// Where are the posts being stored? -James
#import "LAStoreManager.h"
#import <Parse/Parse.h>
#import "LAHashtagAndPost.h"

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
    if (self = [super init])
    {
        // Parse initialization
        [Parse setApplicationId:@"zFi294oXTVT6vj6Tfed5heeF6XPmutl0y1Rf7syg"
                      clientKey:@"jyL9eoOizsJqQK5KtADNX5ILpjgSdP6jW9Lz1nAU"];
        
        //[PFUser enableAutomaticUser];
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

#pragma mark Settings

- (void)getSettingsWithCompletion:(void(^)(NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppSettings"];
    [query whereKey:@"school" equalTo:@"Losal"];
    
    NSError *error;
    NSArray *objects = [query findObjects:&error];
    if (!error && [objects count] > 0) {
        PFObject *appSettings = [objects lastObject];
        self.settings = [[LASettings alloc] init];
        self.settings.queryIntervalDays = [[appSettings objectForKey:@"queryIntervalDays"] intValue];
        self.settings.schoolName = [appSettings objectForKey:@"school"];
        PFFile *backgroundFile = [appSettings objectForKey:@"backgroundImage"];
        NSData *data = [backgroundFile getData:&error];
        if (error) {
            NSLog(@"Could not download background image");
        } else {
            self.settings.backgroundImage = [UIImage imageWithData:data];
        }
    }
    completionBlock(error);
}

#pragma mark Posts
- (void)getHashTags {
    
    PFQuery *query = [PFQuery queryWithClassName:@"HashTags"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *hashtags, NSError *error) {
        if (!error) {
            self.hashtagsAndPosts = [[NSMutableArray alloc] init];
            self.uniqueHashtags = [[NSMutableArray alloc] init];
            for (PFObject *hashtag in hashtags) {
                LAHashtagAndPost *hashtagAndPost = [[LAHashtagAndPost alloc] init];
                hashtagAndPost.hasttag = [hashtag objectForKey:@"hashTag"];
                hashtagAndPost.postID = [hashtag objectForKey:@"postID"];
                [self.hashtagsAndPosts addObject:hashtagAndPost];
                
                if ([self.uniqueHashtags indexOfObject:hashtagAndPost.hasttag] == NSNotFound) {
                    [self.uniqueHashtags addObject:hashtagAndPost.hasttag];
                }
            }
        }
    }];
}

- (void)getFeedFromDate:(NSDate *)date
         WithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock
{
    [self getUserLikesWithCompletion:^(NSError *error)
    {
        if (error) {
            completionBlock(nil, error);
        } else {
            PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
            
            [query orderByDescending:@"postTime"];
            
            NSTimeInterval interval = self.settings.queryIntervalDays * -1 * 24 * 60 * 60;
            
            NSDate *startDate = date;
            
            NSDate *endDate = [startDate dateByAddingTimeInterval:interval];
            
            [query whereKey:@"postTime" lessThan:startDate];
            [query whereKey:@"postTime" greaterThan:endDate];
            [query whereKey:@"status" equalTo:@"1"];
            [query includeKey:@"user"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error)
             {
                 NSMutableArray *messages = nil;
                 
                 if (!error) {
                     messages = [[NSMutableArray alloc] init];
                     for (PFObject *post in posts) {
                         // This does not require a network access.
                         NSLog(@"post looks like %@", post);
                         LAPostItem *postItem = [[LAPostItem alloc] init];
                         [postItem setPostObject:post];
                         
                         //postItem.postObject = post;// this line is weird
                         postItem.postTime = [post objectForKey:@"postTime"];
                         postItem.socialNetwork = [post objectForKey:@"socialNetworkName"];
                         postItem.socialNetworkPostID = [post objectForKey:@"socialNetworkPostID"];
                         postItem.text = [post objectForKey:@"text"];
                         postItem.imageURLString = [post objectForKey:@"url"];
                         postItem.isLikedByThisUser = [self doesThisUserLike:post.objectId];
                         
                         // Only copy user information if this is a verified user
                         if (self.thisUser != nil) {
                             PFObject *user = [post objectForKey:@"user"];
                             if (user != nil) {
                                 NSLog(@"user is %@", user);
                                 postItem.postUser = [[LAUser alloc] init];
                                 postItem.postUser.grade = [user objectForKey:@"year"];
                                 postItem.postUser.firstName = [user objectForKey:@"firstName"];
                                 postItem.postUser.lastName = [user objectForKey:@"lastName"];
                                 postItem.postUser.icon = [user objectForKey:@"icon"];
                                 postItem.postUser.iconColor = [user objectForKey:@"faveColor"];
                             }
                         }
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

- (void)getFeedWithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock
{
    [self getFeedFromDate:[NSDate date] WithCompletion:^(NSArray *posts, NSError *error)
    {
        completionBlock(posts, error);
    }];
}

#pragma mark Likes
- (BOOL)doesThisUserLike:(NSString *)postID {
    BOOL doesUserLikePost = [self.likes containsObject:postID];
    return doesUserLikePost;
}

- (void) getUserLikesWithCompletion:(void(^)(NSError *error))completionBlock
{
    self.likes = [[NSMutableArray alloc] init];
    // Now get all likes for user if user is already set
    if ([PFUser currentUser]) {
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
}

- (void)deleteUsersLike:(PFObject *)postObject
{    
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query whereKey:@"postID" equalTo:postObject];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        for (PFObject *like in likes) {
            [like deleteEventually];
        }
    }];
}

- (void)saveUsersLike:(PFObject *)postObject
{    
    PFObject *like = [PFObject objectWithClassName:@"Likes"];
    [like setObject:[PFUser currentUser] forKey:@"userID"];
    [like setObject:postObject forKey:@"postID"];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [likeACL setPublicReadAccess:YES];
    like.ACL = likeACL;
    
    [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error saving users like error is %@", error);
        }
    }];
}

#pragma mark User
- (LAUser *)getUser {
    if (self.thisUser == nil) {
        if ([PFUser currentUser].objectId != nil) {
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
        } else {
            [PFUser enableAutomaticUser];
        }
    }
    return self.thisUser;
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

- (void)verifyPhoneNumberIsValid:(NSString *)phoneNumber
                  withCompletion:(void(^)(bool isValid))completionBlock {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:phoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *user, NSError *error) {
        BOOL isValid = NO;
        if (!error) {
            if ([user count] > 0) {
                isValid = YES;
            }
        }
        completionBlock(isValid);   
    }];
}

- (void)sendRegistrationRequestForPhoneNumber:(NSString *)phoneNumber {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSString *urlString = @"https://api.parse.com/1/functions/register";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"zFi294oXTVT6vj6Tfed5heeF6XPmutl0y1Rf7syg" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"gyMlPJBhaRG0SV083c3n7ApzsjLnvvbLvXKW0jJm" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *requestString = [NSString stringWithFormat:@"phone=%@", phoneNumber];
    NSData *requestData = [ NSData dataWithBytes: [ requestString UTF8String ] length: [ requestString length ] ];
    [request setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *reply, NSError *error) {
        NSString *replyString = [[NSString alloc] initWithBytes:[reply bytes] length:[reply length] encoding: NSASCIIStringEncoding];
        NSLog(@"Reply: %@", replyString);
    }];
}

- (BOOL)loginWithPhoneNumber:(NSString *)phoneNumber pinNumber:(NSString *)pinNumber {
    
    NSError *error;
    [PFUser logInWithUsername:phoneNumber password:pinNumber error:&error];
    
    if(error) {
        return NO;
    } else {
        [self getUser]; // will store user data in self.thisUser
        return YES;
    }
}

- (void)logout {
    [PFUser logOut];
    self.thisUser = nil;
}
@end
