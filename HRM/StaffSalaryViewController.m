//
//  StaffSalaryViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffSalaryViewController.h"

@interface StaffSalaryViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UITextField *monthlySalaryTextField;
@property (weak, nonatomic) IBOutlet UITextField *workerInsuranceTextField;
@property (weak, nonatomic) IBOutlet UITextField *healthInsuranceTextField;
@property (weak, nonatomic) IBOutlet UITextField *payCutTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullAttendanceTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalSalaryTextField;

@end

@implementation StaffSalaryViewController
{
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnEdit:(UIBarButtonItem *)sender {
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
