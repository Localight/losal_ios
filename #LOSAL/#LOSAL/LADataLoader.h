//
//  LADataLoader.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/22/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAFeedViewController.h"

@protocol LADataLoaderDelegate;

@interface LADataLoader : NSObject

@property (nonatomic, strong) id<LADataLoaderDelegate>delegate;

- (void)loadDataFromDate:(NSDate *)date;

@end

@protocol LADataLoaderDelegate <NSObject>

-(void)processArray:(NSArray *)array;

@end
//TODO: fix the main feed not loading stuff. 


