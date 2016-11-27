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

@interface ApplicationFormPageViewController () <FSCalendarDataSource, FSCalendarDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate> {
    
    NSString *applicationTypeStr, *dateStr, *timeStr;
    NSDate *selectedDate;
    BOOL procedureToken;

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
    
    _contentTextView.delegate = self;
    
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
    
    [textField resignFirstResponder];
    switch (textField.tag) {
            
        case 0:
            procedureToken = false;
            break;
            
        case 1:
            procedureToken = true;
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
        [_startTimeField resignFirstResponder];
        
    } else {
        
        _endTimeField.text =  [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
        [_endTimeField resignFirstResponder];
        
    }    
}

- (void)animationAfterConfirm {
    
    UIView *inputView = [self.view viewWithTag:100];
    _inputViewLocConst.constant = -(self.navigationController.navigationBar.frame.size.height+inputView.frame.size.height);
    [UIView animateWithDuration:1.2 animations:^{
        
        [self.view layoutSubviews];
        
    }];
}

#pragma mark - Text Field Delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return false;
        
    }
    return true;
    
}

- (IBAction)applyBtnPressed:(UIButton *)sender {
    
    NSString *startDateStr = _startTimeField.text;
    NSString *endDateStr = _endTimeField.text;
    if ([StrValidationFilter applicationDateValidationFor:startDateStr] && [StrValidationFilter applicationDateValidationFor:endDateStr]) {
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *startDate = [dateFormatter dateFromString:startDateStr];
        NSDate *endDate = [dateFormatter dateFromString:endDateStr];
        if ([startDate compare:endDate] == NSOrderedAscending) {
            
            NSString *applyDateStr = [NSDateNSStringExchange stringFromUpdateDate:[NSDate date]];
            NSDictionary *applicationInfo = @{@"Agree": @0, @"Content": _contentTextView.text, @"From": startDateStr, @"Type": applicationTypeStr, @"To": endDateStr};
            NSDictionary *application = @{applyDateStr: applicationInfo};
            CurrentUser *localUser = [CurrentUser sharedInstance];
            [localUser uploadApplicationWithDict:application];
            [localUser.applicationList insertObject:application atIndex:0];
            [self.navigationController popViewControllerAnimated:true];
            
        } else {
            
            [self presentAlertControllerWithInfo:@"錯誤的時間順序"];
            
        }
        
    } else {
        
        [self presentAlertControllerWithInfo:@"請假日期選擇不完全"];
        
    }
}

- (void)presentAlertControllerWithInfo:(NSString *)info {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"警告" message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:alertAction];
    [self presentViewController:alertC animated:true completion:nil];
    
}

@end
