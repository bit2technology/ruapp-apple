//
//  RUAMenuTableViewController.h
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUATableViewController.h"

extern NSString *const RUAMenuDataSourceCacheKey;
extern NSString *const RUAMenuUpdated;

@import UIKit;

@interface RUAMenuTableViewController : RUATableViewController

// MARK: Methods

/**
 * Download or update data source and update table view.
 */
- (void)downloadDataSourceAndUpdateTable;

/**
 * Returns the menu list for current meal.
 */
- (NSArray *)menuForCurrentMeal;

@end
