//
//  LAMasterViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "LAMenuViewController.h"


@interface LAFeedViewController : UITableViewController

- (IBAction)revealMenu:(id)sender;

-(void)fetchEntries;

-(NSString *)fuzzyTime:(NSString *)datetime;

@end
