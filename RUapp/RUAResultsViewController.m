//
//  RUAResultsViewController.m
//  RUapp
//
//  Created by Igor Camilo on 19/05/2014.
//  Copyright (c) 2014 Bit2 Software. All rights reserved.
//

#import "RUAResultsViewController.h"

@interface RUAResultsViewController ()

// Chart.
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *chartLabels;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *chartBars;

@end

@implementation RUAResultsViewController

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    NSInteger value = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:4];
    for (int idx = 0; idx < 3; idx++) {
        NSInteger random = arc4random_uniform(value * 3 / 5);
        [values addObject:[NSNumber numberWithInteger:random]];
        value -= random;
    }
    [values addObject:[NSNumber numberWithInteger:value]];
    
    [self setChartValues:values animated:YES];
}

- (void)setChartValues:(NSArray *)chartValues animated:(BOOL)animated
{
    CGFloat maxHeight = [[self.chartBars firstObject] superview].bounds.size.height;
    NSInteger maxValue = NSIntegerMin;
    for (int idx = 0; idx < 4; idx++) {
        NSInteger value = [chartValues[idx] integerValue];
        if (value > maxValue) {
            maxValue = value;
        }
    }
    
    [UIView animateWithDuration:(animated ? .2 : 0) animations:^{
        [self.chartLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
            // Get value.
            NSInteger value = [chartValues[idx] integerValue];
            // Set label text.
            label.text = [NSString stringWithFormat:@"%d%%", value];
            // Set bar frame.
            UIView *bar = self.chartBars[idx];
            CGFloat height = maxHeight * value / maxValue;
            CGRect barFrame = bar.frame;
            barFrame.size.height = height;
            barFrame.origin.y = maxHeight - height;
            bar.frame = barFrame;
        }];
    }];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationController.navigationBar.tintColor = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self segmentedControlValueChanged:nil];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/

@end
