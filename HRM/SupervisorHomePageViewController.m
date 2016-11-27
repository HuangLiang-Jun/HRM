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

@interface SupervisorHomePageViewController ()

@end

@implementation SupervisorHomePageViewController
{
     FIRDatabaseReference *staffNameRef;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    

}

- (IBAction)salaryBtnPressed:(UIButton *)sender {

   
    
    
}

#pragma mark - Signoff List Btn Func

- (IBAction)SignoffListBtnPressed:(UIButton *)sender {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(segueToApplicationPage) name:@"ApplicationListDownloaded" object:nil];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    [localUser downloadAppcationList];
    
}

- (void)segueToApplicationPage {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"ApplicationListDownloaded" object:nil];
    [self performSegueWithIdentifier:@"SignoffListSegue" sender:nil];
    
}

#pragma mark - Staff List Btn Func

- (IBAction)staffListBtnPressed:(id)sender {
    
   
    
}

#pragma mark - Sign Out Btn Func

- (IBAction)signOutBtnPressed:(UIButton *)sender {

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

@end
