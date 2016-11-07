//
//  StaffInfoViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffInfoViewController.h"

@interface StaffInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *staffImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *authSegment;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneTextField;

@end

@implementation StaffInfoViewController{
    NSMutableDictionary *info;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    info = [_staffInfoDict valueForKey:@"Info"];
    NSLog(@"info :%@",info);
    
    _birthdayTextField.text = [info valueForKey:@"Birthday"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
