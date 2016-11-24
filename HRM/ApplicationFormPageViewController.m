//
//  ApplicationViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/21.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ApplicationFormPageViewController.h"
#import "FSCalendar.h"
#import "CurrentUser.h"
#import "StrValidationFilter.h"

@interface ApplicationFormPageViewController () <FSCalendarDataSource, FSCalendarDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
    BOOL procedureToken, startDateToken, endDateToken;
    NSString *applicationTypeStr, *dateStr, *timeStr;
    NSDate *selectedDate;
    
}

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITextField *startTimeField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeField;
@property (weak, nonatomic) IBOutlet UIPickerView *timePickerView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewLocConst;

@end

@implementation ApplicationFormPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _calendar.firstWeekday = 2;
    _calendar.dataSource = self;
    _calendar.delegate = self;
    _calendar.allowsSelection = false;
    
    _startTimeField.tag = 0;
    _startTimeField.delegate = self;
    
    _endTimeField.tag = 1;
    _endTimeField.delegate = self;
    
    _timePickerView.dataSource = self;
    _timePickerView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *inputView = [self.view viewWithTag:100];
    _inputViewLocConst.constant = -(self.navigationController.navigationBar.frame.size.height+inputView.frame.size.height);
    [self.view layoutSubviews];
    applicationTypeStr = @"公假";
    selectedDate = [NSDate date];
    
}

#pragma mark - Application Type Segment Func

- (IBAction)applicationTypeSegment:(UISegmentedControl *)sender {
    
    NSInteger selectedIndex = [sender selectedSegmentIndex];
    applicationTypeStr = [sender titleForSegmentAtIndex:selectedIndex];
    
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
            
        case 0:
            procedureToken = false;
            startDateToken = false;
            break;
            
        case 1:
            procedureToken = true;
            endDateToken = false;
            break;
            
    }
    [self animateToSelectDate];
    
}

- (void)animateToSelectDate {
    
    _inputViewLocConst.constant = 0.0;
    [UIView animateWithDuration:1.2 animations:^{
        
        [self.view layoutSubviews];
        
    }];
    _calendar.allowsSelection = true;
    [_calendar selectDate:selectedDate];
    dateStr = [NSDateNSStringExchange stringFromChosenDate:selectedDate];
    [_timePickerView selectRow:0 inComponent:0 animated:true];
    timeStr = @"09:00";
    
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
            if ([StrValidationFilter applicationDateValidationFor:str]) {
                
                startDateToken = true;
                if (!endDateToken) {
                    
                    [self shiftToTheNextOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"請選擇起始日期"];
                
            }
            break;
            
        case 1:
            if ([StrValidationFilter applicationDateValidationFor:str]) {
                
                endDateToken = true;
                if (!startDateToken) {
                    
                    [self shiftToThePreviousOneOfTextField:textField];
                    
                }
                
            } else {
                
                [self presentAlertControllerWithInfo:@"請選擇截止日期"];
                
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

#pragma mark - Calendar Delegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    
    dateStr = [NSDateNSStringExchange stringFromChosenDate:date];
    selectedDate = date;
    
}

#pragma mark - Picker View Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 1000;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    int count = row % 10 + 9;
    NSString *timeCounter;
    if (count < 10) {
        
        timeCounter = [NSString stringWithFormat:@"0%d:00", count];
        
    } else {
        
        timeCounter = [NSString stringWithFormat:@"%d:00", count];
        
    }
    return timeCounter;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    timeStr = [self pickerView:pickerView titleForRow:row forComponent:0];
    
}

#pragma mark - Confirm Btn Func

- (IBAction)confirmBtnPressed:(UIButton *)sender {
    
    [self animationAfterConfirm];
    [_calendar deselectDate:selectedDate];
    _calendar.allowsSelection = false;
    if (procedureToken == false) {
        
        _startTimeField.text =  [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
        
    } else {
        
        _endTimeField.text =  [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
        
    }    
}

- (void)animationAfterConfirm {
    
    UIView *inputView = [self.view viewWithTag:100];
    _inputViewLocConst.constant = -(self.navigationController.navigationBar.frame.size.height+inputView.frame.size.height);
    [UIView animateWithDuration:1.2 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

- (IBAction)applyBtnPressed:(UIButton *)sender {
//    if (![_subjectField.text isEqualToString:@""]) {
//        NSString *applicationDate = [NSDateNSStringExchange stringFromUpdateDate:[NSDate date]];
////        NSDictionary *applicationInfo = @{@"Agree": @0, @"Content": _contentView.text, @"From": _startDateBtn.titleLabel.text, @"Subject": _subjectField.text, @"To": _endDateBtn.titleLabel.text};
////        NSDictionary *application = @{applicationDate: applicationInfo};
//        CurrentUser *localUser = [CurrentUser sharedInstance];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [localUser uploadApplicationWithDict:application];
//        });
//
//        [localUser.applicationList addObject:application];
//        [self.navigationController popToRootViewControllerAnimated:true];
//    } else {
//        _subjectField.placeholder = @"Enter your password.";
//        _subjectField.text = @"";
//    }
    
//    [_bottomViewConst anima];
    
//    [self.view layoutIfNeeded];
    
    
}


//- (void)animationAfterConfirm {
//    [UIView animateWithDuration:1.0 animations:^{
//        timePicker.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.4);
//        timePicker.alpha = 0.1;
//        optionBlocker.frame = CGRectMake(0.0, self.view.frame.size.height * 1.0 + 20.0, self.view.frame.size.width, self.view.frame.size.height * 0.2 - 20.0);
//        optionBlocker.alpha = 0.1;
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [timePicker removeFromSuperview];
//            [optionBlocker removeFromSuperview];
//        }
//    }];
//}

@end
