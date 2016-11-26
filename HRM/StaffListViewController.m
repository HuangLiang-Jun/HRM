//
//  StaffListViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffListViewController.h"
#import "StaffInfoDataManager.h"
#import "StaffListTableViewCell.h"
#import "StaffInfoViewController.h"

@interface StaffListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *staffListTableView;

@end

@implementation StaffListViewController
{
    StaffInfoDataManager *staffDataManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    staffDataManager = [StaffInfoDataManager sharedInstance];
    [staffDataManager downLoadStaffInfo:_staffListTableView ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return staffDataManager.allStaffInfoDict.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    StaffListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    //下載需要時間 所以要做Loading畫面..
    
    cell.nameLabel.text = staffDataManager.allStaffInfoDict.allKeys[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    StaffInfoViewController *staffInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"StaffInfoViewController"];
    
    staffInfo.staffInfoDict = staffDataManager.allStaffInfoDict.allValues[indexPath.row];
    staffInfo.nameStr = staffDataManager.allStaffInfoDict.allKeys[indexPath.row];
    
    [self showViewController:staffInfo sender:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (staffDataManager.editStatus) {
        [_staffListTableView reloadData];
    }
    
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
