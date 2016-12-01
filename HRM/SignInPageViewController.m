//
//  SignInPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/17.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignInPageViewController.h"
#import "StrValidationFilter.h"
#import "CurrentUser.h"

@interface SignInPageViewController () <UITextFieldDelegate> {
    
    BOOL emailToken, pwdToken;
    
}

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subviewLayoutContraint;

@end

@implementation SignInPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emailField.tag = 10;
    _emailField.delegate = self;
    
    _pwdField.tag = 11;
    _pwdField.delegate = self;
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if ([StrValidationFilter emailValidationFor:localUser.email] && [StrValidationFilter passwordValidationFor:localUser.password]) {
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"UserInfoDownloaded" object:nil];
        [localUser signInUserAccount];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CurrentUser *localUser = [CurrentUser sharedInstance];
    _emailField.text = localUser.email;
    _pwdField.text = localUser.password;
    
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
        case 10:
            emailToken = false;
            break;
            
        case 11:
            pwdToken = false;
            break;
            
    }
    if (_subviewLayoutContraint.constant == 0.0) {
        
        [self animateBeforeTextFieldInputed];
        
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
        
        [self animateAfterTextFieldInputed];
        
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

- (void)presentAlertControllerWithInfo:(NSString *)info {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"警告" message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:alertAction];
    [self presentViewController:alertC animated:true completion:nil];
    
}

- (void)animateBeforeTextFieldInputed {
    
    _subviewLayoutContraint.constant = -100.0;
    [UIView animateWithDuration:0.6 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

- (void)animateAfterTextFieldInputed {
    
    _subviewLayoutContraint.constant = 0.0;
    [UIView animateWithDuration:0.6 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

#pragma mark - Sign In Btn Func

- (IBAction)signInBtnPressed:(UIButton *)sender {
    
    if (_subviewLayoutContraint.constant != 0.0) {
        
        [self animateAfterTextFieldInputed];
        
    }
    NSArray <UITextField *>*fieldArr = @[_emailField, _pwdField];
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
                
        }
        
    }
    if (emailToken && pwdToken) {
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"UserInfoDownloaded" object:nil];
        CurrentUser *localUser = [CurrentUser sharedInstance];
        localUser.email = _emailField.text;
        localUser.password = _pwdField.text;
        [localUser signInUserAccount];
        
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
            
        case 1:
            [self performSegueWithIdentifier:@"SupervisorHomePageSegue" sender:nil];
            break;
            
    }
}

#pragma mark - Sign Up Btn Func

- (IBAction)createNewAccountBtnPressed:(UIButton *)sender {
    
    if (_subviewLayoutContraint.constant != 0.0) {
        
        [self animateAfterTextFieldInputed];
        
    }
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UserInfoDownloaded" object:nil];
    [self performSegueWithIdentifier:@"SignUpPageSegue" sender:sender];
    
}

@end
