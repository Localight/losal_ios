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

@property (nonatomic, weak) IBOutlet UIView *namViewContainter;

@property (nonatomic, weak) IBOutlet UILabel *userIcon;

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

- (IBAction)toSite:(id)sender;


@end
