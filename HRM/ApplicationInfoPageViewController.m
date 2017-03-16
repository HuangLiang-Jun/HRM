//
//  ApplicationInfoViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/10/24.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ApplicationInfoPageViewController.h"
#import "ApplicationListPageTableViewController.h"
#import "CurrentUser.h"

@interface ApplicationInfoPageViewController ()

@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UITextField *fromField;
@property (weak, nonatomic) IBOutlet UITextField *toField;
@property (weak, nonatomic) IBOutlet UITextField *applyTime;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation ApplicationInfoPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_typeField setUserInteractionEnabled:false];
    [_fromField setUserInteractionEnabled:false];
    [_toField setUserInteractionEnabled:false];
    [_applyTime setUserInteractionEnabled:false];
    [_contentTextView setUserInteractionEnabled:false];
    
    NSString *applyDateStr = [_applicationDict allKeys].firstObject;
    NSDictionary *infoDict = [_applicationDict allValues].firstObject;
    _typeField.text = [infoDict objectForKey:@"Type"];
    _fromField.text = [infoDict objectForKey:@"From"];
    _toField.text = [infoDict objectForKey:@"To"];
    _applyTime.text = applyDateStr;
    _contentTextView.text = [infoDict objectForKey:@"Content"];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

@end
