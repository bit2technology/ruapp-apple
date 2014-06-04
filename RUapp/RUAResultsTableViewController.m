//
//  RUAResultsTableViewController.m
//  RUapp
//
//  Created by Igor Camilo on 2014-06-01.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAResultsTableViewController.h"

#import "RUAColor.h"

@interface RUAResultsTableViewController ()

@property (strong, nonatomic) IBOutletCollection(UIProgressView) NSArray *progressViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *progressLabels;

@end

@implementation RUAResultsTableViewController

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender
{
    u_int32_t values[4], biggest = 0, total = 100;
    for (NSUInteger i = 0; i < 4; i++) {
        values[i] = (i < 3 ? arc4random_uniform(total) : total);
        if (values[i] > biggest) {
            biggest = values[i];
        }
        total -= values[i];
    }
    for (NSUInteger i = 0; i < 4; i++) {
        [(UILabel *)self.progressLabels[i] setText:[NSString stringWithFormat:@"%d%%", values[i]]];
        [(UIProgressView *)self.progressViews[i] setProgress:(float)values[i]/biggest animated:YES];
    }
}

#pragma mark - UITableViewController methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    // Set appearance to header text label.
    view.textLabel.backgroundColor = [RUAColor darkBlueColor];
    view.textLabel.opaque = YES;
    view.textLabel.textColor = [RUAColor lightGrayColor];
    view.textLabel.shadowColor = nil;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    // Basic preparation.
    [super viewDidLoad];
    
    // Set tab bar item's selected image.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7 and later.
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarIconVoteSelected"];
    }
}

@end
