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
    UIImage *staffImage ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    staffDataManager = [StaffInfoDataManager sharedInstance];
    [staffDataManager downLoadStaffInfo:_staffListTableView ];
    
    staffDataManager.imageStatus = false;
    
    
    
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
    NSString *tmpUID = staffDataManager.allStaffInfoDict[staffDataManager.allStaffInfoDict.allKeys[indexPath.row]][@"UID"];
    NSString *URLString = [staffDataManager.allStaffThumbnailDict valueForKey:tmpUID];
    NSLog(@"tmpUID:%@",tmpUID);
    NSLog(@"urlString: %@",URLString);
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"name:%@ download image fail: %@",cell.nameLabel.text,error);
            return ;
        }
        staffImage = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (staffImage != nil){
                cell.staffImageView.image = staffImage;
            }
            
        });
        
    }];
    
    [task resume];
    
    //    NSData *imdata = [[NSUserDefaults standardUserDefaults]valueForKey:staffDataManager.allStaffInfoDict.allKeys[indexPath.row]];
    //    UIImage *staffImage = [UIImage imageWithData:imdata];
    //    if (staffImage != nil){
    //        cell.staffImageView.image = staffImage;
    //
    //    } else {
    //        if ([staffDataManager.allStaffInfoDict.allKeys[indexPath.row] isEqualToString:@"李家舜"] && staffDataManager.imageStatus == false){
    //            cell.staffImageView.image = [UIImage imageNamed:@"Li.png"];
    //        }else{
    //            cell.staffImageView.image = [UIImage imageNamed:@"head.png"];
    //        }
    //
    //
    //    }
    
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
    
    if (staffDataManager.editStatus || staffDataManager.imageStatus) {
        [_staffListTableView reloadData];
        
        staffDataManager.imageStatus = false;
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
