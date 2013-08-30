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
{
    NSMutableArray *allItems;

}
+ (LANoticesStore *)defaultStore;

- (void)removeItem:(LANoticeItem *)p;

- (NSArray *)allItems;

- (LANoticeItem *)createItem;

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to;

- (NSString *)itemArchivePath;

- (BOOL)saveChanges;

@end
