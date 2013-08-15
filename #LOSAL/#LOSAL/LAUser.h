//
//  LAUser.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/12/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAUser : NSObject

@property (nonatomic, strong) NSNumber *phoneNumber;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastNumber;
@property (nonatomic, strong) NSNumber *grade;
@property (nonatomic, strong) NSNumber *iconID;
@property (nonatomic, strong) NSNumber *iconColor;
@property (nonatomic, strong) NSDate   *birthday;
@property (nonatomic, strong) NSString *studentID;

@property (nonatomic, strong) NSString *twitterID;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *instagramID;
@end
