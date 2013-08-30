//
//  LADetailNoticeViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LANoticeItem;

@interface LADetailNoticeViewController : UIViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UITextView *content;
}

@property (nonatomic, strong) LANoticeItem *item;

@property (nonatomic, copy) void (^dismissBlock)(void);
@end
