//
//  UserInfoPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/17.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "UserInfoPageViewController.h"
#import "StrValidationFilter.h"
#import "CurrentUser.h"

@interface UserInfoPageViewController () <UITextFieldDelegate> {
    
    BOOL nameToken, birthdayToken, idCardNumToken, cellPhoneNumToken;
    
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;
@property (weak, nonatomic) IBOutlet UITextField *idCardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneNumberField;

@end

@implementation UserInfoPageViewController

#pragma mark - View Lifecycle

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameField.tag = 0;
    _nameField.delegate = self;
    
    _birthdayField.tag = 1;
    _birthdayField.delegate = self;
    
    _idCardNumberField.tag = 2;
    _idCardNumberField.delegate = self;
    
    _cellphoneNumberField.tag = 3;
    _cellphoneNumberField.delegate = self;
    
}

#pragma mark - textFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
            
        case 0:
            nameToken = false;
            break;
            
        case 1:
            birthdayToken = false;
            break;
            
        case 2:
            idCardNumToken = false;
            break;
            
        case 3:
            cellPhoneNumToken = false;
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

#pragma  mark - Complete Account Creation Btn Func

- (IBAction)completeAccountCreationBtnPressed:(UIButton *)sender {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (![_nameField.text isEqualToString:@""]) {
        
        localUser.displayName = _nameField.text;
        [localUser updateUserDefaultsWithValue:localUser.displayName andKey:@"DisplayName"];
        
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"Birthday": _birthdayField, @"IDCardNumber": _idCardNumberField, @"CellphoneNumber": _cellphoneNumberField}];
    int count = 0;
    for (NSString *key in [userInfo allKeys]) {
        
        UITextField *textField = [userInfo valueForKey:key];
        if (![textField.text isEqualToString:@""]) {
            
            [userInfo setValue:textField.text forKey:key];
            
        } else {
            
            count += 1;
            textField.placeholder = @"Please enter compatible info.";
            textField.text = @"";
            
        }
        
    }
    if (count == 0) {
        
        [localUser uploadUserInfoWithDict:userInfo];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(prepareForSignInPage) name:@"UserSignedOut" object:nil];
        CurrentUser *localUser = [CurrentUser sharedInstance];
        [localUser signOutUserAccount];

    }
}

- (void)prepareForSignInPage {
    
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    [notificationCenter removeObserver:self name:@"UserSignedOut" object:nil];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
    
}

@end
