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
@class LAUser;

@interface LAStoreManager : NSObject
{
    NSMutableArray *likesItems;
    NSMutableArray *hashtagsAndPostsItems;
    NSMutableArray *uniqueHashtagsItems;
    NSMutableArray *postItems;
    NSMutableArray *mainPostItems;
}
@property (weak, nonatomic) id controller;
@property (nonatomic, strong) LASettings *settings;
//@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) LAUser *currentUser;

+ (LAStoreManager *)defaultStore;

- (NSArray *)allLikeItems;
- (NSArray *)allHashtagAndPostItems;
- (NSArray *)allUniqueHashtags;
- (NSArray *)allPostItems;
- (NSArray *)allMainPostItems;
//- (LAUser *)createUser;

//- (void)trackOpen:(NSDictionary *)launchOptions;

- (void)getHashTags;

- (void)getSettingsWithCompletion:(void(^)(NSError *error))completionBlock;

- (void)getFeedFromDate:(NSDate *)date WithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock;

- (void)getFeedWithCompletion:(void (^)(NSArray *posts, NSError *error))completionBlock;

//- (void)saveUsersSocialIDs;

- (void)saveUsersLike:(PFObject *)postObject;

- (void)deleteUsersLike:(PFObject *)postObject;

- (void)sendRegistrationRequestForPhoneNumber:(NSString *)phoneNumber;
- (BOOL)verifyPhoneNumberIsValid:(NSString *)phoneNumber;
- (void)reValidateUser;
- (void)loginWithPhoneNumber;
- (void)logout;

@end
