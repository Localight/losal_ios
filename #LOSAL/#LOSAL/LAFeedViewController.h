//
//  LAMasterViewController.h
//  #LOSAL
//
//  Created by James Orion Hall on 7/27/13.
//  Copyright (c) 2013 Localism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAFeedViewController : UITableViewController

// The data source to be displayed in table ()
@property (strong, nonatomic) NSMutableArray *objects;
// The counter of fetch batch.
@property (nonatomic) int fetchBatch;
// Indicates whether the data is already loading.
// Don't load the next batch of data until this batch is finished.
// You MUST set loading = NO when the fetch of a batch of data is completed.
// See line 29 in DataLoader.m for example.
@property (nonatomic) BOOL loading;
// noMoreResultsAvail indicates if there are no more search results.
// Implement noMoreResultsAvail in your app.
// For demo purpsoses here, noMoreResultsAvail = NO.
@property (nonatomic) BOOL moreResultsAvail;

@end
