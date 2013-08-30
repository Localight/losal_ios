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
    self.delegate.fetchBatch ++;
    [[LAStoreManager sharedManager] getFeedFromDate:date
                                     WithCompletion:^(NSArray *array, NSError *error)
    {
        NSLog(@"Loaded more data");
        if (!error)
        {
            if ([array count] > 0) {
                [self.delegate.objects addObjectsFromArray:array];
            } else {
                self.delegate.moreResultsAvail = NO;
            }
            [self.delegate.tableView reloadData];
            // Always remember to set loading to NO whenever you finish loading the data.
            self.delegate.loading = NO;
        }
    }];
}

@end
