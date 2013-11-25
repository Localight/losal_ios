//
//  LADetailNoticeViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 8/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LADetailNoticeViewController.h"
#import "LANoticeItem.h"
#import "LAImageLoader.h"
#import "ECSlidingViewController.h"
#import "UIImage+Resize.h"

@interface LADetailNoticeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UINavigationItem *navyItem;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;

@end

@implementation LADetailNoticeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 0, 25, 25);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"183_x-circle"] forState:UIControlStateNormal];
    [closeBtn addTarget:self
                action:@selector(close:)
      forControlEvents:UIControlEventTouchUpInside];
    
    [_navyItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:closeBtn]];
    [_navyItem setTitle:[_item noticeTitle]];
    
    if ([_item buttonText])
        [_linkButton setTitle:[_item buttonText] forState:UIControlStateNormal];
    else
        [_linkButton setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.titleLabel setText:[_item noticeTitle]];
    [self.titleLabel setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:18]];
    [self.content setText:[_item noticeContent]];
    [self.content setFont:[UIFont fontWithName:@"RobotoSlab-Regular" size:13]];
    
    [[LAImageLoader sharedManager]processImageDataWithURLString:[_item noticeImageUrl]
                                                          forId:[[_item postObject]objectId]
                                                       andBlock:^(UIImage *image) {
         [self.imageView setImage:[image resizedImage:self.imageView.frame.size interpolationQuality:kCGInterpolationDefault]];
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

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
