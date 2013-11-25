//
//  LAUtilities.m
//  #LOSAL
//
//  Created by Justin Schottlaender on 11/10/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAUtilities.h"

@implementation LAUtilities

+ (NSString *)cleanedURLStringFromString:(NSString *)baseString
{
    if ((!baseString) || (baseString.length == 0))
        return baseString;
    
    return [baseString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [LAUtilities intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}

+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

@end
