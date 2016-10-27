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

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Application Page Btn Func

- (IBAction)applicationPageBtnPressed:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"ApplicationListPageSegue" sender:sender];
    
}

#pragma mark - Sign Out Btn Func

- (IBAction)signOutBtnPressed:(UIButton *)sender {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(prepareForSignInPage) name:@"UserHadBeenSignOut" object:nil];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    [localUser signOutUserAccount];

}

- (void)prepareForSignInPage {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    localUser.email = @"";
    localUser.password = @"";
    [self.navigationController popViewControllerAnimated:true];
    
}

@end
