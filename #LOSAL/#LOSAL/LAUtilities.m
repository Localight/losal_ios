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

@end
