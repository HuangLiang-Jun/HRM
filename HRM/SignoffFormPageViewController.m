//
//  SignoffFormPageViewController.m
//  HRM
//
//  Created by 李家舜 on 2016/11/28.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SignoffFormPageViewController.h"

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
    
//    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
//    ApplicationListPageTableViewController *applicationPTableVC = self.navigationController.viewControllers[index-1];
//    NSDictionary *applicationDict = applicationPTableVC.selectedApplicationDict;
//    NSString *applyDateStr = [applicationDict allKeys].firstObject;
//    NSDictionary *infoDict = [applicationDict allValues].firstObject;
//    _typeField.text = [infoDict objectForKey:@"Type"];
//    _fromField.text = [infoDict objectForKey:@"From"];
//    _toField.text = [infoDict objectForKey:@"To"];
//    _applyTime.text = applyDateStr;
//    _contentTextView.text = [infoDict objectForKey:@"Content"];
//    
}

@end
