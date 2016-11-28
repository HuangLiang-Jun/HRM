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
    BulletinBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (sortKeysArr != nil){
        for (int i = 0;i <sortKeysArr.count;i++) {
            if (i == indexPath.row) {
                NSLog(@"sortKey:%@",sortKeysArr[i]);
                NSString *tmp = [NSString stringWithFormat:@"%@",sortKeysArr[i]];
                NSDictionary *valueDic = [comm.bulletinsDict valueForKey:tmp];
                NSLog(@"tmp:%@ , valueDict%@",tmp,valueDic);
                cell.titleLabel.text = valueDic[@"Title"];
                cell.detailLabel.text = valueDic[@"Detail"];
                cell.updateDateLabel.text = valueDic[@"UpdateDate"];
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
        [sortKeysArr addObject:[NSNumber numberWithInt:[allKeys[i] intValue]]];
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
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
