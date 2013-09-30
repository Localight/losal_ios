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
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

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
    self = [super init];
    if (self)
    {
        likesItems = [[NSMutableArray alloc]init];
        // need to create a store for each of these indivdually
        hashtagsAndPostsItems = [[NSMutableArray alloc]init];
        uniqueHashtagsItems = [[NSMutableArray alloc]init];
        mainPostItems = [[NSMutableArray alloc]init];
        _currentUser = [[LAUser alloc]init];
    }
    return self;
}

#pragma mark Settings

- (void)getSettingsWithCompletion:(void(^)(NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppSettings"];
    [query whereKey:@"school" equalTo:@"Losal"];
    
    NSError *error;
    NSArray *objects = [query findObjects:&error];
    if (!error && [objects count] > 0)
    {
        PFObject *appSettings = [objects lastObject];
        _settings = [[LASettings alloc]init];
        [[self settings]setQueryIntervalDays:[[appSettings objectForKey:@"queryIntervalDays"] intValue]];
        NSLog(@"%d",[[self settings]queryIntervalDays]);
        [[self settings]setSchoolName:[appSettings objectForKey:@"school"]];
        
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
                     /// not sure why he had this in here, it doesn't make sense if it doesn't have something in there why put it in their?
                if ([uniqueHashtagsItems indexOfObject:[item hasttag]]== NSNotFound) {
                    [uniqueHashtagsItems addObject:[item hasttag]];
                }
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
//    [self getUserLikesWithCompletion:^(NSError *error) {
//        if (error) {
//            completionBlock(nil, error);
//        } else {
    
    
   
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    
    [query orderByDescending:@"postTime"];
    // what the hell is this for?
    NSTimeInterval interval =  [[[LAStoreManager defaultStore]settings]queryIntervalDays] * -1 * 24 * 60 * 60;
    NSLog(@"%f",interval);
    NSDate *startDate = date;
    
    NSDate *endDate = [startDate dateByAddingTimeInterval:interval];
    
    [query whereKey:@"postTime" lessThan:startDate];
    [query whereKey:@"postTime" greaterThan:endDate];
    [query whereKey:@"status" equalTo:@"1"];
    [query includeKey:@"user"];
    
    // populate the array with post items, and then.. just hold onto it till we need it.
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error)
     {
         
         if (!error)
         {
            NSLog(@"parse was queried at %@ and the size of the array is %lu.",[NSDate date], (unsigned long)[posts count]);
             for (PFObject *post in posts)
             {
                
                 // This does not require a network access.
//                 NSLog(@"post looks like %@", post);
                 LAPostItem *postItem = [[LAPostItem alloc] init];
                 
//               [postItem setPostObject:post];
                 [postItem setPostTime:[post objectForKey:@"postTime"]];
                 [postItem setSocialNetwork:[post objectForKey:@"socialNetworkName"]];
                 [postItem setSocialNetworkPostID:[post objectForKey:@"socialNetworkPostID"]];
                 [postItem setText:[post objectForKey:@"text"]];
                 [postItem setImageURLString:[post objectForKey:@"url"]];
                 [postItem setIsLikedByThisUser:[[LAStoreManager defaultStore]doesThisUserLike:[post objectId]]];
                 
                 PFObject *user = [post objectForKey:@"user"];
                 if (user != nil)
                 {
//                     NSLog(@"user is %@", user);
                     // postItem.postUser = [[LAUser alloc] init];
                     [postItem setPrefix:[user objectForKey:@"prefix"]];//if they have a prefix
                     [postItem setGradeLevel:[user objectForKey:@"year"]];//if they have a grade.
                     // the following sets up the user's display name.
                     [postItem setUserFirstName:[user objectForKey:@"firstName"]];
                     [postItem setUserLastName:[user objectForKey:@"lastName"]];
                     [postItem setIconString:[user objectForKey:@"icon"]];
                     [postItem setUserColorChoice:[self colorFromHexString:[user objectForKey:@"faveColor"]]];
                     [postItem setUserCategory:[user objectForKey:@"userType"]];//find out what they are
                 }
                  [mainPostItems addObject:postItem];
                 
             }
            NSLog(@"the size of the mainpostitems is now from outside the block:%lu",(unsigned long)[mainPostItems count]);
         }else {
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
         [[NSNotificationCenter defaultCenter]
          postNotificationName:@"Reload"
          object:self];
         _lastPostInArray  = [mainPostItems lastObject];
     }];
        NSLog(@"the size of the mainpostitems is now from outside the block: %lu",(unsigned long)[mainPostItems count]);
}
- (void)getFeedWithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock
{
    [self getFeedFromDate:[NSDate date] WithCompletion:^(NSArray *posts, NSError *error) {
        completionBlock(posts, error);
    }];
}

//- (void)getFeedWithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock
//{
//    [self getFeedFromDate:[NSDate date] WithCompletion:^(NSArray *posts, NSError *error)
//    {
//        completionBlock(posts, error);
//    }];
//}
- (void)processArray:(NSMutableArray *)array
{
    if ([array count] > 0)
    {
        NSLog(@" the length of the array before %lu",(unsigned long)[mainPostItems count]);
        [mainPostItems addObjectsFromArray:array];
        NSLog(@"the length of the array after %lu",(unsigned long)[mainPostItems count]);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"Reload"
         object:self];
        //self.filteredObjects = [self filterObjects:self.objects];
    } else {
        [self setMoreResultsAvail:NO];
    }
    [self setLoading:NO];
    // Always remember to set loading to NO whenever you finish loading the data.
//    [self.tableView reloadData];
        // Always remember to set loading to NO whenever you finish loading the data.
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
        PFQuery *likesQuery = [PFQuery queryWithClassName:@"Likes"];
//         [query whereKey:@"username" equalTo:phoneNumber];
    
    if ([[[LAStoreManager defaultStore]currentUser]userVerified])
    {
        [likesQuery whereKey:@"userID" equalTo:[PFUser currentUser]];
        
        [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
            if (!error)
            {
                for (PFObject *like in likes)
                {
                    PFObject *post = [like objectForKey:@"postID"];
                    
                    [likesItems addObject:[post objectId]];
                }
                completionBlock(error);
            }
        }];
    } else{
        NSLog(@"user isn't verifed no ""likes"" for you");
    }
    
}
- (NSArray *)allMainPostItems
{
    return mainPostItems;
}

- (NSArray *)allPostItems
{
    return postItems;
}
- (NSArray *)allLikeItems
{
    return likesItems;
    
}
- (NSArray *)allHashtagAndPostItems
{
    return hashtagsAndPostsItems;
    
}
- (NSArray *)allUniqueHashtags
{
    return uniqueHashtagsItems;
    
}
//TODO: rename this unlikepost, and change accordingly
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
//TODO: consoalidate this to another part
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
//- (void)saveUsersSocialIDs
//{
//    if (self.currentUser.twitterID != nil) {
//        [[PFUser currentUser] setObject:self.currentUser.twitterID forKey:@"twitterID"];
//    }
//    if (self.currentUser.facebookID != nil) {
//        [[PFUser currentUser] setObject:self.currentUser.facebookID forKey:@"facebookID"];
//    }
//    if (self.currentUser.instagramID != nil) {
//        [[PFUser currentUser] setObject:self.currentUser.instagramID forKey:@"instagramID"];
//    }
//    
//    [[PFUser currentUser]saveEventually];
//}

// change flag for number verified here. 
- (BOOL)verifyPhoneNumberIsValid:(NSString *)phoneNumber
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    
    [query whereKey:@"username" equalTo:phoneNumber];
    
    // need to come back and clean this up
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error)
        {
            NSLog(@"This user has a number in the DataBase");
            [_currentUser setUserVerified:YES];
        }else{
            NSLog(@"This user does not have a number in the DataBase and the error is: %@", error);
        }
    }];
    return [_currentUser userVerified];
}

//this part sends for the number
// step 1 send the request for the text message.

//this works fine too.
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
        NSString *replyString = [[NSString alloc] initWithBytes:[reply bytes]
                                                         length:[reply length]
                                                       encoding: NSASCIIStringEncoding];
        NSLog(@"Reply: %@", replyString);
    }];

}
- (void)loginWithPhoneNumber
{
//    // I might want to take this out.
//    [PFUser logOut];
//    PFUser *currentUser1 = [PFUser currentUser]; // this will now be nil
//    
//    NSLog(@"%@",currentUser1);
//    PFUser *user = [[PFUser alloc]init];
//    [user setUsername:[_currentUser phoneNumber]];
//    [user setPassword:[_currentUser pinNumberFromUrl]];
    // if that doesn't work try this
    // [user setUsername:[_current useNameFromParse;
    // [user setPasword: [_currnet userPaswordFromParse;

    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin"
                                                                            accessGroup:nil];
//    PFUser *p = [[PFUser alloc]init];
//    
//    [p setPassword:];
//    [p setUsername:];
//
//    [[PFUser currentUser]setPassword:[_currentUser pinNumberFromUrl]];
//    [[PFUser currentUser]setUsername:[_currentUser phoneNumber]];
    // need to get the password passed some how, getting errors with that.
    //TODO: come back to and make all of the user attributes NSDefualts.
    
    [PFUser logInWithUsernameInBackground:[keychainItem objectForKey:(__bridge id)kSecAttrAccount]
                                 password:[keychainItem objectForKey:(__bridge id)(kSecValueData)]
                                    block:^(PFUser *user, NSError *error)
    {
        NSLog(@"this is the pfusers current password, it should be the pass word from parse: %@",[[PFUser currentUser]password]);
        NSLog(@"about to contact parse for userdata");
        if (user)
        {
            [_currentUser setIconString:[user objectForKey:@"icon"]];
            [_currentUser setIconColor:[self colorFromHexString:[user objectForKey:@"faveColor"]]];
            
            [_currentUser setTwitterDisplayName:[user objectForKey:@"twitterID"]];
            [_currentUser setInstagramDisplayName:[user objectForKey:@"instagramID"]];
            [_currentUser setTwitterUserID:[user objectForKey:@"userInstagramId"]];
            [_currentUser setInstagramUserID:[user objectForKey:@"userTwitterId"]];
            [_currentUser setUserCategory:[user objectForKey:@"userType"]];
            
            [_currentUser setObjectID:[user objectForKey:@"objectID"]];
            [_currentUser setFirstName:[user objectForKey:@"firstName"]];
            [_currentUser setLastName:[user objectForKey:@"lastName"]];
            [_currentUser setPrefix:[user objectForKey:@"prefix"]];
            [_currentUser setUserVerified:YES];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"Reload"
             object:self];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"updateUserDisplay"
             object:self];
            
            NSLog(@"the user logged in.");
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"DissmisView"
             object:self];

        }else{
            NSLog(@"whoops, something happened.");
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
// this works fine.
-(UIColor *)colorFromHexString:(NSString *)hexString
{
    NSUInteger red, green, blue;
    sscanf([hexString UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    return (color);
}
// not sure if we ever get this.
- (void)logout {
    [PFUser logOut];
    self.currentUser = nil;
}
// we could use this method to revalidate;
// we could say if the


@end
