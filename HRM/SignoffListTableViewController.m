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
    
    FIRDatabaseHandle refHandle;
    
}

@end

@implementation SignoffListTableViewController

#pragma View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"backgroundGreen.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"Application"]child:localUser.displayName];
    refHandle = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
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

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}


@end
