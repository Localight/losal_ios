//
//  LAImageStore.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAImageStore : NSObject
{
    NSMutableDictionary *dictionary;
}
+ (LAImageStore *)defaultImageStore;

- (void)setImage:(UIImage *)i forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (void)deleteImageForKey:(NSString *)s;
- (NSString *)imagePathForKey:(NSString *)key;
@end
