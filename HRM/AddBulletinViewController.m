//
//  AddBulletinViewController.m
//  HRM
//
//  Created by huang on 2016/11/26.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "AddBulletinViewController.h"

@interface AddBulletinViewController ()
@property (weak, nonatomic) IBOutlet UITextField *setTittleTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextField;

@end

@implementation AddBulletinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendNewBulletinBtnPressed:(UIButton *)sender {
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
