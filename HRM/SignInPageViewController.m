//
//  SignInPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/17.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignInPageViewController.h"
#import "CurrentUser.h"

@interface SignInPageViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignInPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:false];
}

- (IBAction)signInBtnPressed:(UIButton *)sender {
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (![_emailField.text isEqualToString:@""]) {
        localUser.email = _emailField.text;
        [[NSUserDefaults standardUserDefaults] setValue: localUser.email forKey:@"Email"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (![_passwordField.text isEqualToString:@""]) {
            localUser.password = _passwordField.text;
            [[NSUserDefaults standardUserDefaults] setValue:localUser.password forKey:@"Password"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [localUser signInUserAccount];
            FIRUser *user = [[FIRAuth auth] currentUser];
            if (user != nil && [localUser.downloadState isEqual:@3]) {
                switch (localUser.auth.intValue) {
                    case 1:
                        [self performSegueWithIdentifier:@"SupervisorHomePageSegue" sender:nil];
                        break;
                    default:
                        [self performSegueWithIdentifier:@"EmployeeHomePageSegue" sender:nil];
                        break;
                }
                [localUser downloadAppcationList];
            }
        } else {
            _passwordField.placeholder = @"Enter your password.";
            _passwordField.text = @"";
        }
    } else {
        _emailField.placeholder = @"Enter your email.";
        _emailField.text = @"";
    }
}

- (IBAction)createNewAccountBtnPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"SignUpPageSegue" sender:sender];
}

@end
