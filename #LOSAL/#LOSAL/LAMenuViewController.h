//
//  LAMenuViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAMenuViewController : UITableViewController
{
    
}
// Come back to, and work on.

@property (weak, nonatomic) IBOutlet UIView *namViewContainter;

@property (weak, nonatomic) IBOutlet UILabel *userIcon;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

- (IBAction)toSite:(id)sender;


@end
