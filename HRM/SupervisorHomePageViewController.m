//
//  SupervisorHomePageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/25.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SupervisorHomePageViewController.h"
#import "SearchClassViewController.h"
#import "CurrentUser.h"
#import "StaffInfoDataManager.h"
@import Firebase;
@import FirebaseDatabase;

@interface SupervisorHomePageViewController ()

@end

@implementation SupervisorHomePageViewController
{
     FIRDatabaseReference *staffNameRef;
    StaffInfoDataManager *staffDataManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    staffDataManager = [StaffInfoDataManager sharedInstance];
    

}
- (IBAction)checkOnDutyList:(UIButton *)sender {
    
    
    
    
    
}
- (IBAction)salaryBtnPressed:(UIButton *)sender {

    staffNameRef = [[[FIRDatabase database]reference]child:@"UID"];
    
    //Get All Staff Name.
    [staffNameRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *allName = snapshot.value;
        NSMutableArray *staffName = [[NSMutableArray alloc] initWithArray:allName.allValues];
        
        NSLog(@"snapshotValue: %@",staffName);
        if (staffName.count != 0) {
           
            [[NSUserDefaults standardUserDefaults] setObject:staffName forKey:@"staffName"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
    }];
    
    
}
- (IBAction)confirmApplicationBtnPressed:(UIButton *)sender {
    
    
    
}
- (IBAction)staffListBtnPressed:(id)sender {
    
    [staffDataManager downLoadStaffInfo];
    
}


- (IBAction)signOutBtnPressed:(id)sender {

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(prepareForSignInPage) name:@"UserSignedOut" object:nil];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    [localUser signOutUserAccount];

}

- (void)prepareForSignInPage {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UserHadBeenSignOut" object:nil];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    localUser.email = @"";
    localUser.password = @"";
    [self dismissViewControllerAnimated:true completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
