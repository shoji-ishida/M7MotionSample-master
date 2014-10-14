//
//  SecondViewController.m
//  M7MotionSample
//
//  Created by griffin-stewie on 2013/09/20.
//  Copyright (c) 2013年 cyan-stivy.net. All rights reserved.
//

#import "MotionActivityViewController.h"
#import "DateSelectViewController.h"
#import "ActivityCell.h"
#import "Logger.h"

@interface MotionActivityViewController ()
@property (nonatomic, strong) CMMotionActivityManager *motionActivitiyManager;
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) Logger *logger;
@end

@implementation MotionActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(startUpdateActivity)];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (Logger *)logger
{
    if (_logger == nil) {
        _logger = [[Logger alloc] init];
    }
    return _logger;
}

- (CMMotionActivityManager *)motionActivitiyManager
{
    if (_motionActivitiyManager == nil) {
        _motionActivitiyManager = [[CMMotionActivityManager alloc] init];
    }
    return _motionActivitiyManager;
}

- (void)startUpdateActivity
{
    if ([CMMotionActivityManager isActivityAvailable]) {
        __weak typeof(self) weakSelf = self;
        [self.activities removeAllObjects];
        [self.tableView reloadData];
        [self.motionActivitiyManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                                     withHandler:^(CMMotionActivity *activity) {
                                                         NSLog(@"%s %@", __PRETTY_FUNCTION__, activity);
                                                         [weakSelf.logger appendText:[activity description]];
                                                         [weakSelf.activities insertObject:activity atIndex:0];
                                                         [weakSelf.tableView beginUpdates];
                                                         [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                         [weakSelf.tableView endUpdates];
                                                     }];
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Stop", nil)];
        [self.navigationItem.rightBarButtonItem setAction:@selector(stopUpdateActivity)];
    }
}

- (void)stopUpdateActivity
{
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Start", nil)];
    [self.navigationItem.rightBarButtonItem setAction:@selector(startUpdateActivity)];
    [self.motionActivitiyManager stopActivityUpdates];
    [self.logger writeToFile];
}

- (NSMutableArray *)activities
{
    if (_activities == nil) {
        _activities = [NSMutableArray array];
    }
    return _activities;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ActivityCell *cell = (ActivityCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CMMotionActivity *activity = [self.activities objectAtIndex:indexPath.row];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, activity);
    cell.activity = activity;
    return cell;
}

- (IBAction)returnAction:(UIStoryboardSegue *)segue
{
    
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, fromViewController);
    DateSelectViewController *vc = (DateSelectViewController *)fromViewController;
    [self fetchActivitiesFromDate:vc.fromDate toDate:vc.toDate];
    return [super canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

- (void)fetchActivitiesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
{
    __weak typeof(self) weakSelf = self;
    [self.motionActivitiyManager queryActivityStartingFromDate:fromDate
                                                        toDate:toDate
                                                       toQueue:[NSOperationQueue mainQueue]
                                                   withHandler:^(NSArray *activities, NSError *error) {
                                                       if (error) {
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                                                           message:[error description]
                                                                                                          delegate:nil
                                                                                                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                                 otherButtonTitles:nil, nil];
                                                           [alert show];
                                                           return ;
                                                       }
                                                       weakSelf.activities = [activities mutableCopy];
                                                       [weakSelf.tableView reloadData];
                                                   }];
}

@end
