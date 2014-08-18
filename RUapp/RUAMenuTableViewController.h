//
//  RUAMenuTableViewController.h
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUATableViewController.h"

extern NSString *const RUAMenuDataSourceCacheKey;

@import UIKit;

@interface RUAMenuTableViewController : RUATableViewController

/**
 * Download or update data source and update table view.
 */
- (void)downloadDataSourceAndUpdateTable;

@end
