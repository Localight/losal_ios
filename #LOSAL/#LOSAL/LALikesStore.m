//
//  LALikesStore.m
//  #LOSAL
//
//  Created by James Orion Hall on 9/30/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LALikesStore.h"
#import "LAStoreManager.h"

@interface LALikesStore ()

@property (nonatomic, strong) NSMutableArray *likeItems;

@end

@implementation LALikesStore

+ (LALikesStore *)defaultStore
{
    static LALikesStore *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LALikesStore alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _likeItems = [[NSMutableArray alloc] init];
    }
    return self;
}

//TODO: rename this unlikepost, and change accordingly
- (void)deleteUsersLike:(PFObject *)postObject
{
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query whereKey:@"postID" equalTo:postObject];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        for (PFObject *like in likes) {
            [like deleteEventually];
        }
    }];
}

//TODO: consoalidate this to another part
- (void)saveUsersLike:(PFObject *)postObject
{
    PFObject *like = [PFObject objectWithClassName:@"Likes"];
    [like setObject:[PFUser currentUser] forKey:@"userID"];
    [like setObject:postObject forKey:@"postID"];
    
    // photos are public, but may only be modified by the user who uploaded them
    //TODO: need to look at this closer
    PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [likeACL setPublicReadAccess:YES];
    like.ACL = likeACL;
    
    [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error saving users like error is %@", error);
        }
    }];
}

#pragma mark Likes
- (BOOL)doesThisUserLike:(NSString *)postID
{
    BOOL doesUserLikePost = [self.likeItems containsObject:postID];
    
    return doesUserLikePost;
}

- (void)getUserLikesWithCompletion:(void(^)(NSError *error))completionBlock
{
    // Now get all likes for user if user is already set
    PFQuery *likesQuery = [PFQuery queryWithClassName:@"Likes"];
    
    if ([[[LAStoreManager defaultStore]currentUser]userVerified]) {
        [likesQuery whereKey:@"userID" equalTo:[PFUser currentUser]];
        
        [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
            if (!error)
            {
                for (PFObject *like in likes)
                {
                    PFObject *post = [like objectForKey:@"postID"];
                    
                    [self.likeItems addObject:[post objectId]];
                }
                completionBlock(error);
            }
        }];
    } else {
        NSLog(@"user isn't verifed no ""likes"" for you");
    }
}

@end
