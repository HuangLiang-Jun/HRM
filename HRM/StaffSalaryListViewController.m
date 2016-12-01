//
//  StaffSalaryListViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffSalaryListViewController.h"
#import "SalaryListTableViewCell.h"
#import "SalarySums.h"
#import "StaffSalaryViewController.h"
@import Firebase;
@import FirebaseDatabase;

@interface StaffSalaryListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *salaryTableView;

@end

@implementation StaffSalaryListViewController
{
    FIRDatabaseReference *staffNameRef;
    FIRDatabaseReference *staffWorkingHoursRef;
    
    NSArray *staffName;
    NSDictionary *staffHours;
    NSDictionary *staffsSalaryInfo;
    NSMutableArray *finalSalaryArr;
    
    StaffSalaryViewController *detailVC;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self downLoadStaffWorkingSalaryInfo];
    finalSalaryArr = [NSMutableArray new];

    
}

- (void) downLoadStaffWorkingSalaryInfo{
    staffNameRef = [[[FIRDatabase database]reference]child:@"Salary"];
    
    //Get All Staff Name.
    [staffNameRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //  會有時間差要加loading畫面
        if (snapshot.value != [NSNull null]){
            staffsSalaryInfo = snapshot.value;
            //staffName = [[NSMutableArray alloc] initWithArray:allName.allValues];
            staffName = staffsSalaryInfo.allKeys;
            NSLog(@"snapshotValue: %@",staffName);
            
            
            for (int i = 0; i <staffName.count; i++) {
                
                NSDictionary *staffInfo = staffsSalaryInfo[staffName[i]][@"2016-10"];
                NSLog(@"staff Salary: %@",staffInfo);
                //NSArray *salary = staffInfo.allValues;
                //NSLog(@"allValue%@",salary);
                int insurance = [staffInfo[@"healthInsurance"]intValue] + [staffInfo[@"workerInsurance"]intValue];
                int totalSalary = [staffInfo[@"monthlysalay"]intValue] + 1000 - insurance ;
                NSString *tmpStr = [NSString stringWithFormat:@"%i",totalSalary];
                NSDictionary *tmp = @{@"Name":staffName[i],@"Salary":tmpStr};
                [finalSalaryArr addObject: tmp];
            }
            
            
            [self.salaryTableView reloadData];
            
            
            
        }
        
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView DataSouce

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return finalSalaryArr.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SalaryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.salaryLabel.text = [NSString stringWithFormat:@"%@ 元",finalSalaryArr[indexPath.row][@"Salary"]];
    
    cell.staffNameLabel.text = finalSalaryArr[indexPath.row][@"Name"];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StaffSalaryViewController"];
    NSString *nameStr = finalSalaryArr[indexPath.row][@"Name"];
    detailVC.nameStr = nameStr;
    [self showViewController:detailVC sender:nil];
    
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
