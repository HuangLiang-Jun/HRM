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

- (void)loadView {
    [super loadView];
    
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = [NSDate date];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    [_birthdayField setInputView:datePicker];
    
}

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *dateStr = [NSDateNSStringExchange stringFromChosenDate:[NSDate date]];
    _birthdayField.placeholder = dateStr;
    
}

#pragma mark - textFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
            
        case 0:
            nameToken = false;
            break;
            
        case 1: {
            
            birthdayToken = false;
            NSString *dateStr = [NSDateNSStringExchange stringFromChosenDate:[NSDate date]];
            _birthdayField.text = dateStr;
            
        }
            break;
            
        case 2:
            idCardNumToken = false;
            break;
            
        case 3:
            cellPhoneNumToken = false;
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
            if (str.length != 0) {
                
                nameToken = true;
                if (!birthdayToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"請輸入使用者姓名"];
                
            }
            break;
            
        case 1:
            if ([StrValidationFilter birthdayValidationFor:str]) {
                
                birthdayToken = true;
                if (!idCardNumToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"出生日期格式錯誤"];
                
            }
            break;
            
        case 2:
            if ([StrValidationFilter idCardNumValidationFor:str]) {
                
                idCardNumToken = true;
                if (!cellPhoneNumToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"請輸入合法的身分證字號"];
                
            }
            break;
            
        case 3:
            if ([StrValidationFilter cellPhoneNumValidationFor:str]) {
                
                cellPhoneNumToken = true;
                
            } else {
                
                [self presentAlertControllerWithInfo:@"手機號碼格式錯誤"];
                
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

- (void)updateTextField:(UIDatePicker *)sender {
    
    UIDatePicker *datePicker = (UIDatePicker *)_birthdayField.inputView;
    datePicker.backgroundColor = [UIColor clearColor];
    _birthdayField.text = [NSDateNSStringExchange stringFromChosenDate:datePicker.date];
    
}

#pragma  mark - Complete Account Creation Btn Func

- (IBAction)completeAccountCreationBtnPressed:(UIButton *)sender {
    
    for (UITextField *textField in self.view.subviews) {
        
        if ([textField isFirstResponder]) {
            
            [textField endEditing:true];
            
        }
        
    }
    if (nameToken && birthdayToken && idCardNumToken && cellPhoneNumToken) {
        
        CurrentUser *localUser = [CurrentUser sharedInstance];
        localUser.displayName = _nameField.text;
        [localUser updateUserDefaultsWithValue:localUser.displayName andKey:@"DisplayName"];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"Birthday": _birthdayField.text, @"IDCardNumber": _idCardNumberField.text, @"CellphoneNumber": _cellphoneNumberField.text}];
        
        [localUser uploadUserInfoWithDict:userInfo];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(completeAccountCreation) name:@"UserSignedOut" object:nil];
        [localUser signOutUserAccount];
        
    }
}

- (void)completeAccountCreation {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UserSignedOut" object:nil];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
    
}

@end
