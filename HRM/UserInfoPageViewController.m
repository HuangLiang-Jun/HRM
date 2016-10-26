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
@property (weak, nonatomic) IBOutlet UITextField *genderField;
@property (weak, nonatomic) IBOutlet UITextField *positionField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;
@property (weak, nonatomic) IBOutlet UITextField *IDCardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *heightField;
@property (weak, nonatomic) IBOutlet UITextField *weightField;
@property (weak, nonatomic) IBOutlet UITextField *bloodTypeField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *marriageField;
@property (weak, nonatomic) IBOutlet UITextField *mailingAddressField;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation UserInfoPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CurrentUser signOutUserAccount];
}

- (IBAction)completeAccountCreationBtnPressed:(UIButton *)sender {
    NSArray<UITextField *> *userInfoField = @[_nameField, _genderField, _positionField, _birthdayField, _IDCardNumberField, _heightField, _weightField, _bloodTypeField, _cellphoneNumberField, _marriageField, _mailingAddressField];
    NSArray *userInfoKey = @[@"Gender", @"Position", @"Birthday", @"IDCardNumber", @"Height", @"Weight", @"BloodType", @"CellphoneNumber", @"Marriage", @"MailingAddress"];
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    CurrentUser *localUser = [CurrentUser sharedInstance];
    for (int i = 0; i < userInfoField.count; i += 1) {
        if (![userInfoField[i].text isEqualToString:@""]) {
            switch (i) {
                case 0:
                    localUser.displayName = userInfoField[0].text;
                    [[NSUserDefaults standardUserDefaults] setValue:localUser.displayName forKey:@"DisplayName"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    break;
                default:
                    [userInfo setValue:userInfoField[i].text forKey:userInfoKey[i - 1]];
                    break;
            }
        } else {
            userInfoField[i].placeholder = @"Please enter compatible info.";
            userInfoField[i].text = @"";
        }
    }
    if (userInfo.count == userInfoKey.count && [localUser.downloadState isEqual:@1]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [localUser updateUserInfoWithDict:userInfo];
        });
        [self.navigationController popToRootViewControllerAnimated:true];
    }
}

@end
