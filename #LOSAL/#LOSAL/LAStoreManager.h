//
//  LAParseManager.h
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LAPostItem.h"
#import "LAUser.h"

@interface LAStoreManager : NSObject

+ (id)sharedManager;

- (void)trackOpen:(NSDictionary *)launchOptions;

- (void)getFeedWithCompletion:(void (^)(NSArray *posts, NSError *error))completionBlock;

- (LAUser *)getUser;

- (void)saveUsersSocialIDs;

- (void)saveUsersLike:(PFObject *)postObject;
- (void)deleteUsersLike:(PFObject *)postObject;

- (BOOL)loginWithPhoneNumber:(NSString *)phoneNumber pinNumber:(NSString *)pinNumber;

- (void)logout;

@end
