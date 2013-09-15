//
//  LAPostItem.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LAUser.h"

@interface LAPostItem : NSObject

@property (nonatomic, strong) PFObject *postObject;
@property (nonatomic, strong) NSDate   *postTime;
@property (nonatomic, strong) NSString *socialNetwork;
@property (nonatomic, strong) NSString *socialNetworkPostID;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, strong) NSString *userLastName;
@property (nonatomic, strong) NSString *gradeLevel;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *iconString;
@property (nonatomic, strong) NSString *iconColor;

//@property (nonatomic, strong) LAUser   *postUser;
@property (assign) BOOL isLikedByThisUser;


@end
