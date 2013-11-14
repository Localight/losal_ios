//
//  LAParseManager.m
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//
// Where are the posts being stored? -James
#import "LAStoreManager.h"

#import "LAHashtagAndPost.h"
#import "LAUser.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
#import "LALikesStore.h"

@implementation LAStoreManager
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
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
//What makes the most sense, if for us to pass a type of string and then pass that it in as a parameter. We know we are going t
// to need some kind of sort..
#pragma mark Posts
// this loads all the hashtags and the posts objects as pfobjcts
- (void)getHashTags{
    
    PFQuery *query = [PFQuery queryWithClassName:@"HashTagsIndex"];
    
    [query includeKey:@"postId"];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *hashtagsArray, NSError *error)
    {
        if (!error)
        {
            for (PFObject *hashtag in hashtagsArray)
            {
                
                LAHashtagAndPost *item = [[LAHashtagAndPost alloc] init];
                
                [item setHashTag:[hashtag objectForKey:@"hashTags"]];
                NSLog(@"%@",item);
                
                item = [hashtag objectForKey:@"postId"];
                NSLog(@"%@",item);
                
                
                PFObject *user = [hashtag objectForKey:@"user"];
                
                if (user != nil)
                {
                    [item setPrefix:[user objectForKey:@"prefix"]];//if they have a prefix
                    NSLog(@"%@",item);
                    [item setGradeLevel:[user objectForKey:@"year"]];//if they have a grade.
                    NSLog(@"%@",item);
                    [item setUserFirstName:[user objectForKey:@"firstName"]];
                    NSLog(@"%@",item);
                    [item setUserLastName:[user objectForKey:@"lastName"]];
                    NSLog(@"%@",item);
                    [item setIconString:[user objectForKey:@"icon"]];
                    NSLog(@"%@",item);
                    [item setUserColorChoice:[self getUIColorObjectFromHexString:[user objectForKey:@"faveColor"] alpha:1]];
                    NSLog(@"%@",item);
                    [item setUserCategory:[user objectForKey:@"userType"]];//find out what they are
                } else{
                    NSLog(@"No user for this account: %@", item);
                }
                
               // [item setIsLikedByThisUser:[[LALikesStore defaultStore]doesThisUserLike:[hashtag objectId]]];
                
                if (item)
                    [hashtagsAndPostsItems addObject:item];
                
                NSString *thisHashTag = [hashtag objectForKey:@"hashTags"];
                
                if ([uniqueHashtagsItems indexOfObject:thisHashTag] == NSNotFound)
                    [uniqueHashtagsItems addObject:thisHashTag];
            }
            /// not sure why he had this in here, it doesn't make sense if it doesn't have something in there why put it in their?
            
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

- (void)sortHashTagsWithFilter:(NSString *)filter
{
   
    [[LAStoreManager defaultStore]clearAllMainPostItems];

    for (filter in hashtagsAndPostsItems)
    {
        
        LAHashtagAndPost *aPost = [[LAHashtagAndPost alloc]init];
        
        LAPostItem *postItem = [[LAPostItem alloc]init];
        [postItem setPostTime: [aPost postTime]];
        [postItem setSocialNetworkPostID:[aPost socialNetworkPostID]];
        [postItem setSocialNetwork:[aPost socialNetwork]];
        [postItem setText:[aPost text]];
        [postItem setImageURLString:[aPost imageURLString]];
        [postItem setIsLikedByThisUser:[aPost isLikedByThisUser]];
        [postItem setPrefix:[aPost prefix]];
        [postItem setGradeLevel:[aPost gradeLevel]];
        [postItem setUserFirstName:[aPost userFirstName]];
        [postItem setUserLastName:[aPost userLastName]];
        [postItem setIconString:[aPost iconString]];
        [postItem setUserColorChoice:[aPost userColorChoice]];
        [postItem setUserCategory:[aPost userCategory]];
        
        [mainPostItems addObject:postItem];
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"Reload"
     object:self];
    _lastPostInArray  = [mainPostItems lastObject];
}
- (void)clearAllMainPostItems
{
    [mainPostItems removeAllObjects];
}
- (void)fetchFromDate:(NSDate *)aDate
//       WithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock
{
    if (!aDate){
        aDate= [NSDate date];
    }
        PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
        [query orderByDescending:@"postTime"];
        // what the hell is this for?
        NSTimeInterval interval =  [[[LAStoreManager defaultStore]settings]queryIntervalDays] * -1 * 24 * 60 * 60;
        NSLog(@"%f",interval);
    
        NSDate *endDate = [aDate dateByAddingTimeInterval:interval];
    
        [query whereKey:@"postTime" lessThan:aDate];
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
                 
                    [postItem setPostObject:post];
                    [postItem setPostTime:[post objectForKey:@"postTime"]];
                    [postItem setSocialNetwork:[post objectForKey:@"socialNetworkName"]];
                    [postItem setSocialNetworkPostID:[post objectForKey:@"socialNetworkPostID"]];
                    [postItem setText:[post objectForKey:@"text"]];
                    [postItem setImageURLString:[post objectForKey:@"url"]];
                    [postItem setIsLikedByThisUser:[[LALikesStore defaultStore]doesThisUserLike:[post objectId]]];
                 
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
                        [postItem setUserColorChoice:[self getUIColorObjectFromHexString:[user objectForKey:@"faveColor"] alpha:1]];
                       // [postItem setUserColorChoice:[self colorFromHexString:[user objectForKey:@"faveColor"]]];
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
   
}
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

- (NSArray *)allUniqueHashtagsItems
{
    return uniqueHashtagsItems;
}
- (NSArray *)allMainPostItems
{
    return mainPostItems;
}
- (NSArray *)allHashtagAndPostItems
{
    return hashtagsAndPostsItems;
    
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

    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin"
                                                                            accessGroup:nil];
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
            NSLog(@"%@", [user objectForKey:@"faveColor"]);\
            [_currentUser setIconColor:[self getUIColorObjectFromHexString:[user objectForKey:@"faveColor"]
                                                                     alpha:1]];
            //[_currentUser setIconColor:[self colorFromHexString:[user objectForKey:@"faveColor"]]];
            
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
- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}
- (void)logout {
    [PFUser logOut];
    self.currentUser = nil;
}
// we could use this method to revalidate;
// we could say if the


@end
