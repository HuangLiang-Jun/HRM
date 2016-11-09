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

@interface SignUpPageViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reconfirmPasswordField;

@end

@implementation SignUpPageViewController

#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self validationDependenceOfTextField:textField];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self validationDependenceOfTextField:textField];
    return true;
    
}

- (void)validationDependenceOfTextField:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *str = textField.text;
    switch (textField.tag) {
            
        case 0:
            if ([StrValidationFilter emailValidationFor:str]) {
                [_passwordField becomeFirstResponder];
            } else {
                [self presentAlertControllerFor:textField withInfo:@"電子郵件格式錯誤"];
            }
            break;
            
        case 1:
            if ([StrValidationFilter passwordValidationFor:str]) {
                [_reconfirmPasswordField becomeFirstResponder];
            } else {
                [self presentAlertControllerFor:textField withInfo:@"密碼格式錯誤"];
            }
            break;
            
        case 2:
            if ([StrValidationFilter passwordValidationFor:str]) {
                //.
            } else {
                [self presentAlertControllerFor:textField withInfo:@"密碼比對碼格式錯誤"];
            }
            break;
    }
}

- (void)presentAlertControllerFor:(UITextField *)textField withInfo:(NSString *)info {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"警告" message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        textField.text = @"";
        [textField becomeFirstResponder];
        
    }];
    [alertC addAction:alertAction];
    [self presentViewController:alertC animated:true completion:nil];
    
}

#pragma mark - Create User Account Btn Func

- (IBAction)createUserAccountBtnPressed:(UIButton *)sender {
    
    
    
}

@end
