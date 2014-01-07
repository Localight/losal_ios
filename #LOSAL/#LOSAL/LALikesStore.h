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

+ (LALikesStore *)defaultStore;

- (void)getUserLikesWithCompletion:(void(^)(NSError *error))completionBlock;
- (void)saveUsersLike:(PFObject *)postObject;
- (void)deleteUsersLike:(PFObject *)postObject;
- (BOOL)doesThisUserLike:(NSString *)postID;

@end
