//
//  LAPostItem.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAPostItem.h"

@implementation LAPostItem

-(BOOL)CheckForImage
{
    BOOL check = NO;
    
    if ([[self imageURLString]length] == 0)
    {
        check = YES;
    }
return check;
}
@end
