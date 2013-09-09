//
//  LASchoolLinksViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 9/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASchoolLinksViewController.h"
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"
#import "LANoticeViewController.h"

@interface LASchoolLinksViewController ()

@end

@implementation LASchoolLinksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)revealNotices:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}
- (IBAction)back:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [_navyItem setTitle:@"School Links"];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 30, 30);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_navyItem setLeftBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:menuBtn]];
    
    UIButton *noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noticeBtn.frame = CGRectMake(0, 0, 27, 27);
    [noticeBtn setBackgroundImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
    [noticeBtn addTarget:self action:@selector(revealNotices:) forControlEvents:UIControlEventTouchUpInside];
    
    [_navyItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:noticeBtn]];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LAMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[LANoticeViewController class]]) {
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Notices"];
    }

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)instagramButton:(id)sender
{
       [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://instagram.com/LosAlamitosHigh"]];
}

- (IBAction)flickrButton:(id)sender
{
       [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://www.flickr.com/photos/97669165@N06/"]];
}

- (IBAction)facebookButton:(id)sender
{
       [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://www.facebook.com/losalamitoshighschool"]];
}

- (IBAction)twitterButton:(id)sender
{
       [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"https://twitter.com/LosAlamitosHigh"]];
}

- (IBAction)youtubeButton1:(id)sender
{
       [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://www.youtube.com/user/GriffinNews2013"]];
}

- (IBAction)youtubeButton2:(id)sender
{
       [[UIApplication sharedApplication]openURL:[NSURL URLWithString: @"http://www.youtube.com/user/josharnold67"]];
}

@end
