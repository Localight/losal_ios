//
//  LAColor+Hex.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/22/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    
    NSUInteger red, green, blue;
    sscanf([hexString UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    return (color);
}

@end
