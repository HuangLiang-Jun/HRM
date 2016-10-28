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

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    if (user != nil) {
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"LocalUserInfoFetchCompleted" object:nil];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:true];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    _emailField.text = localUser.email;
    _passwordField.text = localUser .password;
    
}

#pragma mark - Sign In Btn Func

- (IBAction)signInBtnPressed:(UIButton *)sender {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (![_emailField.text isEqualToString:@""]) {
        
        localUser.email = _emailField.text;
        if (![_passwordField.text isEqualToString:@""]) {
            
            localUser.password = _passwordField.text;
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"LocalUserInfoFetchCompleted" object:nil];
             [localUser signInUserAccount];
        
        } else {
            
            _passwordField.placeholder = @"Enter your password.";
            _passwordField.text = @"";
            
        }
        
    } else {
        
        _emailField.placeholder = @"Enter your email.";
        _emailField.text = @"";
        
    }
}

- (void)discriminateUserAuth {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"LocalUserInfoFetchCompleted" object:nil];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    switch (localUser.auth.intValue) {
            
        case 0:
            [self performSegueWithIdentifier:@"EmployeeHomePageSegue" sender:nil];
            break;
            
        default:
            [self performSegueWithIdentifier:@"SupervisorHomePageSegue" sender:nil];
            break;
            
    }
}

#pragma mark - Sign Up Btn Func

- (IBAction)createNewAccountBtnPressed:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"SignUpPageSegue" sender:sender];
    
}

@end
