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
#import <Parse/Parse.h>

@class LAUser;

@interface LAStoreManager : NSObject

@property (nonatomic, strong) NSMutableArray *allHashtagAndPostItems;
@property (nonatomic, strong) NSMutableArray *allMainPostItems;
@property (nonatomic, strong) NSMutableArray *allUniqueHashtagsItems;

@property (nonatomic, strong)LAPostItem *lastPostInArray;
@property (nonatomic) BOOL moreResultsAvail;
@property (weak, nonatomic) id controller;
@property (nonatomic, strong) LASettings *settings;
@property (nonatomic, strong) LAUser *currentUser;

@property BOOL awaitingTextMessageLoginResponse;

+ (LAStoreManager *)defaultStore;

- (void)fetchFromDate:(NSDate *)aDate matchingHashtagFilter:(NSString *)hashtagFilter;
- (void)clearAllMainPostItems;
- (void)getSettingsWithCompletion:(void(^)(NSError *error))completionBlock;
- (void)saveUsersSocialIDs;
- (void)getHashTags;
- (void)sendRegistrationRequestForPhoneNumber:(NSString *)phoneNumber;
- (void)loginWithPhoneNumber;
- (void)logout;

@end
