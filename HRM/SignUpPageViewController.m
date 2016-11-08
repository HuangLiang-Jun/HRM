//
//  SignUpPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/17.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignUpPageViewController.h"
#import "CurrentUser.h"

@interface SignUpPageViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reconfirmPasswordField;

@end

@implementation SignUpPageViewController

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return true;
    
}

#pragma mark - Create User Account Btn Func

- (IBAction)createUserAccountBtnPressed:(UIButton *)sender {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (![_emailField.text isEqualToString:@""] && _passwordField.text.length >= 6) {
        
        if ([_reconfirmPasswordField.text isEqualToString:_passwordField.text]) {
            
            localUser.password = _passwordField.text;
            [localUser createUserAccount];
            [self performSegueWithIdentifier:@"UserInfoPageSegue" sender:sender];
            
        } else {
            
            _reconfirmPasswordField.placeholder = @"Reconfirm your password";
            _reconfirmPasswordField.text = @"";
            
        }
        
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

@end
