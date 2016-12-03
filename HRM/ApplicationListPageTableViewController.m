//
//  ApplicationTableViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/21.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ApplicationListPageTableViewController.h"
#import "CurrentUser.h"

@interface ApplicationListPageTableViewController () {
    
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"Application"]child:localUser.displayName];
        refHandle = [ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if ([snapshot exists]) {
                
                NSString *snapshotApplyDateStr = snapshot.key;
                for (long long i = 0; i < localUser.applicationList.count; i += 1) {
                    
                    NSDictionary *applicationDict = localUser.applicationList[i];
                    NSString *applyDateStr = [applicationDict allKeys].firstObject;
                    if ([applyDateStr isEqualToString:snapshotApplyDateStr]) {
                        
                        NSDictionary *snapshotInfoDict = snapshot.value;
                        applicationDict = @{snapshotApplyDateStr: snapshotInfoDict};
                        [localUser.applicationList replaceObjectAtIndex:i withObject:applicationDict];
                        
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    
                });
            }
        }];
    });
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

#pragma mark - Table View Delegate

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
    NSDictionary *applicationDict = localUser.applicationList[indexPath.row];
    NSDictionary*infoDict = [applicationDict allValues].firstObject;
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (tableViewCell == nil) {
        
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    
    UIImage *cellBackgroundImage = [UIImage imageNamed:@"cellBackground.png"];
    UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
    tableViewCell.backgroundView = cellBackgroundImageView;
    
    UIImageView *thumbnailImageView = [tableViewCell viewWithTag:100];
    NSNumber *agree = [infoDict objectForKey:@"Agree"];
    UIImage *agreementImage;
    switch ([agree intValue]) {
            
        case 0:
            agreementImage = [UIImage imageNamed:@"becheckIcon.png"];
            break;
            
        case 1:
            agreementImage = [UIImage imageNamed:@"agreeIcon.png"];
            break;
            
        case 2:
            agreementImage = [UIImage imageNamed:@"refuseIcon.png"];
            break;

    }
    thumbnailImageView.image = agreementImage;
    
    UILabel *typeLabel = [tableViewCell viewWithTag:101];
    typeLabel.text = [infoDict objectForKey:@"Type"];
    
    UILabel *startDateLabel = [tableViewCell viewWithTag:102];
    startDateLabel.text = [infoDict objectForKey:@"From"];
    
    UILabel *endDateLabel = [tableViewCell viewWithTag:103];
    endDateLabel.text = [infoDict objectForKey:@"To"];
    
    return tableViewCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    _selectedApplicationDict = localUser.applicationList[indexPath.row];
    [self performSegueWithIdentifier:@"ApplicationInfoPageSegue" sender:nil];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle ==UITableViewCellEditingStyleDelete ) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        NSDictionary *applicationDict = localUser.applicationList[indexPath.row];
        NSString*applyDateStr = [applicationDict allKeys].firstObject;
        [localUser removeApplicationWhichAppliedAt:applyDateStr];
        [localUser.applicationList removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        
    }
}

@end
