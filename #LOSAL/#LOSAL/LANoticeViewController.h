//
//  LANoticeViewController.h
//  #LOSAL
//
//  Created by Joaquin Brown on 8/23/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LADetailNoticeViewController.h"
@interface LANoticeViewController :UITableViewController
{
    
}
@property (weak, nonatomic) IBOutlet UINavigationItem *navyItem;
//@property (nonatomic, weak) IBOutlet UITableView *tableView;
//
@property (nonatomic, assign) CGFloat peekLeftAmount;
@end
