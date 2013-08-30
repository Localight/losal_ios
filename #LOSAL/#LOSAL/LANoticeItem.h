//
//  LANoticeItem.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LANoticeItem : NSObject<NSCoding>
{
    
}
- (id)initWithNoticeTitle:(NSString *)title
            noticeContent:(NSString *)content;

@property (nonatomic, strong) NSString *noticeTitle;
@property (nonatomic, strong) NSString *noticeContent;
@property (nonatomic, readonly, strong) NSDate *dateRecieved;//could also be dateMessageSent

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSData *thumbnailData;
@property (nonatomic, copy) NSString *imageKey;

- (void)setThumbnailDataFromImage:(UIImage *)image;
@end
