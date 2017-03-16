//
//  BulletinBoarViewController.m
//  HRM
//
//  Created by huang on 2016/11/3.
//  Copyright © 2016年 JimSu. All rights reserved.
//


#import "BulletinBoardViewController.h"
#import "BulletinBoardTableViewCell.h"
#import "AddBulletinViewController.h"
#import "ServerCommunicator.h"
#import "NSDateNSStringExchange.h"
#import "CurrentUser.h"

@interface BulletinBoardViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BulletinBoardViewController
{
    
    ServerCommunicator *comm;
    NSMutableArray *sortKeysArr;
    NSArray *allKeys;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CurrentUser *localUser = [CurrentUser sharedInstance];
    UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.tableView.backgroundView = backgroundImageView;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if ([localUser.auth intValue] == 1 ) {
        
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(nextToAddPage)];
        self.navigationItem.rightBarButtonItem = addBtn;
        
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sortBulletinAllKeys) name:RELOAD_DATA object:nil];
    comm = [ServerCommunicator shareInstance];
    [comm downLoadBulletinsFromFBDB];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  comm.bulletinsDict.allKeys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 讓cell隨著內容的多寡去調整高度
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 100.0;
    
    BulletinBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    
    if (cell == nil) {
        
        cell = [[BulletinBoardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (sortKeysArr != nil){
        
        for (int i = 0; i <sortKeysArr.count; i++) {
            
            if (i == indexPath.row) {
                
                NSString *tmp = [NSString stringWithFormat:@"%@",sortKeysArr[i]];
                NSDictionary *valueDic = [comm.bulletinsDict valueForKey:tmp];
                NSLog(@"tmp:%@ , valueDict%@",tmp,valueDic);
                cell.titleLabel.text = valueDic[@"Title"];
                cell.detailLabel.text = valueDic[@"Detail"];
                cell.updateDateLabel.text = valueDic[@"UpdateDate"];
                NSLog(@"updateDate:%@",valueDic[@"UpdateDate"]);
                
                return cell;
            }

        }
    }
    return cell;
}

- (void) sortBulletinAllKeys{
    sortKeysArr = [NSMutableArray new];
    
    allKeys = comm.bulletinsDict.allKeys;
    
    NSLog(@"arr: %@",allKeys);
    
    for (int i = 0; i <allKeys.count; i++) {
        //[sortKeysArr addObject:[NSNumber numberWithInt:[allKeys[i] intValue]]];
       
        // 位元數不足改成 long
        [sortKeysArr addObject:[NSNumber numberWithLong:[allKeys[i] longLongValue]]];
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:false];
    [sortKeysArr sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    NSLog(@"arr2: %@",sortKeysArr);
    [self.tableView reloadData];
    
}

-(void) nextToAddPage{
   
    AddBulletinViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddBulletinViewController"];
    [self showViewController:vc sender:nil];
    
}

@end
