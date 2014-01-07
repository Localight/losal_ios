//
//  LAUser.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/12/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAUser : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *iconStringFromParse;
@property (nonatomic, strong) NSString *iconStringColorFromParse;
@property (nonatomic, strong) NSString *iconString;
@property (nonatomic, strong) UIColor  *iconColor;
@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *grade;
@property (nonatomic, strong) NSString *userCategory;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *filterPref;
@property (nonatomic, strong) NSString *twitterDisplayName;
@property (nonatomic, strong) NSString *instagramDisplayName;
@property (nonatomic, strong) NSString *twitterUserID;
@property (nonatomic, strong) NSString *instagramUserID;
@property (assign) BOOL userVerified;
@property (assign) BOOL waitingForText;
@property (assign) BOOL isFilteredArray;

@end

