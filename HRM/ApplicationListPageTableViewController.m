//
//  ApplicationTableViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/21.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ApplicationListPageTableViewController.h"
#import "ApplicationInfoPageViewController.h"
#import "CurrentUser.h"
#import <SVProgressHUD/SVProgressHUD.h>
@interface ApplicationListPageTableViewController () {
    
    FIRDatabaseHandle _refHandle;
    long long _count;
    BOOL status;
}

@end

@implementation ApplicationListPageTableViewController

#pragma View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;
    status = true;
    CurrentUser *localUser = [CurrentUser sharedInstance];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setForegroundColor:[UIColor darkGrayColor]];
    [SVProgressHUD setRingThickness:4.0];
    
    [SVProgressHUD show];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(segueToApplicationPage) name:@"ApplicationListDownloaded" object:nil];
    
    [localUser downloadAppcationList];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        
        FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"Application"]child:localUser.displayName];
        _refHandle = [ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSLog(@"snapshot%@",snapshot);
            if ([snapshot exists]) {
                
                NSString *snapshotApplyDateStr = snapshot.key;
                for (long long i = 0; i < localUser.applicationList.count; i += 1) {
                    
                    NSDictionary *applicationDict = localUser.applicationList[i];
                    NSString *applyDateStr = [applicationDict allKeys].firstObject;
                    if ([applyDateStr isEqualToString:snapshotApplyDateStr]) {
                        
                        NSDictionary *snapshotInfoDict = snapshot.value;
                        applicationDict = @{snapshotApplyDateStr: snapshotInfoDict};
                        [localUser.applicationList replaceObjectAtIndex:i withObject:applicationDict];
                        NSLog(@"application:%@",applicationDict);
                        
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    
                });
            }
        }];
    });
}

- (void)segueToApplicationPage {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"ApplicationListDownloaded" object:nil];
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    long long latestCount = localUser.applicationList.count;
    if (status){
        _count = localUser.applicationList.count;
        status = false;
    }
    if (latestCount - _count != 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController == true) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"Application"]child:localUser.displayName];
        [ref removeObserverWithHandle:_refHandle];
        
    }
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    _count = localUser.applicationList.count;
    
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
    
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
    
//    UIImage *cellBackgroundImage = [UIImage imageNamed:@"cellBackground.png"];
//    UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
//    tableViewCell.backgroundView = cellBackgroundImageView;
    
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
    ApplicationInfoPageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ApplicationInfoPageViewController"];
    vc.applicationDict = localUser.applicationList[indexPath.row];
    
    [self showViewController:vc sender:nil];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle ==UITableViewCellEditingStyleDelete ) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        NSDictionary *applicationDict = localUser.applicationList[indexPath.row];
        NSString*applyDateStr = [applicationDict allKeys].firstObject;
        [localUser removeApplicationWhichAppliedAt:applyDateStr];
        [localUser.applicationList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

@end
