//
//  LAImageLoader.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/7/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAImageLoader : NSObject

+ (id)sharedManager;

- (void)processImageDataWithURLString:(NSString *)urlString
                                forId:(NSString *)imageId
                             andBlock:(void (^)(UIImage *image))processImage;

@end
