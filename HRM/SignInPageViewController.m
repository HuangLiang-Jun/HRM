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

@end

@implementation SignInPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emailField.tag = 0;
    _emailField.delegate = self;
    
    _pwdField.tag = 1;
    _pwdField.delegate = self;
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (localUser.email.length != 0 && localUser.password.length != 0) {
        
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
        case 0:
            emailToken = false;
            break;
            
        case 1:
            pwdToken = false;
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

#pragma mark - Sign In Btn Func

- (IBAction)signInBtnPressed:(UIButton *)sender {
    
    for (UITextField *textField in self.view.subviews) {
        
        if ([textField isFirstResponder]) {
            
            [textField endEditing:true];
            
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
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UserInfoDownloaded" object:nil];
    [self performSegueWithIdentifier:@"SignUpPageSegue" sender:sender];
    
}

@end
