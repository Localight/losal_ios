//
//  LAParseManager.h
//  #LOSAL
//
//  Created by Joaquin Brown on 7/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LAPostItem.h"

@interface LAStoreManager : NSObject

+ (id)sharedManager;

- (void)trackOpen:(NSDictionary *)launchOptions;

- (void)getFeedWithCompletion:(void (^)(NSArray *posts, NSError *error))completionBlock;

@end
