//
//  LAParseManager.m
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAStoreManager.h"
#import "LAHashtagAndPost.h"
#import "KeychainItemWrapper.h"
#import "LALikesStore.h"
#import "LAUtilities.h"

@implementation LAStoreManager

+ (LAStoreManager *)defaultStore
{
    static LAStoreManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LAStoreManager alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // need to create a store for each of these indivdually
        _allHashtagAndPostItems = [[NSMutableArray alloc] init];
        _allMainPostItems = [[NSMutableArray alloc] init];
        _allUniqueHashtagsItems = [[NSMutableArray alloc] init];
        _currentUser = [[LAUser alloc] init];
    }
    return self;
}

#pragma mark Settings
- (void)getSettingsWithCompletion:(void(^)(NSError *error))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"AppSettings"];
    [query whereKey:@"school" equalTo:@"Losal"];
    
    NSError *error;
    NSArray *objects = [query findObjects:&error];
    if (!error && [objects count] > 0) {
        PFObject *appSettings = [objects lastObject];
        _settings = [[LASettings alloc] init];
        [[self settings]setQueryIntervalDays:[[appSettings objectForKey:@"queryIntervalDays"] intValue]];
        NSLog(@"%d",[[self settings]queryIntervalDays]);
        [[self settings]setSchoolName:[appSettings objectForKey:@"school"]];
        
        PFFile *backgroundFile = [appSettings objectForKey:@"backgroundImage"];
        NSData *data = [backgroundFile getData:&error];
        
        if (error)
            NSLog(@"Could not download background image");
        else
            self.settings.backgroundImage = [UIImage imageWithData:data];
    }
    completionBlock(error);
}

#pragma mark Posts
- (void)getHashTags
{
    PFQuery *query = [PFQuery queryWithClassName:@"HashTagsIndex"];
    
    [query includeKey:@"postId"];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *hashtagsArray, NSError *error) {
        if (!error) {
            for (PFObject *hashtag in hashtagsArray)
            {
                LAHashtagAndPost *item = [[LAHashtagAndPost alloc] init];
                
                [item setHashTag:[hashtag objectForKey:@"hashTags"]];
                
                item = [hashtag objectForKey:@"postId"];
                
                PFObject *user = [hashtag objectForKey:@"user"];
                
                if (user) {
                    [item setPrefix:[user objectForKey:@"prefix"]];
                    [item setGradeLevel:[user objectForKey:@"year"]];
                    [item setUserFirstName:[user objectForKey:@"firstName"]];
                    [item setUserLastName:[user objectForKey:@"lastName"]];
                    [item setIconString:[user objectForKey:@"icon"]];
                    [item setUserColorChoice:[LAUtilities getUIColorObjectFromHexString:[user objectForKey:@"faveColor"] alpha:1]];
                    [item setUserCategory:[user objectForKey:@"userType"]];
                }
                else {
                    NSLog(@"No user for this account: %@", item);
                }
                
                if (item)
                    [self.allHashtagAndPostItems addObject:item];
                
                NSString *thisHashTag = [hashtag objectForKey:@"hashTags"];
                
                if ([self.allUniqueHashtagsItems indexOfObject:thisHashTag] == NSNotFound)
                    [self.allUniqueHashtagsItems addObject:thisHashTag];
            }
        }
        else {
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

- (void)clearAllMainPostItems
{
    [self.allMainPostItems removeAllObjects];
}

- (void)fetchFromDate:(NSDate *)aDate matchingHashtagFilter:(NSString *)hashtagFilter
{
    if (!aDate)
        aDate= [NSDate date];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    [query orderByDescending:@"postTime"];

    NSTimeInterval interval =  [[[LAStoreManager defaultStore]settings]queryIntervalDays] * -1 * 24 * 60 * 60;
    NSDate *endDate = [aDate dateByAddingTimeInterval:interval];
    
    [query whereKey:@"postTime" lessThan:aDate];
    [query whereKey:@"postTime" greaterThan:endDate];
    [query whereKey:@"status" equalTo:@"1"];
    [query includeKey:@"user"];
    
    // if a hashtag filter is set, use it
    if (hashtagFilter)
        [query whereKey:@"text" containsString:hashtagFilter];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
         if (!error) {
             for (PFObject *post in posts)
             {
                 LAPostItem *postItem = [[LAPostItem alloc] init];
                 
                 [postItem setPostObject:post];
                 [postItem setPostTime:[post objectForKey:@"postTime"]];
                 [postItem setSocialNetwork:[post objectForKey:@"socialNetworkName"]];
                 [postItem setSocialNetworkPostID:[post objectForKey:@"socialNetworkPostID"]];
                 [postItem setText:[post objectForKey:@"text"]];
                 [postItem setImageURLString:[post objectForKey:@"url"]];
                 [postItem setIsLikedByThisUser:[[LALikesStore defaultStore]doesThisUserLike:[post objectId]]];
                 
                 PFObject *user = [post objectForKey:@"user"];
                 if (user) {
                     [postItem setPrefix:[user objectForKey:@"prefix"]];
                     [postItem setGradeLevel:[user objectForKey:@"year"]];
                     [postItem setUserFirstName:[user objectForKey:@"firstName"]];
                     [postItem setUserLastName:[user objectForKey:@"lastName"]];
                     [postItem setIconString:[user objectForKey:@"icon"]];
                     [postItem setUserColorChoice:[LAUtilities getUIColorObjectFromHexString:[user objectForKey:@"faveColor"] alpha:1]];
                     [postItem setUserCategory:[user objectForKey:@"userType"]];
                 }
                 
                 [self.allMainPostItems addObject:postItem];
             }
         }
         else {
             // If things went bad, show an alert view
             NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", [error localizedDescription]];
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:errorString
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
             [av show];
         }
        
         [[NSNotificationCenter defaultCenter] postNotificationName:@"Reload" object:self];
        
         _lastPostInArray  = [self.allMainPostItems lastObject];
     }];
}

#pragma mark User
- (void)saveUsersSocialIDs
{
    if (self.currentUser.twitterUserID) {
        [[PFUser currentUser] setObject:self.currentUser.twitterDisplayName forKey:@"twitterID"];
        [[PFUser currentUser] setObject:self.currentUser.twitterUserID forKey:@"userTwitterId"];
    }
    
    if (self.currentUser.instagramUserID) {
        [[PFUser currentUser] setObject:self.currentUser.instagramDisplayName forKey:@"instagramID"];
        [[PFUser currentUser] setObject:self.currentUser.instagramUserID forKey:@"userInstagramId"];
    }
    
    [[PFUser currentUser] saveEventually];
}

- (void)sendRegistrationRequestForPhoneNumber:(NSString *)phoneNumber
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSString *urlString = @"https://api.parse.com/1/functions/register";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"zFi294oXTVT6vj6Tfed5heeF6XPmutl0y1Rf7syg" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:@"gyMlPJBhaRG0SV083c3n7ApzsjLnvvbLvXKW0jJm" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *requestString = [NSString stringWithFormat:@"phone=%@", phoneNumber];
    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String]length:[requestString length]];
    [request setHTTPBody:requestData];
    
    __weak typeof(self)weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *reply, NSError *error) {
                               // we've successfully sent the text message request, so mark state as awaiting confirmation
                               weakSelf.awaitingTextMessageLoginResponse = YES;
    }];
}

- (void)loginWithPhoneNumber
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin"
                                                                            accessGroup:nil];
    //TODO: come back to and make all of the user attributes NSDefualts.
    
    __weak typeof(self)weakSelf = self;
    [PFUser logInWithUsernameInBackground:[keychainItem objectForKey:(__bridge id)kSecAttrAccount]
                                 password:[keychainItem objectForKey:(__bridge id)(kSecValueData)]
                                    block:^(PFUser *user, NSError *error) {
        if (user) {
            [_currentUser setIconString:[user objectForKey:@"icon"]];
            [_currentUser setIconColor:[LAUtilities getUIColorObjectFromHexString:[user objectForKey:@"faveColor"] alpha:1]];
            [_currentUser setTwitterDisplayName:[user objectForKey:@"twitterID"]];
            [_currentUser setTwitterUserID:[user objectForKey:@"userTwitterId"]];
            [_currentUser setInstagramDisplayName:[user objectForKey:@"instagramID"]];
            [_currentUser setInstagramUserID:[user objectForKey:@"userInstagramId"]];
            [_currentUser setUserCategory:[user objectForKey:@"userType"]];
            [_currentUser setObjectID:[user objectForKey:@"objectID"]];
            [_currentUser setFirstName:[user objectForKey:@"firstName"]];
            [_currentUser setLastName:[user objectForKey:@"lastName"]];
            [_currentUser setPrefix:[user objectForKey:@"prefix"]];
            [_currentUser setUserVerified:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Reload" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserDisplay" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNotices" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedInDismiss" object:self];

            // we've successfully logged the user in, so mark the state as no longer awaiting confirmation
            weakSelf.awaitingTextMessageLoginResponse = NO;
        }
        else {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:[[error userInfo] objectForKey:@"error"]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
}

- (void)logout
{
    [PFUser logOut];
    self.currentUser = nil;
}

@end
