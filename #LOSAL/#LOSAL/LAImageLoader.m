//
//  LAImageLoader.m
//  #LOSAL
//
//  Created by Joaquin Brown on 8/7/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAImageLoader.h"

@interface LAImageLoader ()

@end

@implementation LAImageLoader

+ (id)sharedManager
{
    static LAImageLoader *sharedMyManager= nil;
    if (!sharedMyManager) {
        
        // Create the singleton
        sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _imageCache = [[NSCache alloc]init];
        
    }
    return self;
}

- (void)processImageDataWithURLString:(NSString *)urlString
                                forId:(NSString *)imageId
                             andBlock:(void (^)(UIImage *image))processImage
{
    // so you are checking if an image got passed and didn't have an image string.
    // is this necessary?
    
    // first grab the url, because we know the images is coming from a url
    NSURL *url = [NSURL URLWithString:urlString];
    
    // check to see if this image has been used all ready.
    
    // Look for existing image
    
    UIImage * image = [self.imageCache objectForKey:imageId];
    if (image != nil) {
        processImage(image);
    } else {
        if (!url)
            return;
        
        dispatch_queue_t callerQueue = dispatch_get_main_queue();
        dispatch_queue_t asyncQueue = dispatch_queue_create("com.myapp.asyncqueue", NULL);
        dispatch_async(asyncQueue, ^{
            NSError *error;
            NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
            
            UIImage *image = nil;
            if (error || [self isImageValid:imageData] == NO) {
                NSLog(@"Could not download photo for id %@ url %@", imageId, url);
            } else {
                image = [UIImage imageWithData:imageData];
                if (image == nil) {
                    NSLog(@"Image is nil for id %@ url %@", imageId, url);
                } else {
                    [self.imageCache setObject:image forKey:imageId];
                }
            }
            dispatch_async(callerQueue, ^{
                processImage(image);
            });
        });
    }
}
// This method works well for jpegs, might need to modify for pngs
- (BOOL)isImageValid:(NSData *)imageData {
    if ([imageData length] < 4) return NO;
    const unsigned char * bytes = (const unsigned char *)[imageData bytes];
    if (bytes[0] != 0xFF || bytes[1] != 0xD8) return NO;
    if (bytes[[imageData length] - 2] != 0xFF ||
        bytes[[imageData length] - 1] != 0xD9) return NO;
    return YES;
}

@end