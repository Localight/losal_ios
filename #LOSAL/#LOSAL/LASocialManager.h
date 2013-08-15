//
//  LASocialManager.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/14/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Instagram.h"

@protocol LASocialManagerDelegate;

@interface LASocialManager : NSObject <IGSessionDelegate, IGRequestDelegate>

@property (nonatomic, weak) id<LASocialManagerDelegate>delegate;

+ (id)sharedManager;

- (BOOL)twitterSessionIsValid;
- (void)twitterLogin;
- (void)twitterLogout;
- (void)twitterFavoriteTweet:(NSString *)tweetID;

- (BOOL)facebookSessionsIsValid;
- (void)facebookLogin;
- (void)facebookLogout;
- (void)facebookLikePost:(NSString *)postID;

- (BOOL)instagramhandleOpenURL:(NSURL *)url;
- (BOOL)instagramSessionIsValid;
- (void)instagramLogin;
- (void)instagramLogout;

@end

@protocol LASocialManagerDelegate <NSObject>

- (void)twitterDidLogin;
- (void)twitterDidLogout;
- (void)twitterDidReceiveAnError;

- (void)facebookDidLogin;
- (void)facebookDidLogout;
- (void)facebookDidReceiveAnError;

- (void)instagramDidLogin;
- (void)instagramDidLogout;
- (void)instagramDidReceiveAnError;
- (void)instagramDidLoad:(id)result;
@end


