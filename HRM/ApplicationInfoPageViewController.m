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

@property (weak, nonatomic) IBOutlet UITextField *subjectField;
@property (weak, nonatomic) IBOutlet UITextField *fromField;
@property (weak, nonatomic) IBOutlet UITextField *toField;
@property (weak, nonatomic) IBOutlet UITextView *contentView;

@end

@implementation ApplicationInfoPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadView {
    [super loadView];
    ApplicationListPageTableViewController *applicationListPageTableVC = self.navigationController.viewControllers[0];
    NSDictionary *applicationInfo = applicationListPageTableVC.selectedApplicationInfo;
    _subjectField.text = applicationInfo[@"Subject"];
    _subjectField.userInteractionEnabled = false;
    _fromField.text = applicationInfo[@"From"];
    _fromField.userInteractionEnabled = false;
    _toField.text = applicationInfo[@"To"];
    _toField.userInteractionEnabled = false;
    _contentView.text = applicationInfo[@"Content"];
    _contentView.userInteractionEnabled = false;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
}

- (IBAction)confirmApplicationInfoBtnPressed:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}



@end
