//
//  SalaryViewController.m
//  HRM
//
//  Created by JimSu on 2016/10/22.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SalaryViewController.h"
#import "SalarySums.h"


@import Firebase;
@import FirebaseDatabase;

@interface SalaryViewController ()
@property (weak, nonatomic) IBOutlet UITextField *monthlySalaryTextField;
@property (weak, nonatomic) IBOutlet UITextField *workerInsuranceTextField;
@property (weak, nonatomic) IBOutlet UITextField *healthInsuranceTextField;
@property (weak, nonatomic) IBOutlet UITextField *payCutTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullAttendanceTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalSalaryTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBtn;


@property (strong,nonatomic) FIRDatabaseReference *databaseRef;

@end

@implementation SalaryViewController
{
    int monthlySalary,hourSalary,leaveHour,payCut,fullAttendance,totalSalary,workerInsurance,healthInsurance;
    NSMutableDictionary *snapShotDic,*downloadSalaryDic;
    NSArray *salaryArr;
    double totalHours,workHours;
    FIRDatabaseReference *updateRef;
    Boolean downLoadStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    snapShotDic = [NSMutableDictionary new];
    downloadSalaryDic = [NSMutableDictionary new];
    //下載出勤紀錄的路徑
    _databaseRef = [[[[[FIRDatabase database]reference]child:@"Attendance"] child:@"黃亮鈞"] child:@"2016-10"];

    //上傳本薪資料到資料庫的路徑
    updateRef = [[[[FIRDatabase database]reference]child:@"Salary"]child:@"黃亮鈞"];
   
    NSLog(@"ref: %@",_databaseRef);
    monthlySalary = 32000;
    totalHours = 176;
    leaveHour = 0;
    workerInsurance = 1234;
    healthInsurance = 789;
    
    [self downLoadSalary];
    [self changeSalary];
    [self loadData];
    
    //下方為計算時薪
    SalarySums *get = [[SalarySums alloc] init];
    hourSalary = [get hourSalary:monthlySalary totalHours:totalHours];
    NSLog(@"時薪為: %i", hourSalary);
    
    //下方為計算請假扣薪
    payCut = [get askForLeave:leaveHour hourSalary:hourSalary];
    self.payCutTextField.text = [[NSString alloc] initWithFormat:@"%i", payCut];
    NSLog(@"事假扣薪: %i", payCut);
    
    //下方為計算全勤獎金
    fullAttendance = [get fullAttendance:leaveHour];
    self.fullAttendanceTextField.text = [[NSString alloc] initWithFormat:@"%i", fullAttendance];
    NSLog(@"全勤獎金為: %i", fullAttendance);
    
    if (downLoadStatus) {
        //下方為計算實領薪水
        [self totalSalarySums];
        NSLog(@"實領薪水為: %i", totalSalary);
    }
    
    //放置Navigation Bar button item
    UIBarButtonItem * testItem = [[UIBarButtonItem alloc] initWithTitle:@"TEST" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = testItem;
}

- (void) totalSalarySums {
    totalSalary = monthlySalary - workerInsurance - healthInsurance + fullAttendance - payCut;
}


//抓取資料庫內的打卡記錄
-(void) loadData {
    [_databaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        snapShotDic = snapshot.value;
        //NSLog(@"test: %@",snapShotDic);
        
        NSArray *arr = snapShotDic.allValues;
        //NSLog(@"arr: %@",arr);
        
        for(int i = 0; i<arr.count; i++) {
            NSMutableDictionary *dic2 = arr[i];
            
            NSArray *arr2 = dic2.allValues;
            //NSLog(@"arr2 %@",arr2);
            
            NSString *first = arr2.firstObject;
            NSString *last = arr2.lastObject;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            NSDate *date1 = [dateFormatter dateFromString:last];
            NSDate *date2 = [dateFormatter dateFromString:first];
            
            NSTimeInterval aTime = [date2 timeIntervalSinceDate:date1];
            double hour = (double)(aTime / 3600);
            NSLog(@"hour: %1.2f", hour);
            
            workHours += hour;
            
            downLoadStatus = true;
        };
        NSLog(@"workHour: %1.2f", workHours);
    }];
    if (snapShotDic) {
        NSLog(@"snapShotDic: %@", snapShotDic);
        
    }
}

-(void) updateSalary {
    NSString *monthlySalaryDic = [[NSString alloc] initWithFormat:@"%@", self.monthlySalaryTextField.text];
    NSString *workerInsuranceDic = [[NSString alloc] initWithFormat:@"%@", self.workerInsuranceTextField.text];
    NSString *healthInsuranceDic = [[NSString alloc] initWithFormat:@"%@", self.healthInsuranceTextField.text];
    
    NSDictionary *salaryDic = @{@"monthlysalay":monthlySalaryDic,@"workerInsurance":workerInsuranceDic,@"healthInsurance":healthInsuranceDic};
    [updateRef updateChildValues:salaryDic withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"update salary error: %@",error);
            
        }
    }];
}

-(void) downLoadSalary {
    [updateRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        downloadSalaryDic = snapshot.value;
        //NSLog(@"downloadSalary: %@",snapshot.value);
        
        salaryArr = downloadSalaryDic.allValues;
        NSLog(@"salaryArr: %@", salaryArr);
        self.monthlySalaryTextField.text = salaryArr[0];
        self.workerInsuranceTextField.text = salaryArr[1];
        self.healthInsuranceTextField.text = salaryArr[2];
        
        [self totalSalarySums];
        self.totalSalaryTextField.text = [[NSString alloc] initWithFormat:@"%i", totalSalary];
        
    }];
}

-(void) changeSalary {
    monthlySalary = [salaryArr[0] intValue];
    workerInsurance = [salaryArr[1] intValue];
    healthInsurance = [salaryArr[2] intValue];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editBtnAction:(id)sender {
    if ([_editBtn.title  isEqual: @"編輯"]) {
        [_editBtn setTitle:@"完成"];
        _monthlySalaryTextField.enabled = YES;
        _workerInsuranceTextField.enabled = YES;
        _healthInsuranceTextField.enabled = YES;
        [self downLoadSalary];
        
    } else if ([_editBtn.title  isEqual: @"完成"]) {
        [_editBtn setTitle:@"編輯"];
        _monthlySalaryTextField.enabled = NO;
        _workerInsuranceTextField.enabled = NO;
        _healthInsuranceTextField.enabled = NO;
        
        [self updateSalary];
        monthlySalary = [self.monthlySalaryTextField.text intValue];
        workerInsurance = [self.workerInsuranceTextField.text intValue];
        healthInsurance = [self.healthInsuranceTextField.text intValue];
        
        [self totalSalarySums];
        self.totalSalaryTextField.text = [[NSString alloc] initWithFormat:@"%i", totalSalary];
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
