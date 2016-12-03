//
//  SignoffListTableViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/11/28.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignoffListTableViewController.h"
#import "CurrentUser.h"

@interface SignoffListTableViewController () {
    
    FIRDatabaseHandle _refAddedHandle, _refRemovedHandle;
    
}

@end

@implementation SignoffListTableViewController

#pragma View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"backgroundGreen.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        
        FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"Signoff"];
        _refAddedHandle = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if ([snapshot exists]) {
                
                NSString *newApplyDateStr = snapshot.key;
                NSDictionary *infoDict = snapshot.value;
                NSDictionary *signoffFormDict = @{newApplyDateStr: infoDict};
                if (![localUser.applicationList containsObject:signoffFormDict]) {
                    
                    [localUser.applicationList insertObject:signoffFormDict atIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    });
                }
            }
        }];
        
        _refRemovedHandle = [ref observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if ([snapshot exists]) {
                
                NSString *newApplyDateStr = snapshot.key;
                NSDictionary *infoDict = snapshot.value;
                NSDictionary *signoffFormDict = @{newApplyDateStr: infoDict};
                long long row = [localUser.applicationList indexOfObject:signoffFormDict];
                [localUser.applicationList removeObject:signoffFormDict];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
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
        
        FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"Signoff"];
        [ref removeObserverWithHandle:_refAddedHandle];
        [ref removeObserverWithHandle:_refRemovedHandle];
        
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
    NSDictionary *signoffFormDict = localUser.applicationList[indexPath.row];
    NSDictionary*infoDict = [signoffFormDict allValues].firstObject;
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
    
    NSString *newApplyDateStr = [signoffFormDict allKeys].firstObject;
    NSArray<NSString *> *subNewApplyDateStr = [newApplyDateStr componentsSeparatedByString:@"@"];
    NSString *username = subNewApplyDateStr.lastObject;
    UILabel *usernameLabel = [tableViewCell viewWithTag:101];
    usernameLabel.text = username;
    
    UILabel *typeLabel = [tableViewCell viewWithTag:102];
    typeLabel.text = [infoDict objectForKey:@"Type"];
    
    UILabel *startDateLabel = [tableViewCell viewWithTag:103];
    startDateLabel.text = [infoDict objectForKey:@"From"];
    
    UILabel *endDateLabel = [tableViewCell viewWithTag:104];
    endDateLabel.text = [infoDict objectForKey:@"To"];
    
    return tableViewCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    _selectedSignoffFormDict = localUser.applicationList[indexPath.row];
    [self performSegueWithIdentifier:@"SignoffFormPageSegue" sender:nil];
    
}

@end
