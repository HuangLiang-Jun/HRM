//
//  SignoffListTableViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/11/28.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignoffListTableViewController.h"
#import "SignoffFormPageViewController.h"
#import "CurrentUser.h"
#import <SVProgressHUD/SVProgressHUD.h>
@interface SignoffListTableViewController () {
    
    FIRDatabaseHandle _refAddedHandle, _refRemovedHandle;
    CurrentUser *localUser;
}

@end

@implementation SignoffListTableViewController

#pragma View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(segueToApplicationPage) name:@"ApplicationListDownloaded" object:nil];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setForegroundColor:[UIColor darkGrayColor]];
    [SVProgressHUD setRingThickness:4.0];
    
    [SVProgressHUD show];
    
    localUser = [CurrentUser sharedInstance];
   
     [localUser downloadAppcationList];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"Signoff"];
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
        
        FIRDatabaseQuery * query =[[ref queryOrderedByValue] queryLimitedToLast:1];
        _refAddedHandle = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
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
        [ref removeObserverWithHandle:_refRemovedHandle];
        
        FIRDatabaseQuery * query =[[ref queryOrderedByValue] queryLimitedToLast:1];
        [query removeObserverWithHandle:_refAddedHandle];
        
    }
}

- (void)segueToApplicationPage {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"ApplicationListDownloaded" object:nil];
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
    
    
    
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    
    return localUser.applicationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (tableViewCell == nil) {
        
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    
//    UIImage *cellBackgroundImage = [UIImage imageNamed:@"cellBackground.png"];
//    UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
//    tableViewCell.backgroundView = cellBackgroundImageView;
    
//    CurrentUser *localUser = [CurrentUser sharedInstance];
    NSDictionary *signoffFormDict = localUser.applicationList[indexPath.row];
    
    NSString *newApplyDateStr = [signoffFormDict allKeys].firstObject;
    
    NSArray<NSString *> *subNewApplyDateStr = [newApplyDateStr componentsSeparatedByString:@"@"];
    NSString *username = subNewApplyDateStr.lastObject;
    UILabel *usernameLabel = [tableViewCell viewWithTag:101];
    usernameLabel.text = username;
    
    NSDictionary*infoDict = [signoffFormDict allValues].firstObject;
    
    UIImage *agreementImage;
    NSNumber *agree = [infoDict objectForKey:@"Agree"];
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
    UIImageView *thumbnailImageView = [tableViewCell viewWithTag:100];
    thumbnailImageView.image = agreementImage;
    
    UILabel *typeLabel = [tableViewCell viewWithTag:102];
    typeLabel.text = [infoDict objectForKey:@"Type"];
    
    UILabel *startDateLabel = [tableViewCell viewWithTag:103];
    startDateLabel.text = [infoDict objectForKey:@"From"];
    
    UILabel *endDateLabel = [tableViewCell viewWithTag:104];
    endDateLabel.text = [infoDict objectForKey:@"To"];
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedSignoffFormDict = localUser.applicationList[indexPath.row];
    [self performSegueWithIdentifier:@"SignoffFormPageSegue" sender:nil];
    
}

@end
