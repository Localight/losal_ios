//
//  LAParseManager.h
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LASettings.h"
#import "LAPostItem.h"
#import "LAUser.h"

@interface LAStoreManager : NSObject

@property (nonatomic, strong) NSMutableArray *hashtagsAndPosts;
@property (nonatomic, strong) NSMutableArray *uniqueHashtags;
@property (nonatomic, strong) LASettings *settings;

+ (id)sharedManager;

- (void)trackOpen:(NSDictionary *)launchOptions;

- (void)getHashTags;

- (void)getSettingsWithCompletion:(void(^)(NSError *error))completionBlock;

- (void)getFeedFromDate:(NSDate *)date WithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock;

- (void)getFeedWithCompletion:(void (^)(NSArray *posts, NSError *error))completionBlock;

- (LAUser *)getUser;

- (void)saveUsersSocialIDs;

- (void)saveUsersLike:(PFObject *)postObject;
- (void)deleteUsersLike:(PFObject *)postObject;

- (void)sendRegistrationRequestForPhoneNumber:(NSString *)phoneNumber;
- (void)verifyPhoneNumberIsValid:(NSString *)phoneNumber withCompletion:(void(^)(bool isValid))completionBlock;
- (BOOL)loginWithPhoneNumber:(NSString *)phoneNumber pinNumber:(NSString *)pinNumber;

- (void)logout;

@end
