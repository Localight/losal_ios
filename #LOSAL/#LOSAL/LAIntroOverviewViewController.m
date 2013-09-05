//
//  LAIntroductionViewController.m
//  #LOSAL
//
//  Created by Jeffrey Algera on 9/3/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LAIntroOverviewViewController.h"

#import "LALoginViewController.h"

@interface LAIntroOverviewViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *pagingScrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *contentArray;
@property (nonatomic, strong) LALoginViewController *introVC;

@end

@implementation LAIntroOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _contentArray = [NSMutableArray array];

    CGRect scrollFrame = self.view.bounds;
    
    // view 1 - intro image
    UIImage *introImage = [UIImage imageNamed:@"iphone-sign-in"];
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:introImage];
    imageView1.frame = scrollFrame;
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    [self.pagingScrollView addSubview:imageView1];
    scrollFrame.origin.x += imageView1.frame.size.width;
    
    // view 2 - intro image
    introImage = [UIImage imageNamed:@"sign-in-02"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:introImage];
    imageView2.frame = scrollFrame;
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    [self.pagingScrollView addSubview:imageView2];
    scrollFrame.origin.x += imageView2.frame.size.width;
    
    UIView *v = [[UIView alloc] initWithFrame:scrollFrame];
    v.backgroundColor = [UIColor greenColor];
    self.introVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    self.introVC.delegate = self;
    [v addSubview:self.introVC.view];
    [self.pagingScrollView addSubview:v];
    scrollFrame.origin.x += v.frame.size.width;
    
    [self.pagingScrollView setContentSize:CGSizeMake(scrollFrame.origin.x, 1.0f)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self.pageControl setCurrentPage:page];
}

#pragma mark IntroVC delegate
- (void)wantsToCloseView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
