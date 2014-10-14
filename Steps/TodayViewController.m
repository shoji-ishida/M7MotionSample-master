//
//  TodayViewController.m
//  Steps
//
//  Created by 石田 勝嗣 on 2014/07/24.
//  Copyright (c) 2014年 cyan-stivy.net. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <CoreMotion/CoreMotion.h>

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) CMStepCounter *stepCounter;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.stepCounter = [[CMStepCounter alloc] init];
    
    __weak typeof(self) weakSelf = self;

    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:now];
    [comps setHour:0];
    NSDate *today = [gregorian dateFromComponents:comps];
    
    [self.stepCounter queryStepCountStartingFrom:today
                                              to:now
                                         toQueue:[NSOperationQueue mainQueue]
                                     withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                         NSLog(@"%s %ld %@", __PRETTY_FUNCTION__, numberOfSteps, error);
                                          weakSelf.totalStepsLabel.text = [@(numberOfSteps) stringValue];
                                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
