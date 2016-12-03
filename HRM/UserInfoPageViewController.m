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

@interface UserInfoPageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate> {
    
    BOOL nameToken, birthdayToken, idCardNumToken, cellPhoneNumToken;
    
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;
@property (weak, nonatomic) IBOutlet UITextField *idCardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneNumberField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subviewLayoutContraint;

@end

@implementation UserInfoPageViewController

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [recognizer setNumberOfTapsRequired:1];
    
    UIImageView *imageView = [self.view viewWithTag:10];
    [imageView setUserInteractionEnabled:true];
    [imageView addGestureRecognizer:recognizer];
    
    imageView.layer.cornerRadius = imageView.frame.size.height*0.5;
    imageView.layer.masksToBounds = true;
    imageView.layer.borderWidth = 0.0;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = [NSDate date];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    [_birthdayField setInputView:datePicker];
    
}

-(void)singleTapping:(UIGestureRecognizer *)recognizer {
    
    UIAlertController *alert =  [UIAlertController alertControllerWithTitle:@"請選擇照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相機" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"從相簿中選擇" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:Cancel];
    
    [self presentViewController:alert animated:true completion:nil];
    
}

-(void) launchImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType{
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        
        UIImagePickerController *imagePickerC = [UIImagePickerController new];
        
        imagePickerC.delegate = self;
        imagePickerC.allowsEditing = true;
        imagePickerC.sourceType = sourceType;
        
        [self presentViewController:imagePickerC animated:true completion:nil];
        
    } else {
        
        [self presentAlertControllerWithInfo:@"此裝置上找不到該選項"];
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameField.tag = 11;
    _nameField.delegate = self;
    
    _birthdayField.tag = 12;
    _birthdayField.delegate = self;
    
    _idCardNumberField.tag = 13;
    _idCardNumberField.delegate = self;
    
    _cellphoneNumberField.tag = 14;
    _cellphoneNumberField.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *dateStr = [NSDateNSStringExchange stringFromChosenDate:[NSDate date]];
    _birthdayField.placeholder = dateStr;
    
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    UIImageView *imageView = [self.view viewWithTag:10];
    [imageView setImage:image];
    
    [picker dismissViewControllerAnimated:true completion:nil];
    
}

#pragma mark - textFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
            
        case 11:
            nameToken = false;
            if (_subviewLayoutContraint.constant != 0.0) {
                
                [self animateAfterCellphoneNumInputed];
                
            }
            break;
            
        case 12: {
            
            birthdayToken = false;
            NSString *dateStr = [NSDateNSStringExchange stringFromChosenDate:[NSDate date]];
            _birthdayField.text = dateStr;
            if (_subviewLayoutContraint.constant != 0.0) {
                
                [self animateAfterCellphoneNumInputed];
                
            }
            break;
            
        }
            
        case 13:
            idCardNumToken = false;
            if (_subviewLayoutContraint.constant == 0.0) {
                
                [self animateBeforeIDCardNumInputed];
            
            }
            break;
            
        case 14:
            cellPhoneNumToken = false;
            if (_subviewLayoutContraint.constant == 0.0) {
                
                [self animateBeforeIDCardNumInputed];
                
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
        
        [self animateAfterCellphoneNumInputed];
        
    }
    [textField resignFirstResponder];
    NSString *str = textField.text;
    switch (textField.tag) {
            
        case 11:
            if (str.length != 0) {
                
                nameToken = true;
                if (!birthdayToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"請輸入使用者姓名"];
                
            }
            break;
            
        case 12:
            if ([StrValidationFilter birthdayValidationFor:str]) {
                
                birthdayToken = true;
                if (!idCardNumToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"出生日期格式錯誤"];
                
            }
            break;
            
        case 13:
            if ([StrValidationFilter idCardNumValidationFor:str]) {
                
                idCardNumToken = true;
                if (!cellPhoneNumToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"請輸入合法的身分證字號"];
                
            }
            break;
            
        case 14:
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

- (void)animateBeforeIDCardNumInputed {
    
    _subviewLayoutContraint.constant = -200.0;
    [UIView animateWithDuration:0.6 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

- (void)animateAfterCellphoneNumInputed {
    
    _subviewLayoutContraint.constant = 0.0;
    [UIView animateWithDuration:0.6 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

#pragma  mark - Complete Account Creation Btn Func

- (IBAction)completeAccountCreationBtnPressed:(UIButton *)sender {
    
    if (_subviewLayoutContraint.constant != 0.0) {
        
        [self animateAfterCellphoneNumInputed];
        
    }
    NSArray <UITextField *>*fieldArr = @[_nameField, _birthdayField, _idCardNumberField, _cellphoneNumberField];
    for (int i = 0; i < fieldArr.count; i += 1) {
        
        [fieldArr[i] resignFirstResponder];
        NSString *str = fieldArr[i].text;
        switch (i) {
                
            case 0:
                if (str.length != 0) {
                    
                    nameToken = true;
                    
                } else {
                    
                    [self presentAlertControllerWithInfo:@"請輸入使用者姓名"];
                    
                }
                break;
                
            case 1:
                if ([StrValidationFilter birthdayValidationFor:str]) {
                    
                    birthdayToken = true;
                    
                } else {
                    
                    [self presentAlertControllerWithInfo:@"出生日期格式錯誤"];
                    
                }
                break;
                
            case 2:
                if ([StrValidationFilter idCardNumValidationFor:str]) {
                    
                    idCardNumToken = true;
                    
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
