//
//  LASettings.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/19/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LASettings : NSObject

@property (assign) int queryIntervalDays;
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) UIImage *backgroundImage;

@end
