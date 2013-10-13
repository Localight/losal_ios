//
//  LADetailNoticeViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LADetailNoticeViewController.h"
#import "LANoticeItem.h"
#import "LANoticesStore.h"
#import "LAImageLoader.h"
#import "ECSlidingViewController.h"
//#import "LAImageStore.h"
//#import "LAImageStore.h"
@implementation LADetailNoticeViewController

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        UINavigationItem *navyItem = [self navyItem];
//        [navyItem setTitle:[_item noticeTitle]];
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", _navyItem);
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    
    [backBtn setBackgroundImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self
                action:@selector(back:)
      forControlEvents:UIControlEventTouchUpInside];
     [_navyItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:backBtn]];
    
    [_navyItem setTitle:[_item noticeTitle]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [titleLabel setText:[_item noticeTitle]];
    [content setText:[_item noticeContent]];
    
    [[LAImageLoader sharedManager]processImageDataWithURLString:[_item noticeImageUrl]
                                                          forId:[[_item postObject]objectId]
                                                       andBlock:^(UIImage *image)
     {
         [imageView setImage:image];
    }];
    [[self navigationItem] setTitle:[_item noticeTitle]];
}

- (void)setItem:(LANoticeItem *)i
{
    _item = i;
    
    [[self navigationItem] setTitle:[_item noticeTitle]];
}

- (IBAction)back:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];    
}

@end
