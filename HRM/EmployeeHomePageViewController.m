//
//  EmployeeHomePageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/25.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "EmployeeHomePageViewController.h"
#import "CurrentUser.h"

@interface EmployeeHomePageViewController ()

@end

@implementation EmployeeHomePageViewController

#pragma mark - Application Page Btn Func

- (IBAction)applicationPageBtnPressed:(UIButton *)sender {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(segueToApplicationPage) name:@"ApplicationListDownloaded" object:nil];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    [localUser downloadAppcationList];
    
}

- (void)segueToApplicationPage {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"ApplicationListDownloaded" object:nil];
    [self performSegueWithIdentifier:@"ApplicationListPageSegue" sender:nil];
    
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
