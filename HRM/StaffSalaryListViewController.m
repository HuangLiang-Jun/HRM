//
//  StaffSalaryListViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffSalaryListViewController.h"
#import "SalaryListTableViewCell.h"

@import Firebase;
@import FirebaseDatabase;

@interface StaffSalaryListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *salaryTableView;

@end

@implementation StaffSalaryListViewController
{
    FIRDatabaseReference *staffNameRef;
    NSArray *staffName;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
    staffNameRef = [[[FIRDatabase database]reference]child:@"UID"];
    
    //Get All Staff Name.
    [staffNameRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //  會有時間差要加loading畫面
        if (snapshot.value != [NSNull null]){
            NSDictionary *allName = snapshot.value;
            //staffName = [[NSMutableArray alloc] initWithArray:allName.allValues];
            staffName = allName.allValues;
            NSLog(@"snapshotValue: %@",staffName);
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
    
    return staffName.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SalaryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.salaryLabel.text = @"30000";
   
    cell.staffNameLabel.text = staffName[indexPath.row];

    
    cell.basicSalaryLabel.text = @"40000";
    
    return cell;
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
