//
//  ApplicationTableViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/21.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ApplicationListPageTableViewController.h"
#import "CurrentUser.h"

@interface ApplicationListPageTableViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ApplicationListPageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadView {
    [super loadView];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewApplication)];
    self.navigationItem.rightBarButtonItems = @[add];
    
//    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissToHomePage)];
//    self.navigationItem.leftBarButtonItems = @[back];

}

//- (void) dismissToHomePage{
//    [self dismissViewControllerAnimated:true completion:nil];
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:true];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CurrentUser *localUser = [CurrentUser sharedInstance];
    return localUser.applicationList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    NSString *applicatedDate = [localUser.applicationList[indexPath.row] allKeys].firstObject;
    NSDictionary *applicationInfo = localUser.applicationList[indexPath.row][applicatedDate];
    NSString *applicationPeriod = [NSString stringWithFormat:@"%@ (%@ ~ %@)", applicationInfo[@"Subject"], applicationInfo[@"From"], applicationInfo[@"To"]];
    cell.textLabel.text = applicationPeriod;
    cell.detailTextLabel.text = applicatedDate;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrentUser *localUser = [CurrentUser sharedInstance];
    NSString *applicatedDate = [localUser.applicationList[indexPath.row] allKeys].firstObject;
    _selectedApplicationInfo = localUser.applicationList[indexPath.row][applicatedDate];
    [self performSegueWithIdentifier:@"ApplicationInfoPageSegue" sender:nil];
}

- (void)addNewApplication {
    [self performSegueWithIdentifier:@"ApplicationFormPageSegue" sender:nil];
}

@end
