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
    
    BOOL procedureToken, emailToken, pwdToken, reconfirmPWDToken;
    
}

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reconfirmPasswordField;

@end

@implementation SignUpPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emailField.tag = 0;
    _emailField.delegate = self;
    
    _passwordField.tag = 1;
    _passwordField.delegate = self;
    
    _reconfirmPasswordField.tag = 2;
    _reconfirmPasswordField.delegate = self;
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    if (user != nil) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        [localUser signOutUserAccount];
        
    }
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
        case 0:
            emailToken = false;
            break;
        
        case 1:
            pwdToken = false;
            procedureToken = false;
            break;
        
        case 2:
            reconfirmPWDToken = false;
            procedureToken = false;
            break;
            
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text.length != 0) {
        
        [self validationDependenceOfTextField:textField];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length != 0) {
        
        [self validationDependenceOfTextField:textField];
        
    }
    return true;
    
}

- (void)validationDependenceOfTextField:(UITextField *)textField {
    
    [textField resignFirstResponder];
    NSString *str = textField.text;
    switch (textField.tag) {
            
        case 0:
            if ([StrValidationFilter emailValidationFor:str]) {
                
                emailToken = true;
                if (!pwdToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"電子郵件格式錯誤"];
                
            }
            break;
            
        case 1:
            if ([StrValidationFilter passwordValidationFor:str]) {
                
                pwdToken = true;
                if (reconfirmPWDToken) {
                    
                    if ([str isEqualToString:_reconfirmPasswordField.text]) {
                        
                        procedureToken = true;
                        
                    } else {
                        
                        [self presentAlertControllerWithInfo:@"密碼比對失敗"];
                        
                    }
                    
                } else {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"密碼格式錯誤"];
                
            }
            break;
            
        case 2:
            if ([StrValidationFilter passwordValidationFor:str]) {
                
                reconfirmPWDToken = true;
                if (emailToken) {
                    
                    if ([str isEqualToString:_passwordField.text]) {
                        
                        procedureToken = true;
                        
                    } else {
                        
                        [self presentAlertControllerWithInfo:@"密碼比對失敗"];
                        
                    }
                    
                } else {
                    
                    [self shiftToThePreviousOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"密碼格式錯誤"];
                
            }
            break;
            
    }
}

- (void)shiftToTheNextOneOfTextField:(UITextField *)textField {
    
    NSInteger nextTag = textField.tag+1;
    UIResponder *nextResponder = [self.view viewWithTag:nextTag];
    if ([nextResponder isKindOfClass:[textField class]]) {
        
        [nextResponder becomeFirstResponder];
        
    }
}

- (void)shiftToThePreviousOneOfTextField:(UITextField *)textField {
    
    NSInteger previousTag = textField.tag-1;
    UIResponder *previousResponder = [self.view viewWithTag:previousTag];
    if ([previousResponder isKindOfClass:[textField class]]) {
        
        [previousResponder becomeFirstResponder];
        
    }
}

- (void)presentAlertControllerWithInfo:(NSString *)info {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"警告" message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:alertAction];
    [self presentViewController:alertC animated:true completion:nil];
    
}

#pragma mark - Create User Account Btn Func

- (IBAction)createUserAccountBtnPressed:(UIButton *)sender {
    
    for (UITextField *textField in self.view.subviews) {
        
        if ([textField isFirstResponder]) {
            
            [textField endEditing:true];
            
        }
        
    }
    if (emailToken && procedureToken) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        localUser.email = _emailField.text;
        localUser.password = _passwordField.text;
        [localUser createUserAccount];
        [self performSegueWithIdentifier:@"UserInfoPageSegue" sender:sender];
        
    }
}

- (IBAction)cancelAccountCreationBtnPressed:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    
}

@end
