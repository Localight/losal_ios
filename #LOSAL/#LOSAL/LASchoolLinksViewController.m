//
//  LASchoolLinksViewController.m
//  #LOSAL
//
//  Created by James Orion Hall on 9/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import "LASchoolLinksViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
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
