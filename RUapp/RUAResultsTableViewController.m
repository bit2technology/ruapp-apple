//
//  RUAResultsTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 2014-06-01.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAResultsTableViewController.h"
#import "RUAColor.h"
#import "RUAServerConnection.h"

NSString *const RUAResultsDataSourceCacheKey = @"ResultsDataSourceCache";

@implementation RUAResultsTableViewCell

@end

@interface RUAResultsTableViewController ()

@property (strong, nonatomic) NSObject *dataSource;

@end

@implementation RUAResultsTableViewController

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender
{
//    u_int32_t values[4], biggest = 0, total = 100;
//    for (NSUInteger i = 0; i < 4; i++) {
//        values[i] = (i < 3 ? arc4random_uniform(total) : total);
//        if (values[i] > biggest) {
//            biggest = values[i];
//        }
//        total -= values[i];
//    }
//    for (NSUInteger i = 0; i < 4; i++) {
//        [(UILabel *)self.progressLabels[i] setText:[NSString stringWithFormat:@"%d%%", values[i]]];
//        [(UIProgressView *)self.progressViews[i] setProgress:(float)values[i]/biggest animated:YES];
//    }
}

#pragma mark - UITableViewController methods



// MARK: UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Adjusting interface.
//    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconMenuSelected"];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
//    self.menuDishesList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuDishesList" ofType:@"plist"]];
#warning Activate cached menu.
    self.dataSource = [[NSUserDefaults standardUserDefaults] valueForKey:RUAResultsDataSourceCacheKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If there is a cached data source, adjust current page. Otherwise, show downloading (for the first time) interface.
    if (!self.dataSource) {
        self.tableView.userInteractionEnabled = NO;
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView startAnimating];
        self.tableView.backgroundView = activityView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [RUAServerConnection requestResultsWithCompletionHandler:^(NSArray *results, NSError *error) {
        
    }];
}

@end
