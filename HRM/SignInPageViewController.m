//
//  SignInPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/17.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignInPageViewController.h"
#import "CurrentUser.h"

@interface SignInPageViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignInPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)loadView {
    [super loadView];
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (![localUser.email isEqualToString:@""] && ![localUser.password isEqualToString:@""]) {
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"UserInfoDownloaded" object:nil];
        [localUser signInUserAccount];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_emailField becomeFirstResponder];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    _emailField.text = localUser.email;
    _passwordField.text = localUser .password;
    
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return true;
    
}

#pragma mark - Sign In Btn Func

- (IBAction)signInBtnPressed:(UIButton *)sender {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (![_emailField.text isEqualToString:@""] && ![_passwordField.text isEqualToString:@""]) {
        
        localUser.email = _emailField.text;
        localUser.password = _passwordField.text;
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"UserInfoDownloaded" object:nil];
        [localUser signInUserAccount];
        
    } else {
        
        NSDictionary *signInInfo = @{@"Email": _emailField, @"Password": _passwordField};
        for (NSString *key in [signInInfo allKeys]) {
            
            UITextField *textField = [signInInfo valueForKey:key];
            if ([textField.text isEqualToString:@""]) {
                
                textField.placeholder = [NSString stringWithFormat:@"Enter your %@", key];
                textField.text = @"";
                
            }
        }
    }
}

- (void)discriminateUserAuth {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UserInfoDownloaded" object:nil];
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
