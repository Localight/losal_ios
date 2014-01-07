//
//  LANoticesStore.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LANoticeItem;

@interface LANoticesStore : NSObject

@property (nonatomic, strong) NSMutableArray *allItems;

+ (LANoticesStore *)defaultStore;

- (void)updateEntries;

@end
