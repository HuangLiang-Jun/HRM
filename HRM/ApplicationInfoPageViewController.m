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
    
    UIImage *backgroundImage = [UIImage imageNamed:@"backgroundGreen.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    [_typeField setUserInteractionEnabled:false];
    [_fromField setUserInteractionEnabled:false];
    [_toField setUserInteractionEnabled:false];
    [_applyTime setUserInteractionEnabled:false];
    [_contentTextView setUserInteractionEnabled:false];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    ApplicationListPageTableViewController *applicationPTableVC = self.navigationController.viewControllers[index-1];
    NSDictionary *applicationDict = applicationPTableVC.selectedApplicationDict;
    NSString *applyDate = [applicationDict allKeys].firstObject;
    NSDictionary *infoDict = [applicationDict objectForKey:applyDate];
    _typeField.text = [infoDict objectForKey:@"Type"];
    _fromField.text = [infoDict objectForKey:@"From"];
    _toField.text = [infoDict objectForKey:@"To"];
    _applyTime.text = applyDate;
    _contentTextView.text = [infoDict objectForKey:@"Content"];
    
}

@end
