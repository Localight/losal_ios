//
//  LADataLoader.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/22/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LADataLoader.h"
#import "LAStoreManager.h"

@implementation LADataLoader

- (void)loadDataFromDate:(NSDate *)date
{
    [[LAStoreManager defaultStore] getFeedFromDate:date WithCompletion:^(NSArray *array, NSError *error)
    {
        NSLog(@"Loaded more data");
        if (!error)
        {
            [self.delegate processArray:array];
        }
    }];
}

@end
