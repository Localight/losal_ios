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

@interface LASocialManager ()

#define INSTAGRAM_ID @"64392b8719fb49f59f71213ed640fb68"

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
    }
    return self;
}

#pragma - TWITTER
- (BOOL)twitterSessionIsValid {
    return(self.twitterAccount != nil);
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
                 [self.delegate twitterDidLogin];
             } else {
                 NSLog(@"%@", [error localizedDescription]);
                 [self.delegate twitterDidReceiveAnError];
             }
         }];
    }
}

-(void)twitterLogout {
    self.twitterAccount = nil;
    [self.delegate twitterDidLogout];
}

- (void) twitterFavoriteTweet:(NSString *)tweetID {
    //  Step 0: Check that the user has local Twitter accounts
    if (self.twitterSessionIsValid) {
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                      @"/1.1/favorites/create.json"];
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
                    [self.delegate twitterDidReceiveAnError];
                }
            }
        }];
        
    }
}

#pragma - FACEBOOK
- (BOOL)facebookSessionsIsValid {
    return(self.twitterAccount != nil);
}

- (void)facebookLogin {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        // Specify App ID and permissions
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"149510731911579",
                                  ACFacebookPermissionsKey: @[@"email"],
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
    if (self.facebookSessionsIsValid) {
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                      @"/1.1/favorites/create.json"];
        NSDictionary *params = @{@"id" : postID};
        
        NSDictionary *options = @{
                                  ACFacebookAppIdKey: @"552649564758410",
                                  ACFacebookPermissionsKey: @[@"publish_stream"],
                                  ACFacebookAudienceKey: ACFacebookAudienceFriends
                                  };

        
        SLRequest *request =
        [SLRequest requestForServiceType:SLServiceTypeFacebook
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
                    [self.delegate twitterDidReceiveAnError];
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
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self", @"method", nil];
    [self.instagram requestWithParams:params delegate:self];
    
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
