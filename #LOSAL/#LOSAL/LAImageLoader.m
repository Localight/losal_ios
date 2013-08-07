//
//  LAImageLoader.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/7/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAImageLoader.h"

@interface LAImageLoader ()

@property (nonatomic, strong) NSMutableDictionary *existingImages;
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
        self.existingImages = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)processImageDataWithURLString:(NSString *)urlString forId:(NSString *)imageId andBlock:(void (^)(UIImage *image))processImage
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Look for existing image
    UIImage * image = [self.existingImages objectForKey:imageId];
    if (image != nil) {
        processImage(image);
    } else {
        dispatch_queue_t callerQueue = dispatch_get_current_queue();
        dispatch_queue_t asyncQueue = dispatch_queue_create("com.myapp.asyncqueue", NULL);
        dispatch_async(asyncQueue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            [self.existingImages addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:image,imageId, nil]];
            dispatch_async(callerQueue, ^{
                processImage(image);
            });
        });
    }
}

@end