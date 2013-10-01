
//
//  LAUser.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/12/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAUser.h"
#define  DEFAULT_ICON "\uE00C"

@implementation LAUser

- (id)initWithDisplayName:(NSString *)name
           userIconString:(NSString *)icon
            userIconColor:(UIColor *)color
{
    self = [super init];
     if(self)
     {
         NSLog(@"Default LAUser was Created.");
         [self setDisplayName:name];
         [self setIconString:icon];
         [self setIconColor:color];
     }
    return self;
}
- (id)init
{
    // set the flag for user verified. 
    [self setUserVerified:NO];
    return [self initWithDisplayName:@"Non-Registered"
                      userIconString:[NSString stringWithUTF8String:DEFAULT_ICON]
                       userIconColor:[UIColor whiteColor]];
}

//    [cell.icon setFont:[UIFont fontWithName:@"icomoon" size:30.0f]];
//
//    if ([postItem.postUser.icon length] > 0) {
//        NSScanner *scanner = [NSScanner scannerWithString:postItem.postUser.icon];
//        unsigned int code;
//        [scanner scanHexInt:&code];
//        cell.icon.text  = [NSString stringWithFormat:@"%C", (unsigned short)code];
//        [cell.icon setTextColor:[self colorFromHexString:postItem.postUser.iconColor]];
//    } else {
//        cell.icon.text = [NSString stringWithUTF8String:DEFAULT_ICON];
//        [cell.icon setTextColor:[UIColor whiteColor]];
//    }

//        //[PFUser enableAutomaticUser];
//        PFACL *defaultACL = [PFACL ACL];
//
//        // Enable public read access by default, with any newly created PFObjects belonging to the current user
//
//        [defaultACL setPublicReadAccess:YES];
//        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
@end
