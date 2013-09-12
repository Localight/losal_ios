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
#import "LAUser.h"
@interface LAStoreManager ()
@property (nonatomic, strong) PFUser *user;


@end

@implementation LAStoreManager

#pragma mark Singleton Methods

+ (LAStoreManager *)defaultStore
{
    static LAStoreManager *defaultStore = nil;
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
    if (self = [super init])
    {
        userContainerItems = [[NSMutableArray alloc]init];
        likesItems = [[NSMutableArray alloc]init];
        hashtagsAndPostsItems = [[NSMutableArray alloc]init];
        uniqueHashtagsItems = [[NSMutableArray alloc]init];
//        //[PFUser enableAutomaticUser];
//        PFACL *defaultACL = [PFACL ACL];
//        
//        // Enable public read access by default, with any newly created PFObjects belonging to the current user
//        
//        [defaultACL setPublicReadAccess:YES];
//        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
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
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *hashtagsArray, NSError *error) {
       
        if (!error)
        {
            for (PFObject *hashtag in hashtagsArray)
            {
                LAHashtagAndPost *item = [[LAHashtagAndPost alloc] init];
                [item setHasttag:[hashtag objectForKey:@"hashTag"]];
                [item setPostID:[hashtag objectForKey:@"postID"]];
                [hashtagsAndPostsItems addObject:item];
                     // not sure why he had this in here, it doesn't make sense if it doesn't have something in there why put it in their?
//                if ([self.uniqueHashtags indexOfObject:hashtagAndPost.hasttag] == NSNotFound) {
//                    [self.uniqueHashtags addObject:hashtagAndPost.hasttag];
//                }
            }
        }else{
            //TODO: not sure i did this part right might need to come back too.
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:errorString
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
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
                         [postItem setPostTime:[post objectForKey:@"postTime"]];
                         [postItem setSocialNetwork:[post objectForKey:@"socialNetworkName"]];
                         [postItem setSocialNetworkPostID:[post objectForKey:@"socialNetworkPostID"]];
                         [postItem setText:[post objectForKey:@"text"]];
                         [postItem setImageURLString:[post objectForKey:@"url"]];
                         [postItem setIsLikedByThisUser:[self doesThisUserLike:[post objectId]]];
                         
                         // Only copy user information if this is a verified user
                         // if this user isn't verified then they won't have this info to begin with.-james
                         if (self.thisUser != nil) {
                             PFObject *user = [post objectForKey:@"user"];
                             if (user != nil) {
                                 NSLog(@"user is %@", user);
                                 postItem.postUser = [[LAUser alloc] init];
                                 postItem.postUser.grade = [user objectForKey:@"year"];
                                 postItem.postUser.firstName = [user objectForKey:@"firstName"];
                                 postItem.postUser.lastName = [user objectForKey:@"lastName"];
                                 postItem.postUser.iconString = [user objectForKey:@"icon"];
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
- (BOOL)doesThisUserLike:(NSString *)postID
{
    BOOL doesUserLikePost = [likesItems containsObject:postID];
    
    return doesUserLikePost;
}

- (void) getUserLikesWithCompletion:(void(^)(NSError *error))completionBlock
{
    // Now get all likes for user if user is already set
    if ([PFUser currentUser])
    {
        PFQuery *likesQuery = [PFQuery queryWithClassName:@"Likes"];
        
        [likesQuery whereKey:@"userID" equalTo:[PFUser currentUser]];
        
        [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
            if (!error) {
                for (PFObject *like in likes)
                {
                    PFObject *post = [like objectForKey:@"postID"];
                    [likesItems addObject:[post objectId]];
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
    //TODO: need to look at this closer
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
// our issues are here

//TODO: still have no idea what this is even for.
- (LAUser *)getUser
{
    if (self.thisUser == nil)
    {
        if ([PFUser currentUser].objectId != nil)
        {
            
//            self.thisUser = [[LAUser alloc] init];
            
            PFQuery *query = [PFUser query];
            
            
            [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
            
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error)
             {
                 NSMutableArray *messages = nil;
                 if (!error) {
                     messages = [[NSMutableArray alloc] init];
                     for (PFObject *user in users)
                     {
                        
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
//TODO: come back and finish the LAUser our thoughts was to have the store manager create a new lAuser Object, and if the user isn't verified, to do a normal alloc init. if the user is verified, then use the info from parse to create the new LAUser object. 
- (void)saveUsersSocialIDs
{
    
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

// change flag for number verified here. 
- (BOOL)verifyPhoneNumberIsValid:(NSString *)phoneNumber
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:phoneNumber equalTo:@"username"];
    // need to come back and clean this up
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"This user has a number in the DataBase");
            [_thisUser setUserVerified:YES];
        }else{
            [_thisUser setUserVerified:NO];
        }
    }];
    return [_thisUser userVerified];
}

//this part sends for the number
// step 1 send the request for the text message. 
- (void)sendRegistrationRequestForPhoneNumber:(NSString *)phoneNumber {
   
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSString *urlString = @"https://api.parse.com/1/functions/register";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"zFi294oXTVT6vj6Tfed5heeF6XPmutl0y1Rf7syg"
   forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"gyMlPJBhaRG0SV083c3n7ApzsjLnvvbLvXKW0jJm"
    forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"application/x-www-form-urlencoded"
   forHTTPHeaderField:@"Content-Type"];
    
    NSString *requestString = [NSString stringWithFormat:@"phone=%@", phoneNumber];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String]length:[requestString length]];
    [request setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *reply, NSError *error) {
        NSString *replyString = [[NSString alloc] initWithBytes:[reply bytes] length:[reply length] encoding: NSASCIIStringEncoding];
        NSLog(@"Reply: %@", replyString);
    }];
}

- (void)loginWithPhoneNumber;
{
    NSLog(@"%@ INFO about our user", _user);

    [PFUser logInWithUsernameInBackground:[_thisUser phoneNumber]
                                 password:[_thisUser pinNumberFromUrl]
                                    block:^(PFUser *user, NSError *error){
        if (user)
        {
            NSScanner *scanner = [NSScanner scannerWithString:[user objectForKey:@"icon"]];
            unsigned int code;
            [scanner scanHexInt:&code];
            [_thisUser setIconString:[NSString stringWithFormat:@"%C", (unsigned short)code]];
            [_thisUser setIconColor:[self colorFromHexString:[user objectForKey:@"faveColor"]]];
            [_thisUser setFirstName:[user objectForKey:@"firstName"]];
            [_thisUser setLastName:[user objectForKey:@"lastName"]];
        }else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:errorString
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
}
-(UIColor *)colorFromHexString:(NSString *)hexString
{
    NSUInteger red, green, blue;
    sscanf([hexString UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    return (color);
}

- (void)logout {
    [PFUser logOut];
    self.thisUser = nil;
}
@end
