//
//  LAUtilities.h
//  #LOSAL
//
//  Created by Justin Schottlaender on 11/10/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAUtilities : NSObject

+ (NSString *)cleanedURLStringFromString:(NSString *)baseString;
+ (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
+ (unsigned int)intFromHexString:(NSString *)hexStr;

@end
