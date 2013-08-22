//
//  LADataLoader.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/22/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAFeedViewController.h"

@interface LADataLoader : UIColor

@property (strong, nonatomic) LAFeedViewController *delegate;
- (void)loadDataFromDate:(NSDate *)date;

@end
