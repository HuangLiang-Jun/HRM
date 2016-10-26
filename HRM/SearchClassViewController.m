//
//  SearchClassViewController.m
//  HRM
//
//  Created by huang on 2016/10/25.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SearchClassViewController.h"
#import "CheckClassCollectionCell.h"
#import "CheckClassCollectionReusable.h"
#import "FSCalendar.h"
#import "NSDateNSStringExchange.h"
@import Firebase;
@import FirebaseDatabase;

@interface SearchClassViewController ()<FSCalendarDelegate,FSCalendarDataSource,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *checkClassTableCollectionView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (strong, nonatomic) FIRDatabaseReference *classRef;
@end

@implementation SearchClassViewController
{
    NSMutableDictionary *dic;
    NSMutableArray *onDuty,*offDuty,*dayoff,*annualLeave;
    NSString *monthStrKey;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // for collectionView
    onDuty = [NSMutableArray new];
    offDuty = [NSMutableArray new];
    dayoff = [NSMutableArray new];
    annualLeave = [NSMutableArray new];
    
    monthStrKey = [NSDateNSStringExchange stringFromYearAndMonth: _calendar.currentPage];
    
    _checkClassTableCollectionView.delegate = self;
    _checkClassTableCollectionView.dataSource = self;
    // ref
    _classRef = [[[FIRDatabase database]reference]child:@"Secheduling"];
    
    // DownLoad Data
    [_classRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        dic = snapshot.value;
        NSLog(@"valueDic: %@",dic);
    
        // 顯示所有人班別 第一次運算 第二次運算--num.100!
        NSArray *keyForName = [[dic valueForKey:monthStrKey]allKeys];
        NSLog(@"keyfornameArr:%@",keyForName);
        NSString *keyForDate = [NSDateNSStringExchange stringFromChosenDate:_calendar.today];
        NSLog(@"keyfordate(selectDay): %@",keyForDate);
        for (NSInteger i = 0; i < keyForName.count ; i++) {
            NSString *name = keyForName[i];
            NSMutableDictionary *classInfo =[[dic valueForKey:monthStrKey] valueForKey:name];
            
            NSString *classStr = [classInfo valueForKey:keyForDate];
            
            if ([classStr isEqualToString:@"早班"]) {
                [onDuty addObject:name];
            }else if ([classStr isEqualToString:@"晚班"]) {
                [offDuty addObject:name];
            }else if ([classStr isEqualToString:@"例休"]) {
                [dayoff addObject:name];
            }else if ([classStr isEqualToString:@"特休"]){
                [annualLeave addObject:name];
            }
            [_checkClassTableCollectionView reloadData];
        }
    }];
    
}

#pragma -MARK Calendar Method

-(void)calendarCurrentPageDidChange:(FSCalendar *)calendar{
    // change page
    
    monthStrKey = [NSDateNSStringExchange stringFromYearAndMonth: calendar.currentPage];

}

-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    // 顯示所有人班別
    NSArray *keyForName = [[dic valueForKey:monthStrKey]allKeys];
    NSLog(@"keyfornameArr:%@",keyForName);
    NSString *keyForDate = [NSDateNSStringExchange stringFromChosenDate:date];
    NSLog(@"keyfordate(selectDay): %@",keyForDate);

    // 重新點選日期將陣列初始化
    onDuty = [NSMutableArray new];
    offDuty = [NSMutableArray new];
    dayoff = [NSMutableArray new];
    annualLeave = [NSMutableArray new];
    
    for (NSInteger i = 0; i < keyForName.count ; i++) {
        NSString *name = keyForName[i];
        NSMutableDictionary *classInfo =[[dic valueForKey:monthStrKey] valueForKey:name];
        
        NSString *classStr = [classInfo valueForKey:keyForDate];
        
        if ([classStr isEqualToString:@"早班"]) {
            [onDuty addObject:name];
        }else if ([classStr isEqualToString:@"晚班"]) {
            [offDuty addObject:name];
        }else if ([classStr isEqualToString:@"例休"]) {
            [dayoff addObject:name];
        }else if ([classStr isEqualToString:@"特休"]){
            [annualLeave addObject:name];
        }
        [_checkClassTableCollectionView reloadData];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma -MARK CollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    
    return 4;
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = nil;
    
    CheckClassCollectionReusable *headerView = [_checkClassTableCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ClassHeaderView" forIndexPath:indexPath];
    
    NSArray *arr = @[@"早班",@"晚班",@"例休",@"特休"];
    headerView.headerLabel.text = arr[indexPath.section];
    reusableView = headerView;
    
    return reusableView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            if (onDuty > 0){
                return onDuty.count;
            }
            break;
        case 1:
            if (offDuty > 0){
                return offDuty.count;
            }
            break;
        case 2:
            if (dayoff > 0){
                return dayoff.count;
            }
            break;
        case 3:
            if (annualLeave > 0){
                return annualLeave.count;
            }
            break;
        default:
            break;
    }
    return 0;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CheckClassCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            
            cell.cellLabel.text = onDuty[indexPath.row];
            break;
        case 1:
            cell.cellLabel.text = offDuty[indexPath.row];
            break;
        case 2:
            cell.cellLabel.text = dayoff[indexPath.row];
            break;
        case 3:
            cell.cellLabel.text = annualLeave[indexPath.row];
            break;
        default:
            break;
    }
    return cell;
}




@end
