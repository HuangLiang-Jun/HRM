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
@interface SupervisorHomePageViewController ()

@end

@implementation SupervisorHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)checkOnDutyList:(UIButton *)sender {
    
    
    
    
    
}
- (IBAction)salaryBtnPressed:(UIButton *)sender {

}
- (IBAction)confirmApplicationBtnPressed:(UIButton *)sender {

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
