//
//  LAHashtagAndPost.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/26/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LAUser.h"
@interface LAHashtagAndPost : NSObject

@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, strong) PFObject *postObject;
@property (nonatomic, strong) NSDate   *postTime;
@property (nonatomic, strong) NSString *socialNetwork;
@property (nonatomic, strong) NSString *socialNetworkPostID;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, strong) NSString *userLastName;
@property (nonatomic, strong) NSString *gradeLevel;
@property (nonatomic, strong) NSString *iconString;
@property (nonatomic, strong) UIColor *userColorChoice;
@property (nonatomic, strong) NSString *userCategory;
@property (nonatomic, strong) LAUser   *postUser;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *prefix;
@property (assign) BOOL isLikedByThisUser;

@end
