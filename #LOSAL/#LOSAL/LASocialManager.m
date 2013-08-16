//
//  LASocialManager.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/14/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASocialManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "LAStoreManager.h"

@interface LASocialManager ()

#define INSTAGRAM_ID @"64392b8719fb49f59f71213ed640fb68"

@property (strong, nonatomic) LAStoreManager *storeManager;
@property (strong, nonatomic) Instagram *instagram;
@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, strong) ACAccount *facebookAccount;
@end

@implementation LASocialManager

+ (id)sharedManager
{
    static LASocialManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    if (self = [super init]) {
        self.instagram = [[Instagram alloc] initWithClientId:INSTAGRAM_ID
                                                    delegate:nil];
        self.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
        self.instagram.sessionDelegate = self;
        
        self.storeManager = [LAStoreManager sharedManager];
    }
    return self;
}

#pragma - GENERAL
- (BOOL)isSessionValidForNetwork:(NSString *)socialNetwork {
    if ([socialNetwork isEqualToString:@"Twitter"]) {
        return [self twitterSessionIsValid];
    } else if ([socialNetwork isEqualToString:@"Facebook"]) {
        return [self facebookSessionIsValid];
    } else if ([socialNetwork isEqualToString:@"Instagram"]) {
        return [self instagramSessionIsValid];
    }
}

- (void)likePostItem:(LAPostItem *)postItem {
    if ([postItem.socialNetwork isEqualToString:@"Twitter"]) {
        [self twitterFavoriteTweet:postItem.socialNetworkPostID];
    } else if ([postItem.socialNetwork isEqualToString:@"Facebook"]) {
        [self facebookLikePost:postItem.socialNetworkPostID];
    } else if ([postItem.socialNetwork isEqualToString:@"Instagram"]) {
        [self instagramLikePost:postItem.socialNetworkPostID];
    }
}
- (void)unLikePostItem:(LAPostItem *)postItem {
    if ([postItem.socialNetwork isEqualToString:@"Twitter"]) {
        [self twitterUnFavoriteTweet:postItem.socialNetworkPostID];
    } else if ([postItem.socialNetwork isEqualToString:@"Facebook"]) {
        [self facebookLikePost:postItem.socialNetworkPostID];
    } else if ([postItem.socialNetwork isEqualToString:@"Instagram"]) {
        [self instagramUnLikePost:postItem.socialNetworkPostID];
    }
}

#pragma - TWITTER
- (BOOL)twitterSessionIsValid {
    if ([self.storeManager getUser].twitterID != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (void)twitterLogin {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];

        [accountStore requestAccessToAccountsWithType:twitterAccountType
                                              options:NULL
                                           completion:^(BOOL granted, NSError *error)
         {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];
                 self.twitterAccount = [twitterAccounts objectAtIndex:0];
                 [self.storeManager getUser].twitterID = self.twitterAccount.username;
                 [self.storeManager saveUsersSocialIDs];
                 [self.delegate twitterDidLogin];
             } else {
                 NSLog(@"%@", [error localizedDescription]);
                 [self.delegate twitterDidReceiveAnError:@"Please make sure you have configured your twitter account in Settings."];
             }
         }];
    }
}

-(void)twitterLogout {
    self.twitterAccount = nil;
    [self.delegate twitterDidLogout];
}

- (void) twitterFavoriteTweet:(NSString *)tweetID {
    [self twitterSetFavoriteTo:YES forTweet:tweetID];
}
- (void) twitterUnFavoriteTweet:(NSString *)tweetID {
    [self twitterSetFavoriteTo:NO forTweet:tweetID];
}

- (void) twitterSetFavoriteTo:(BOOL)isFavorite forTweet:(NSString *)tweetID {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:twitterAccountType
                                              options:NULL
                                           completion:^(BOOL granted, NSError *error)
         {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];
                 self.twitterAccount = [twitterAccounts objectAtIndex:0];
                 NSString *methodURL;
                 if (isFavorite) {
                     methodURL = @"https://api.twitter.com/1.1/favorites/create.json";
                 } else {
                     methodURL = @"https://api.twitter.com/1.1/favorites/destroy.json";
                 }
                 NSURL *url = [NSURL URLWithString:methodURL];
                 NSDictionary *params = @{@"id" : tweetID};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:self.twitterAccount];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         NSError *jsonError;
                         NSDictionary *timelineData =
                         [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSJSONReadingAllowFragments error:&jsonError];
                         
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             
                             
                             if (timelineData) {
                                 NSLog(@"Timeline Response: %@\n", timelineData);

                             }
                             else {
                                 // Our JSON deserialization went awry
                                 NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                             }
                         }
                         else {
                             // The server did not respond successfully... were we rate-limited?
                             NSLog(@"The response status code is %d and response is %@", urlResponse.statusCode, timelineData);
                             if (self.delegate != nil) {
                                 [self.delegate twitterDidReceiveAnError:@"There was an error favoriting this tweet."];
                             }
                         }
                     }
                 }];
             } else {
                 NSLog(@"%@", [error localizedDescription]);
                 [self.delegate twitterDidReceiveAnError:@"Please go to settings and set up Twitter and allow #LOSAL to use your account."];
             }
         }];
    }
    //  Step 0: Check that the user has local Twitter accounts
    if (self.twitterSessionIsValid) {
        
        
    }
}

#pragma - FACEBOOK
- (BOOL)facebookSessionIsValid {
    if (self.facebookAccount != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (void)facebookLogin {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        // Specify App ID and permissions
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"149510731911579",
                                  ACFacebookPermissionsKey: @[@"publish_stream"],
                                  ACFacebookAudienceKey: ACFacebookAudienceEveryone
                                  };

        [accountStore requestAccessToAccountsWithType:facebookAccountType
                                              options:options
                                           completion:^(BOOL granted, NSError *error)
         {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *facebookAccounts =
                 [accountStore accountsWithAccountType:facebookAccountType];
                 self.facebookAccount = [facebookAccounts objectAtIndex:0];
                 NSLog(@"facebook account is %@", self.facebookAccount);
                 [self.delegate facebookDidLogin];
             } else {
                 NSLog(@"%@", [error localizedDescription]);
                 [self.delegate facebookDidReceiveAnError];
             }
         }];
    }
}

-(void)facebookLogout {
    self.facebookAccount = nil;
    [self.delegate facebookDidLogout];
}

- (void) facebookLikePost:(NSString *)postID {
    //  Step 0: Check that the user has local Twitter accounts
    if (self.facebookSessionIsValid) {
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                      @"/1.1/favorites/create.json"];
        NSDictionary *params = @{@"id" : postID};
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                requestMethod:SLRequestMethodPOST
                                                          URL:url
                                                   parameters:params];
        
        //  Attach an account to the request
        [request setAccount:self.facebookAccount];
        
        //  Step 3:  Execute the request
        [request performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
            if (responseData) {
                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                    NSError *jsonError;
                    NSDictionary *timelineData =
                    [NSJSONSerialization
                     JSONObjectWithData:responseData
                     options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (timelineData) {
                        NSLog(@"Timeline Response: %@\n", timelineData);
                    }
                    else {
                        // Our JSON deserialization went awry
                        NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                    }
                }
                else {
                    // The server did not respond successfully... were we rate-limited?
                    NSLog(@"The response status code is %d", urlResponse.statusCode);
                    [self.delegate facebookDidReceiveAnError];
                }
            }
        }];
        
    }
}

#pragma - INSTAGRAM
-(BOOL)instagramhandleOpenURL:(NSURL *)url {
    return ([self.instagram handleOpenURL:url]);
}

- (BOOL)instagramSessionIsValid {
    return [self.instagram isSessionValid];
}

-(void)instagramLikePost:(NSString *)postID {
    [self instagramSetLikeTo:YES forPost:postID];
}

-(void)instagramUnLikePost:(NSString *)postID {
    [self instagramSetLikeTo:NO forPost:postID];
}

-(void)instagramSetLikeTo:(BOOL)isLIked forPost:(NSString *)postID {
    
    NSString *methodName = [NSString stringWithFormat:@"/media/%@/likes", postID];
    NSMutableDictionary *emptyParams = [[NSMutableDictionary alloc] init];
    NSString *method;
    if (isLIked) {
        method = @"POST";
    } else {
        method = @"DEL";
    }
    [self.instagram requestWithMethodName:methodName params:emptyParams httpMethod:@"POST" delegate:self];
}

- (void)instagramLogin {
    [self.instagram authorize:[NSArray arrayWithObjects:@"likes", nil]];
}

- (void)instagramLogout {
    [self.instagram logout];
}

#pragma - INSTAGRAM IGSessionDelegate
-(void)igDidLogin {
    NSLog(@"Instagram did login");
    // here i can store accessToken
    [[NSUserDefaults standardUserDefaults] setObject:self.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate instagramDidLogin];
    
}

-(void)igDidLogout {
    [self.delegate instagramDidLogout];
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    
    [self.delegate instagramDidReceiveAnError];
}

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    [self.delegate instagramDidReceiveAnError];
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSLog(@"Instagram did load: %@", result);

    [self.delegate instagramDidLoad:result];
}

@end
