//
//  ApplicationTableViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/21.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ApplicationListPageTableViewController.h"
#import "CurrentUser.h"

@interface ApplicationListPageTableViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    CurrentUser *localUser;

}

@end

@implementation ApplicationListPageTableViewController

#pragma View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    localUser = [CurrentUser sharedInstance];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadView {
    [super loadView];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewApplication)];
    self.navigationItem.rightBarButtonItems = @[add];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self.navigationController setNavigationBarHidden:false];
    [self.tableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:true];
    
}

#pragma Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return localUser.applicationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *applicatedDate = [localUser.applicationList[indexPath.row] allKeys].firstObject;
    cell.detailTextLabel.text = applicatedDate;
    
    NSDictionary *applicationInfo = localUser.applicationList[indexPath.row][applicatedDate];
    NSString *applicationPeriod = [NSString stringWithFormat:@"%@ (%@ ~ %@)", applicationInfo[@"Subject"], applicationInfo[@"From"], applicationInfo[@"To"]];
    cell.textLabel.text = applicationPeriod;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *applicatedDate = [localUser.applicationList[indexPath.row] allKeys].firstObject;
    _selectedApplicationInfo = localUser.applicationList[indexPath.row][applicatedDate];
    [self performSegueWithIdentifier:@"ApplicationInfoPageSegue" sender:nil];
    
}

#pragma Additional Func

- (void)addNewApplication {
    [self performSegueWithIdentifier:@"ApplicationFormPageSegue" sender:nil];
}

@end
