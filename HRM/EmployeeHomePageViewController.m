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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)applicationPageBtnPressed:(UIButton *)sender {
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if ([localUser.applicationDownloadState isEqual:@1]) {
        [self performSegueWithIdentifier:@"ApplicationListPageSegue" sender:sender];
    }
}


@end
