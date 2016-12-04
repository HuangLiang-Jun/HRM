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

#import <SVProgressHUD/SVProgressHUD.h>

@interface SignUpPageViewController () <UITextFieldDelegate> {
    
    BOOL procedureToken, emailToken, pwdToken, reconfirmPWDToken;
    
}

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *reconfirmPWDField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subviewLayoutContraint;

@end

@implementation SignUpPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emailField.tag = 10;
    _emailField.delegate = self;
    
    _pwdField.tag = 11;
    _pwdField.delegate = self;
    
    _reconfirmPWDField.tag = 12;
    _reconfirmPWDField.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    if (user != nil) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        [localUser signOutUserAccount];
        
    }
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
        case 10:
            emailToken = false;
            if (_subviewLayoutContraint.constant != 0.0) {
                
                [self animateAfterReconfirmPWDInputed];
                
            }
            break;
        
        case 11:
            pwdToken = false;
            procedureToken = false;
            if (_subviewLayoutContraint.constant != 0.0) {
                
                [self animateAfterReconfirmPWDInputed];
                
            }
            break;
        
        case 12:
            reconfirmPWDToken = false;
            procedureToken = false;
            if (_subviewLayoutContraint.constant == 0.0) {
            
                [self animateBeforeReconfirmPWDInputed];
                
            }
            break;
            
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text.length != 0) {
        
        [self validationDependenceOfTextField:textField];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self validationDependenceOfTextField:textField];
    return true;
    
}

- (void)validationDependenceOfTextField:(UITextField *)textField {
    
    if (_subviewLayoutContraint.constant != 0.0) {
        
        [self animateAfterReconfirmPWDInputed];
        
    }
    [textField resignFirstResponder];
    NSString *str = textField.text;
    switch (textField.tag) {
            
        case 10:
            if ([StrValidationFilter emailValidationFor:str]) {
                
                emailToken = true;
                if (!pwdToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"電子郵件格式錯誤"];
                
            }
            break;
            
        case 11:
            if ([StrValidationFilter passwordValidationFor:str]) {
                
                pwdToken = true;
                if (reconfirmPWDToken) {
                    
                    if ([str isEqualToString:_reconfirmPWDField.text]) {
                        
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
            
        case 12:
            if ([StrValidationFilter passwordValidationFor:str]) {
                
                reconfirmPWDToken = true;
                if (emailToken) {
                    
                    if ([str isEqualToString:_pwdField.text]) {
                        
                        procedureToken = true;
                        
                    } else {
                        
                        [self presentAlertControllerWithInfo:@"密碼比對失敗"];
                        
                    }
                    
                } else {
                    
                    [self shiftToThePreviousOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"比對密碼格式錯誤"];
                
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

- (void)animateBeforeReconfirmPWDInputed {
    
    _subviewLayoutContraint.constant = -100.0;
    [UIView animateWithDuration:0.6 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

- (void)animateAfterReconfirmPWDInputed {
    
    _subviewLayoutContraint.constant = 0.0;
    [UIView animateWithDuration:0.6 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

#pragma mark - Create User Account Btn Func

- (IBAction)createUserAccountBtnPressed:(UIButton *)sender {
    
    if (_subviewLayoutContraint.constant != 0.0) {
        
        [self animateAfterReconfirmPWDInputed];
        
    }
    NSArray <UITextField *>*fieldArr = @[_emailField, _pwdField, _reconfirmPWDField];
    for (int i = 0; i < fieldArr.count; i += 1) {
        
        [fieldArr[i] resignFirstResponder];
        NSString *str = fieldArr[i].text;
        switch (i) {
                
            case 0:
                if ([StrValidationFilter emailValidationFor:str]) {
                    
                    emailToken = true;
                    
                    
                } else {
                    
                    [self presentAlertControllerWithInfo:@"電子郵件格式錯誤"];
                    
                }
                break;
                
            case 1:
                if ([StrValidationFilter passwordValidationFor:str]) {
                    
                    pwdToken = true;
                    
                    
                } else {
                    
                    [self presentAlertControllerWithInfo:@"密碼格式錯誤"];
                    
                }
                break;
                
            case 2:
                if ([StrValidationFilter passwordValidationFor:str]) {
                    
                    reconfirmPWDToken = true;
                    if (emailToken) {
                        
                        if ([str isEqualToString:_pwdField.text]) {
                            
                            procedureToken = true;
                            
                        } else {
                            
                            [self presentAlertControllerWithInfo:@"密碼比對失敗"];
                            
                        }
                        
                    }
                    
                } else {
                    
                    [self presentAlertControllerWithInfo:@"比對密碼格式錯誤"];
                    
                }
                break;
                
        }
        
    }
    if (emailToken && procedureToken) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        localUser.email = _emailField.text;
        localUser.password = _pwdField.text;
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(segueToUserInfoPage) name:@"UserAccountCreated" object:nil];
        [notificationCenter addObserver:self selector:@selector(errHandler:) name:@"AccountCreationErr" object:nil];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
        [SVProgressHUD setForegroundColor:[UIColor darkGrayColor]];
        [SVProgressHUD setRingThickness:4.0];
        
        [SVProgressHUD show];
        
        [localUser createUserAccount];
        
    }
}

- (void)segueToUserInfoPage {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:@"UserAccountCreated" object:nil];
    [notificationCenter removeObserver:self name:@"AccountCreationErr" object:nil];
    
    [SVProgressHUD dismiss];
    
    [self performSegueWithIdentifier:@"UserInfoPageSegue" sender:nil];
    
}

#pragma mark - Cancel Account Creation Btn Func

- (IBAction)cancelAccountCreationBtnPressed:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    
}

#pragma mark- Error Handler Func

- (void)errHandler:(NSNotification *)notification {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:@"UserAccountCreated" object:nil];
    [notificationCenter removeObserver:self name:@"AccountCreationErr" object:nil];
    
    [SVProgressHUD dismiss];
    
    NSDictionary *errDict = notification.userInfo;
    NSString *errNameStr = [errDict objectForKey:@"NSLocalizedDescription"];
    
    [self presentAlertControllerWithInfo:errNameStr];
    
}

@end
