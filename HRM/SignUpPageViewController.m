//
//  SignUpPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/17.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignUpPageViewController.h"
#import "StrValidationFilter.h"
#import "CurrentUser.h"

@interface SignUpPageViewController () <UITextFieldDelegate> {
    
    CurrentUser *localUser;
    
}

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reconfirmPasswordField;

@end

@implementation SignUpPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    localUser = [CurrentUser sharedInstance];
    [_emailField becomeFirstResponder];
    
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    if (textField == _emailField) {
        
        NSString *emailStr = textField.text;
        if ([StrValidationFilter emailValidationWithStr:emailStr]) {
            
            localUser.email = emailStr;
            [_passwordField becomeFirstResponder];
            
        } else {
            
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"警告" message:@"E-mail 格式錯誤" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                textField.text = @"";
                [textField becomeFirstResponder];
                
            }];
            [alertC addAction:alertAction];
            [self presentViewController:alertC animated:true completion:nil];
            
        }
    }
    
    
    
    
    return true;
    
}

#pragma mark - Create User Account Btn Func

- (IBAction)createUserAccountBtnPressed:(UIButton *)sender {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    int i = 0;
    NSString *emailStr = _emailField.text;
    if ([StrValidationFilter emailValidationWithStr:emailStr]) {
        
        localUser.email = emailStr;
        i += 1;
        
    } else {
        
        _emailField.placeholder = @"E-mail 格式錯誤";
        _emailField.text = @"";
        
    }
    NSString *pwdStr = _passwordField.text;
    if ([StrValidationFilter passwordValidationWithStr:pwdStr]) {
        
        NSString *reconfirmPwd = _reconfirmPasswordField.text;
        if ([reconfirmPwd isEqualToString:pwdStr]) {
            
            localUser.password = pwdStr;
            
        } else {
            
            _reconfirmPasswordField.placeholder = @"請再次確認密碼";
            _reconfirmPasswordField.text = @"";
            i += 1;
            
        }
        
    } else {
        
        _passwordField.placeholder = @"密碼格式錯誤";
        _passwordField.text = @"";
        
    }
    if (i == 2) {
        
        [localUser createUserAccount];
        [self performSegueWithIdentifier:@"UserInfoPageSegue" sender:sender];
        
    }
}

@end
