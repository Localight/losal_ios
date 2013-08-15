//
//  LAPostItem.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAPostItem : NSObject

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSDate   *postTime;
@property (nonatomic, strong) NSString *socialNetwork;
@property (nonatomic, strong) NSString *socialNetworkPostID;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *text;
@property (assign) BOOL isLikedByThisUser;


@end
