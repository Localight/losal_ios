//
//  LANoticeItem.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/29/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface LANoticeItem : NSObject<NSCoding>
{
    
}
- (id)initWithnoticeObject:(PFObject *)object
               NoticeTitle:(NSString *)title
             noticeContent:(NSString *)content;
             
@property (nonatomic, strong) NSString *noticeTitle;
@property (nonatomic, strong) NSString *noticeContent;
@property (nonatomic, strong) NSString *interestField;
@property (nonatomic, strong) NSString *audienceTypes;
@property (nonatomic, strong) NSString *buttonLink;
@property (nonatomic, strong) NSString *buttonText;
@property (nonatomic, strong) NSString *teaserText;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
@property BOOL isAnAd;
@property (nonatomic, readonly, strong) NSDate *dateRecieved;//could also be dateMessageSent

@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic, strong) NSData *thumbnailData;

@property (nonatomic, copy) NSString *imageKey;

@property (nonatomic, strong) NSString *noticeImageUrl;
@property (nonatomic, strong) PFObject *postObject;
@property (nonatomic, strong) PFFile *photoFile;
- (void)setThumbnailDataFromImage:(UIImage *)image;
@end
