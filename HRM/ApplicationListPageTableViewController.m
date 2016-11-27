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
    
    FIRDatabaseHandle refHandle;
    
}

@end

@implementation ApplicationListPageTableViewController

#pragma View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"backgroundGreen.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    
    FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"Application"]child:localUser.displayName];
    refHandle = [ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if ([snapshot exists]) {
            
            [self.tableView reloadData];
            
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController == true) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"Application"]child:localUser.displayName];
        [ref removeObserverWithHandle:refHandle];
        
    }
}

#pragma Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    return localUser.applicationList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    NSDictionary *application = localUser.applicationList[indexPath.row];
    NSDictionary*infoDict = [application allValues].firstObject;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    
    UIImage *cellBackgroundImage = [UIImage imageNamed:@"cellBackground.png"];
    UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
    cell.backgroundView = cellBackgroundImageView;
    
    UIImageView *thumbnailImageView = [cell viewWithTag:100];
    NSNumber *agree = [infoDict objectForKey:@"Agree"];
    UIImage *agreeImage;
    switch ([agree intValue]) {
            
        case 0:
            agreeImage = [UIImage imageNamed:@"refuseIcon.png"];
            break;
            
        case 1:
            agreeImage = [UIImage imageNamed:@"agreeIcon.png"];
            break;

    }
    thumbnailImageView.image = agreeImage;
    
    UILabel *typeLabel = [cell viewWithTag:101];
    typeLabel.text = [infoDict objectForKey:@"Type"];
    
    UILabel *startDateLabel = [cell viewWithTag:102];
    startDateLabel.text = [infoDict objectForKey:@"From"];
    
    UILabel *endDateLabel = [cell viewWithTag:103];
    endDateLabel.text = [infoDict objectForKey:@"To"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    _selectedApplicationDict = localUser.applicationList[indexPath.row];
    [self performSegueWithIdentifier:@"ApplicationInfoPageSegue" sender:nil];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle ==UITableViewCellEditingStyleDelete ) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        NSDictionary *application = localUser.applicationList[indexPath.row];
        NSString*applyDate = [application allKeys].firstObject;
        [localUser removeApplicationWhichAppliedAt:applyDate];
        [localUser.applicationList removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        
    }
}

@end
