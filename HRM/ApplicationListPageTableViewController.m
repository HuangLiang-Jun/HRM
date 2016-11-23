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

#pragma View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];

}

#pragma Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
//    return localUser.applicationList.count;
    return 100;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    CurrentUser *localUser = [CurrentUser sharedInstance];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    NSString *applicatedDate = [localUser.applicationList[indexPath.row] allKeys].firstObject;
//    cell.detailTextLabel.text = applicatedDate;
//    
//    NSDictionary *applicationInfo = localUser.applicationList[indexPath.row][applicatedDate];
//    NSString *applicationPeriod = [NSString stringWithFormat:@"%@ (%@ ~ %@)", applicationInfo[@"Subject"], applicationInfo[@"From"], applicationInfo[@"To"]];
//    cell.textLabel.text = applicationPeriod;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    UIImageView *thumbnailImageView = [cell viewWithTag:0];
    thumbnailImageView.image = [UIImage new];
    
    UILabel *applicationDateLabel = [cell viewWithTag:1];
    applicationDateLabel.text = [NSDateNSStringExchange stringFromChosenDate:[NSDate date]];
    
    UILabel *typeLabel = [cell viewWithTag:2];
    typeLabel.text = @"病假";
    
    UILabel *durationLabel = [cell viewWithTag:3];
    durationLabel.text = @"1d 3h";
    

    return cell;
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    CurrentUser *localUser = [CurrentUser sharedInstance];
//    NSString *applicatedDate = [localUser.applicationList[indexPath.row] allKeys].firstObject;
//    _selectedApplicationInfo = localUser.applicationList[indexPath.row][applicatedDate];
//    [self performSegueWithIdentifier:@"ApplicationInfoPageSegue" sender:nil];
//    
//}
//
//#pragma Additional Func
//
- (void)addNewApplication {
    
    [self performSegueWithIdentifier:@"ApplicationFormPageSegue" sender:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
