//
//  LAPostItem.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLImageView.h"

@interface LAPostItem : NSObject

@property (nonatomic, strong) NSDate *postTime;
@property (nonatomic, strong) NSString *socialNetwork;
@property (nonatomic, strong) NSString *socialNetworkPostID;
@property (nonatomic, strong) FLImageView *postImage;
@property (nonatomic, strong) NSString *text;

@end
