//
//  LASocialManager.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/14/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Instagram.h"
#include "LAPostItem.h"

@protocol LASocialManagerDelegate;

@interface LASocialManager : NSObject <IGSessionDelegate, IGRequestDelegate>

@property (nonatomic, strong) id<LASocialManagerDelegate>delegate;

+ (id)sharedManager;

- (BOOL)isSessionValidForNetwork:(NSString *)socialNetwork;
- (void)likePostItem:(LAPostItem *)postItem;
- (void)unLikePostItem:(LAPostItem *)postItem;

- (BOOL)twitterSessionIsValid;
- (void)twitterLogin;
- (void)twitterLogout;
- (void)twitterFavoriteTweet:(NSString *)tweetID;
- (void)twitterUnFavoriteTweet:(NSString *)tweetID;

- (BOOL)facebookSessionIsValid;
- (void)facebookLogin;
- (void)facebookLogout;
- (void)facebookLikePost:(NSString *)postID;

- (BOOL)instagramhandleOpenURL:(NSURL *)url;
- (BOOL)instagramSessionIsValid;
- (void)instagramLogin;
- (void)instagramLogout;
- (void)instagramUnLikePost:(NSString *)postID;
@end

@protocol LASocialManagerDelegate <NSObject>

@optional
- (void)twitterDidLogin;
- (void)twitterDidLogout;
- (void)twitterDidReceiveAnError:(NSString *)errorMessage;

- (void)facebookDidLogin;
- (void)facebookDidLogout;
- (void)facebookDidReceiveAnError;

- (void)instagramDidLogin;
- (void)instagramDidLogout;
- (void)instagramDidReceiveAnError;
- (void)instagramDidLoad:(id)result;
@end


