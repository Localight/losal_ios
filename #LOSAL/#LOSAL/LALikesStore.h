//
//  LALikesStore.h
//  #LOSAL
//
//  Created by James Orion Hall on 9/30/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface LALikesStore : NSObject
{
    // contains an array of the post this user has liked
    NSMutableArray *likeItems;
}

+ (LALikesStore *)defaultStore;

- (NSArray *)allLikeItems;

- (void) getUserLikesWithCompletion:(void(^)(NSError *error))completionBlock;
//- (void)saveUsersSocialIDs;

- (void)saveUsersLike:(PFObject *)postObject;

- (void)deleteUsersLike:(PFObject *)postObject;

- (BOOL)doesThisUserLike:(NSString *)postID;
@end
