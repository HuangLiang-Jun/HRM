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
#import "ApplicationListPageTableViewController.h"

@interface ApplicationFormPageViewController () <FSCalendarDataSource, FSCalendarDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    UIView *optionBlocker;
    NSDate *selectedDate;
    NSString *dateString, *timeString;
    UIPickerView *timePicker;
}

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UITextField *subjectField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vyc;


@property (weak, nonatomic) IBOutlet UITextView *contentView;

@end

@implementation ApplicationFormPageViewController

static int dependence;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _vyc.constant = self.view.frame.size.height;
    
        [self.view layoutIfNeeded];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadView {
    [super loadView];
    _calendar.firstWeekday = 2;
    _calendar.allowsSelection = false;
    timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.2, self.view.frame.size.width, self.view.frame.size.height * 0.4)];
    timePicker.transform = CGAffineTransformScale(timePicker.transform, 2.0, 2.0);
    timePicker.alpha = 0.1;
    timePicker.showsSelectionIndicator = true;
    timePicker.dataSource = self;
    timePicker.delegate = self;
    optionBlocker = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height * 1.0 + 20.0, self.view.frame.size.width, self.view.frame.size.height * 0.2 - 20.0)];
    optionBlocker.alpha = 0.1;
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    confirmBtn.frame = CGRectMake(optionBlocker.frame.size.width * 0.1, optionBlocker.frame.size.height * 0.2, optionBlocker.frame.size.width * 0.8, optionBlocker.frame.size.height * 0.6);
    [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:40.0]];
    [confirmBtn addTarget:self action:@selector(confirmBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [optionBlocker addSubview:confirmBtn];
//    _startDateBtn.titleLabel.adjustsFontSizeToFitWidth = true;
//    _endDateBtn.titleLabel.adjustsFontSizeToFitWidth = true;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    dateString = [NSDateNSStringExchange stringFromChosenDate:date];
    selectedDate = date;
    [timePicker selectRow:0 inComponent:0 animated:true];
    [self animateToSelectTime];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 1000;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger count = row % 10 + 9;
    NSString *timeCounter;
    if (count < 10) {
        timeCounter = [NSString stringWithFormat:@"0%ld:00", count];
    } else {
        timeCounter = [NSString stringWithFormat:@"%ld:00", count];
    }
    return timeCounter;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger count = row % 10 + 9;
    if (count < 10) {
        timeString = [NSString stringWithFormat:@"0%ld:00", count];
    } else {
        timeString = [NSString stringWithFormat:@"%ld:00", count];
    }
}

- (void)confirmBtnPressed {
    [self animationAfterConfirm];
    [_calendar deselectDate:selectedDate];
    _calendar.allowsSelection = false;
    dateString = [NSString stringWithFormat:@"%@ %@", dateString, timeString];
    if (dependence == 0) {
//        _startDateBtn.titleLabel.text = dateString;
    } else {
//        _endDateBtn.titleLabel.text = dateString;
    }
}

- (IBAction)startTime:(UIButton *)sender {
    dependence = 0;
    _calendar.allowsSelection = true;
}

- (IBAction)endTime:(UIButton *)sender {
    dependence = 1;
    _calendar.allowsSelection = true;
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
    _vyc.constant =  self.view.frame.size.height-300;
    [UIView animateWithDuration:2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}

- (void)animateToSelectTime {
    timeString = @"09:00";
    [self.view addSubview:timePicker];
    [self.view addSubview:optionBlocker];
    [UIView animateWithDuration:1.0 animations:^{
        timePicker.frame = CGRectMake(0.0, self.view.frame.size.height * 0.4 + 20.0, self.view.frame.size.width, self.view.frame.size.height * 0.4);
        timePicker.backgroundColor = [UIColor lightTextColor];
        timePicker.alpha = 0.9;
        optionBlocker.frame = CGRectMake(0.0, self.view.frame.size.height * 0.8 + 20.0, self.view.frame.size.width, self.view.frame.size.height * 0.2 - 20.0);
        optionBlocker.backgroundColor = [UIColor lightTextColor];
        optionBlocker.alpha = 0.9;
    }];
}

- (void)animationAfterConfirm {
    [UIView animateWithDuration:1.0 animations:^{
        timePicker.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.4);
        timePicker.alpha = 0.1;
        optionBlocker.frame = CGRectMake(0.0, self.view.frame.size.height * 1.0 + 20.0, self.view.frame.size.width, self.view.frame.size.height * 0.2 - 20.0);
        optionBlocker.alpha = 0.1;
    } completion:^(BOOL finished) {
        if (finished) {
            [timePicker removeFromSuperview];
            [optionBlocker removeFromSuperview];
        }
    }];
}

@end
