//
//  RUATableViewController.h
//  RUapp
//
//  Created by Igor Camilo on 04/06/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

@import UIKit;

@interface RUATableViewLoadingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@interface RUATableViewController : UITableViewController

@end
