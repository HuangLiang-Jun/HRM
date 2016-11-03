//
//  UserInfoPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/17.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "UserInfoPageViewController.h"
#import "CurrentUser.h"

@interface UserInfoPageViewController ()


@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;
@property (weak, nonatomic) IBOutlet UITextField *IDCardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneNumberField;


@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation UserInfoPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma  mark - Complete Account Creation Btn Func

- (IBAction)completeAccountCreationBtnPressed:(UIButton *)sender {
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (![_nameField.text isEqualToString:@""]) {
        
        localUser.displayName = _nameField.text;
        [localUser updateUserDefaultsWithValue:localUser.displayName andKey:@"DisplayName"];
        
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"Birthday": _birthdayField, @"IDCardNumber": _IDCardNumberField, @"CellphoneNumber": _cellphoneNumberField}];
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
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UserSignedOut" object:nil];
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
    
}

-(IBAction) textFieldDoneEditing: (id) sender
{
    [sender resignFirstResponder];
}


@end
