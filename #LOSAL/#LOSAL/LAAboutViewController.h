//
//  LAAboutViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/28/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAAboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *navyItem;

@property (weak, nonatomic) IBOutlet UIScrollView *scroll;

@property (weak, nonatomic) IBOutlet UIImageView *companyBanner;
@property (weak, nonatomic) IBOutlet UIImageView *prinicpalPhoto;

@property (weak, nonatomic) IBOutlet UITextView *paragraph1;
@property (weak, nonatomic) IBOutlet UITextView *paragraph2;
@property (weak, nonatomic) IBOutlet UITextView *paragraph3;
@property (weak, nonatomic) IBOutlet UITextView *paragraph4;
@property (weak, nonatomic) IBOutlet UITextView *paragraph5;

@property (weak, nonatomic) IBOutlet UILabel *labelSuggestFeature;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UILabel *SafetySecurityLabel;
@property (weak, nonatomic) IBOutlet UILabel *faqLabel;
@property (weak, nonatomic) IBOutlet UILabel *copywriteLabel;

@end
