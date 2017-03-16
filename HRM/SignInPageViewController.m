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

#import "EmployeeTabBarController.h"
#import "ManagerTabBarController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SignInPageViewController () <UITextFieldDelegate> {
    
    BOOL _emailToken, _pwdToken;
    
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
    _emailField.placeholder = @"請輸入您的電子郵件";
    
    _pwdField.tag = 11;
    _pwdField.delegate = self;
    _pwdField.placeholder = @"請輸入您的密碼";
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    
    NSString *pwdStr = localUser.password;
    NSArray<NSString *> *subPwdStrArr = [pwdStr componentsSeparatedByString:@"."];
    pwdStr = subPwdStrArr.firstObject;
    
    if ([StrValidationFilter emailValidationFor:localUser.email] &&
        [StrValidationFilter passwordValidationFor:pwdStr]) {
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"UserInfoDownloaded" object:nil];
        [notificationCenter addObserver:self selector:@selector(errHandler:) name:@"LogInErr" object:nil];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
        [SVProgressHUD setForegroundColor:[UIColor darkGrayColor]];
        [SVProgressHUD setRingThickness:4.0];
        
        [SVProgressHUD show];
        
        [localUser signInUserAccount];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CurrentUser *localUser = [CurrentUser sharedInstance];
    _emailField.text = localUser.email;
    
    NSString *pwdStr = localUser.password;
    NSArray<NSString *> *subPwdStrArr = [pwdStr componentsSeparatedByString:@"."];
    pwdStr = subPwdStrArr.firstObject;
    
    _pwdField.text = pwdStr;
    
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
        case 10:
            _emailToken = false;
            break;
            
        case 11:
            _pwdToken = false;
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
                
                _emailToken = true;
                if (!_pwdToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"電子郵件格式錯誤"];
                
            }
            break;
            
        case 11:
            if ([StrValidationFilter passwordValidationFor:str]) {
                
                _pwdToken = true;
                
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
                    
                    _emailToken = true;
                    
                } else {
                    
                    [self presentAlertControllerWithInfo:@"電子郵件格式錯誤"];
                    
                }
                break;
                
            case 1:
                if ([StrValidationFilter passwordValidationFor:str]) {
                    
                    _pwdToken = true;
                    
                } else {
                    
                    [self presentAlertControllerWithInfo:@"密碼格式錯誤"];
                    
                }
                break;
                
        }
        
    }
    if (_emailToken && _pwdToken) {
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(discriminateUserAuth) name:@"UserInfoDownloaded" object:nil];
        [notificationCenter addObserver:self selector:@selector(errHandler:) name:@"LogInErr" object:nil];
        
        [SVProgressHUD show];
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        
        localUser.email = _emailField.text;
        
        NSString *pwdStr = [self pwdEditer];
        localUser.password = pwdStr;
        
        [localUser signInUserAccount];

    }
}

- (NSString *)pwdEditer {
    
    NSString *pwdStr = _pwdField.text;
    
    if (pwdStr.length < 6) {
        
        pwdStr = [pwdStr stringByAppendingString:@".00000"];
        pwdStr = [pwdStr substringToIndex:6];
        
    }
    
    return pwdStr;
}

- (void)discriminateUserAuth {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:@"UserInfoDownloaded" object:nil];
    [notificationCenter removeObserver:self name:@"LogInErr" object:nil];
    
    [SVProgressHUD dismiss];
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    
    if (localUser.auth.intValue == 0) {
       UIStoryboard *employeeStoryBoard = [UIStoryboard storyboardWithName:@"Staff" bundle:[NSBundle mainBundle]];
    
        EmployeeTabBarController *staffVC = [employeeStoryBoard instantiateViewControllerWithIdentifier:@"EmployeeTabBarController"];
        
        [self presentViewController:staffVC animated:true completion:nil];
        //[self showViewController:test sender:nil];
        
    } else if (localUser.auth.intValue == 1) {
        
        UIStoryboard *managerStoryBoard = [UIStoryboard storyboardWithName:@"Manager" bundle:[NSBundle mainBundle]];

        ManagerTabBarController *managerVC = [managerStoryBoard instantiateViewControllerWithIdentifier:@"ManagerTabBarController"];
        
        [self presentViewController:managerVC animated:true completion:nil];
    }
}

#pragma mark - Sign Up Btn Func

- (IBAction)createNewAccountBtnPressed:(UIButton *)sender {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:@"UserInfoDownloaded" object:nil];
    [notificationCenter removeObserver:self name:@"LogInErr" object:nil];
    
    if (_subviewLayoutContraint.constant != 0.0) {
        
        [self animateAfterTextFieldInputed];
        
    }
    
    [self performSegueWithIdentifier:@"SignUpPageSegue" sender:sender];
    
}

#pragma mark- Error Handler Func

- (void)errHandler:(NSNotification *)notification {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:@"UserInfoDownloaded" object:nil];
    [notificationCenter removeObserver:self name:@"LogInErr" object:nil];
    
    [SVProgressHUD dismiss];
    
    NSDictionary *errDict = notification.userInfo;
    NSString *errNameStr = [errDict objectForKey:@"NSLocalizedDescription"];
    
    [self presentAlertControllerWithInfo:errNameStr];
    
}

@end
