//
//  LAMasterViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LANoticeViewController.h"
#import "LASocialManager.h"

@interface LAFeedViewController : UITableViewController<LANoticeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, LASocialManagerDelegate>

@end
