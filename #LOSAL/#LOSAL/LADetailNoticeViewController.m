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
    if (![_item buttonText]) {
        [_linkButton setTitle:[_item buttonText] forState:UIControlStateNormal];
    }else{
        [_linkButton setHidden:YES];
    }
}

//TODO:setup the links if they have them. 

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [titleLabel setText:[_item noticeTitle]];
    [titleLabel setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:24]];
    [content setText:[_item noticeContent]];
    [content setFont:[UIFont fontWithName:@"RobotoSlab-" size:16]];
    
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
- (IBAction)toLink:(id)sender
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[_item buttonLink]]];
}
- (IBAction)back:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

@end
