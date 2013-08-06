//
//  LAPostItem.h
//  #LOSAL
//
//  Created by James Orion Hall on 7/31/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    LASocialSourceFacebook,
    LASocialourceInstagram,
    LASocialSourceTwitter
} LASocialMediaSource;
@interface LAPostItem : NSObject<NSCoding>


@property (nonatomic, assign) LASocialMediaSource postSource;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *academicLevel;
@property (nonatomic, readonly, strong) NSDate *publicationDate;

@property (nonatomic, copy) NSString *imageKey;

@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic, strong) NSData *imagePostData;
@property (nonatomic, strong) NSString *messageContent;


@end
