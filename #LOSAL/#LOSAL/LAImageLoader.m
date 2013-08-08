//
//  LAImageLoader.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/7/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAImageLoader.h"

@interface LAImageLoader ()

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSCache *testCache;
@end

@implementation LAImageLoader

+ (id)sharedManager
{
    static LAImageLoader *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id) init {
    if (self = [super init]) {
        self.imageCache = [[NSCache alloc] init];
        self.testCache = [[NSCache alloc] init];
    }
    
    return self;
}

- (void)processImageDataWithURLString:(NSString *)urlString forId:(NSString *)imageId andBlock:(void (^)(UIImage *image))processImage
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Look for existing image
    NSString *test = [self.testCache objectForKey:imageId];
    if (test != nil)
        NSLog(@"test cache for %@ is %@", imageId, test);
    UIImage * image = [self.imageCache objectForKey:imageId];
    if (image != nil) {
        processImage(image);
    } else {
        dispatch_queue_t callerQueue = dispatch_get_current_queue();
        dispatch_queue_t asyncQueue = dispatch_queue_create("com.myapp.asyncqueue", NULL);
        dispatch_async(asyncQueue, ^{
            NSError *error;
            NSData *imageData = [NSData dataWithContentsOfURL:url options:nil error:&error];
            if (error) {
                NSLog(@"Could not download photo for id %@", imageId);
            } else {
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(callerQueue, ^{
                    [self.imageCache setObject:image forKey:imageId];
                    [self.testCache setObject:imageId forKey:imageId];
                    NSLog(@"Downloaded %@ for id %@", imageId);                    
                    processImage(image);
                });
            }
        });
    }
}

@end