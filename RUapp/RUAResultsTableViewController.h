//
//  RUAResultsTableViewController.h
//  RUapp
//
//  Created by Igor Camilo on 2014-06-01.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUATableViewController.h"

extern NSString *const RUAResultsDataSourceCacheKey;

@import UIKit;

@interface RUAResultsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *voteIconView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *dishLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *helperLabel;

@end

@interface RUAResultsTableViewController : RUATableViewController
@end
