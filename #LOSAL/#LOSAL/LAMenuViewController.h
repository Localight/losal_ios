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
    __weak IBOutlet UIView *namViewContainter;
    __weak IBOutlet UILabel *userIcon;
    __weak IBOutlet UILabel *userNameLabel;
    
}
// Come back to, and work on.

- (IBAction)toSite:(id)sender;


@end
