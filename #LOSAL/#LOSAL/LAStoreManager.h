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
{
    
    //contains an array of the filterd posts related to a hashtag
    NSMutableArray *hashtagsAndPostsItems;
    NSMutableArray *uniqueHashtagsItems;
    // contains an array of post for the main feed
    NSMutableArray *mainPostItems;
}
@property (nonatomic, strong)LAPostItem *lastPostInArray;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL moreResultsAvail;
@property (weak, nonatomic) id controller;
@property (nonatomic, strong) LASettings *settings;
//@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) LAUser *currentUser;

+ (LAStoreManager *)defaultStore;
- (void)sortHashTagsWithFilter:(NSString *)filter;
- (void)fetchFromDate:(NSDate *)aDate;
//       WithCompletion:(void(^)(NSArray *posts, NSError *error))completionBlock;
- (NSArray *)allHashtagAndPostItems;
- (NSArray *)allMainPostItems;
- (NSArray *)allUniqueHashtagsItems;
//- (LAUser *)createUser;
 
//- (void)trackOpen:(NSDictionary *)launchOptions;
- (void)clearAllMainPostItems;

- (void)processArray:(NSArray *)array;



- (void)getSettingsWithCompletion:(void(^)(NSError *error))completionBlock;
//- (void)saveUsersSocialIDs;
- (void)getHashTags;


- (void)sendRegistrationRequestForPhoneNumber:(NSString *)phoneNumber;
- (BOOL)verifyPhoneNumberIsValid:(NSString *)phoneNumber;

- (void)loginWithPhoneNumber;
- (void)logout;

@end
