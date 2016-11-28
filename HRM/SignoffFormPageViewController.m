//
//  SignoffFormPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/11/28.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignoffFormPageViewController.h"
#import "SignoffListTableViewController.h"
#import "CurrentUser.h"

@interface SignoffFormPageViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UITextField *fromField;
@property (weak, nonatomic) IBOutlet UITextField *toField;
@property (weak, nonatomic) IBOutlet UITextField *applyDateField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;


@end

@implementation SignoffFormPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_usernameField setUserInteractionEnabled:false];
    [_typeField setUserInteractionEnabled:false];
    [_fromField setUserInteractionEnabled:false];
    [_toField setUserInteractionEnabled:false];
    [_applyDateField setUserInteractionEnabled:false];
    [_contentTextView setUserInteractionEnabled:false];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    SignoffListTableViewController *signoffListTableVC = self.navigationController.viewControllers[index-1];
    NSDictionary *signoffFormDict = signoffListTableVC.selectedSignoffFormDict;
    
    NSString *newApplyDateStr = [signoffFormDict allKeys].firstObject;
    NSArray<NSString *> *subNewApplyDateStr = [newApplyDateStr componentsSeparatedByString:@"@"];
    
    NSString *applyDateStr = subNewApplyDateStr.firstObject;
    _applyDateField.text = applyDateStr;
    
    NSString *usernameStr = subNewApplyDateStr.lastObject;
    _usernameField.text = usernameStr;
    
    NSDictionary *infoDict = [signoffFormDict allValues].firstObject;
    
    NSString *type = [infoDict objectForKey:@"Type"];
    _typeField.text = type;
    
    NSString *from = [infoDict objectForKey:@"From"];
    _fromField.text = from;
    
    NSString *to = [infoDict objectForKey:@"To"];
    _toField.text = to;
    
    NSString *content = [infoDict objectForKey:@"Content"];
    _contentTextView.text = content;

}

- (IBAction)signoffPassedBtnPressed:(UIButton *)sender {
    
    NSNumber *agreementNum = @1;
    [self setAgreementWith:agreementNum];
    [self.navigationController popViewControllerAnimated:true];
    
}

- (IBAction)signoffRejectedBtnPressed:(UIButton *)sender {
    
    NSNumber *agreementNum = @2;
    [self setAgreementWith:agreementNum];
    [self.navigationController popViewControllerAnimated:true];
    
}

- (void)setAgreementWith:(NSNumber *)agreementNum {
    
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    SignoffListTableViewController *signoffListTableVC = self.navigationController.viewControllers[index-1];
    NSDictionary *signoffFormDict = signoffListTableVC.selectedSignoffFormDict;
    
    NSString *newApplyDateStr = [signoffFormDict allKeys].firstObject;
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    [localUser signoffApplicationWith:newApplyDateStr andAgreement:agreementNum];
    
    for (long long i = 0; i < localUser.applicationList.count; i += 1) {
        
        NSDictionary *signoffFormDict = localUser.applicationList[i];
        NSString *applyDateStr = [signoffFormDict allKeys].firstObject;
        if ([applyDateStr isEqualToString:newApplyDateStr]) {
            
            NSDictionary *infoDict = [signoffFormDict allValues].firstObject;
            NSMutableDictionary *renewInfoDict = [[NSMutableDictionary alloc] initWithDictionary:infoDict];
            [renewInfoDict setObject:agreementNum forKey:@"Agree"];
            NSDictionary *renewSignoffForm = @{newApplyDateStr: renewInfoDict};
            [localUser.applicationList replaceObjectAtIndex:i withObject:renewSignoffForm];
            
        }
    }
}

@end
