//
//  LAPostCell.h
//  #LOSAL
//
//  Created by James Orion Hall on 8/6/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateAndGradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *socialLabel;
@property (weak, nonatomic) IBOutlet UILabel *icon;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *messageArea;
//@property (weak, nonatomic) IBOutlet UITextView *messageArea;
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;
@property (weak, nonatomic) IBOutlet UIImageView *socialMediaImage;
@property (weak, nonatomic) IBOutlet UIImageView *timeImage;

- (IBAction)showImage:(id)sender;
@end
