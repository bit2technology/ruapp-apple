//
//  RUATableViewController.h
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

@import UIKit;

@interface RUATableViewController : UITableViewController

// MARK: Methods

/**
 * Creates a view to be used as background.
 */
- (UIView *)tableViewBackgroundViewWithMessage:(NSString *)message;

/**
 * View to show on top of empity views, suggesting how to refresh.
 */
- (UIView *)tableViewHeaderViewPullToRefresh;

@end
