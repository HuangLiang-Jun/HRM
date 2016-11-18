//
//  SchedulingViewController.m
//  HRM
//
//  Created by huang on 2016/10/20.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SchedulingViewController.h"
#import "HMSegmentedControl.h"
#import "FSCalendar.h"
#import "NSDateNSStringExchange.h"
#import "CollectionViewCell.h"
#import "RecipeCollectionHeaderView.h"
#import "CurrentUser.h"

#define NOTIFICATION_KEY @"reloadData"

@interface SchedulingViewController ()<FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *schedulingCalendar;
@property (weak, nonatomic) IBOutlet UICollectionView *schedulingCollectionView;


@property (strong,nonatomic)  NSDate *nextMonth;
@end

@implementation SchedulingViewController
{
    NSInteger segmentIndex;
    UIColor *selectColor;
    NSString *classStr;
    
    // 路徑：上傳班表
    FIRDatabaseReference *updateSchedulingRef;
    
    int officialHolidayHours;
    int annualLeaveHours;
    NSMutableDictionary *colorForVactionDic,*attendanceSheetForNextMonthDic;
    NSMutableArray *firstShiftArr,*secondShiftArr,*dayoff,*annualLeaveArr;
    CurrentUser *staffInfo;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    colorForVactionDic = [NSMutableDictionary new];
    attendanceSheetForNextMonthDic = [NSMutableDictionary new];
    staffInfo = [CurrentUser sharedInstance];
    
    // for collectionView
    firstShiftArr = [NSMutableArray new];
    secondShiftArr = [NSMutableArray new];
    dayoff = [NSMutableArray new];
    annualLeaveArr = [NSMutableArray new];
    
    _schedulingCollectionView.delegate = self;
    _schedulingCollectionView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadCollectionData) name:NOTIFICATION_KEY object:nil];
    
    NSDate *today = [NSDate date];
    _nextMonth = [_schedulingCalendar dateByAddingMonths:1 toDate:today];
    // 設定排班功能月曆顯示月份
    [_schedulingCalendar setCurrentPage:_nextMonth];
    
    updateSchedulingRef = [[[[[FIRDatabase database]reference]
                            child:@"Secheduling"]
                            child:[NSDateNSStringExchange stringFromYearAndMonth:_nextMonth]]
                            child:staffInfo.displayName];
    
    //-- Loading Next Month VacationHours --//
    
    FIRDatabaseReference *downloadSchedulingRef = [[[[FIRDatabase database]reference]child:@"Secheduling"]child:[NSDateNSStringExchange stringFromYearAndMonth:_nextMonth]];
    [downloadSchedulingRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        // 下載排班狀況
        NSLog(@"dict for scheduling : %@",dict);
    }];
    
    FIRDatabaseReference *officialHolidayRef = [[[FIRDatabase database]reference] child:@"vacation"];
    [officialHolidayRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSMutableDictionary *dict = snapshot.value;
        NSString *nextMonthKey = [NSDateNSStringExchange stringFromYearAndMonth:_nextMonth];
        officialHolidayHours = [dict[nextMonthKey] intValue];
        NSLog(@"officialHolidayHours: %i",officialHolidayHours);
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NOTIFICATION_KEY //Notification以一個字串(Name)下去辨別
         object:self
         userInfo:nil];
    }];
    
    FIRDatabaseReference *annualLeaveRef = [[[[[FIRDatabase database]reference]
                        child:@"StaffInformation"]
                        child:staffInfo.displayName]
                        child:@"AnnualLeave"];
   
    [annualLeaveRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
       
        NSDictionary *dict = snapshot.value;
        annualLeaveHours = [dict[@"2016"]intValue];
        NSLog(@"annualLeaveHours: %i",annualLeaveHours);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NOTIFICATION_KEY //Notification以一個字串(Name)下去辨別
         object:self
         userInfo:nil];
    }];
    
    //setting segmentControl
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc]
                                            initWithSectionImages:@[[UIImage imageNamed:@"morningDeselect"],
                                                                    [UIImage imageNamed:@"nightDeselect"],
                                                                    [UIImage imageNamed:@"dayoffDeselect"],
                                                                    [UIImage imageNamed:@"specialDeselect"]]
                                            sectionSelectedImages:@[[UIImage imageNamed:@"morningSelect"],
                                                                    [UIImage imageNamed:@"nightSelect"],
                                                                    [UIImage imageNamed:@"dayoffSelect"],
                                                                    [UIImage imageNamed:@"specialSelect"]]];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.frame = CGRectMake(0, 0, viewWidth, 50);
    segmentedControl.selectionIndicatorHeight = 3.0f;
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventAllEvents];
    [self.view addSubview:segmentedControl];
    
    // Default setting.
    selectColor = [UIColor colorWithRed:0.196 green:0.729 blue:0.682 alpha:1];
    segmentIndex = 0;
    classStr = @"早班";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}


- (IBAction)submitBtnPressed:(UIButton *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否確定送出?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"送出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self submitWorkSchedule];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
    
}

-(void) submitWorkSchedule{
    [updateSchedulingRef setValue:attendanceSheetForNextMonthDic withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Update Scheduling Error : %@",error);
        }
    }];
    
}


#pragma -mark Calendar Method

-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    
    NSString  *selectDateStr = [NSDateNSStringExchange stringFromChosenDate:date];
    // for collectionView
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd"];
    NSString *monthAndDay = [formatter stringFromDate:date];
    
    switch (segmentIndex) {
        case 0:
            [firstShiftArr addObject:monthAndDay];
            break;
        case 1:
            [secondShiftArr addObject:monthAndDay];
            break;
        case 2:
            [dayoff addObject:monthAndDay];
            break;
        case 3:
            [annualLeaveArr addObject:monthAndDay];
            break;
        default:
            break;
    }
    //update firebase data
    [colorForVactionDic setValue:selectColor forKey:selectDateStr];
    [attendanceSheetForNextMonthDic setObject:classStr forKey:selectDateStr];
    [_schedulingCalendar reloadData];
    [_schedulingCollectionView reloadData];
    NSLog(@"加入班別時間: %@",attendanceSheetForNextMonthDic);
}

-(void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date{
    
    NSString *dateStr = [NSDateNSStringExchange stringFromChosenDate:date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd"];
    NSString *removeStr = [formatter stringFromDate:date];
    
    NSMutableArray *classArr = [[NSMutableArray alloc]initWithObjects:firstShiftArr,secondShiftArr,dayoff,annualLeaveArr, nil];
    for (NSInteger i = 0; i < classArr.count ; i++) {
        for (NSInteger a = 0; a < [classArr[i] count]; a++) {
            NSString *indexStr = classArr[i][a];
            if ([removeStr isEqualToString:indexStr]) {
                [classArr[i] removeObjectAtIndex:a];
                [_schedulingCollectionView reloadData];
            }
        }
    }
    
    [attendanceSheetForNextMonthDic removeObjectForKey:dateStr];
    
    NSLog(@"取消班別時間: %@",attendanceSheetForNextMonthDic);
    
    [_schedulingCollectionView reloadData];
}

-(UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date{
    NSString *key = [NSDateNSStringExchange stringFromChosenDate:date];
    if (colorForVactionDic != nil) {
        if ([colorForVactionDic.allKeys containsObject:key] ) {
            return colorForVactionDic[key];
        }
    }
    return nil;
}

#pragma -mark CollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 5;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView;
    
    RecipeCollectionHeaderView *headerView = [_schedulingCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    
    // prepare title & image
    NSArray *statusArr = @[@"排班狀況",@"早班",@"晚班",@"例休",@"特休"];
    NSArray *headerImage = @[[UIImage imageNamed:@"grayheader.png"],
                             [UIImage imageNamed:@"blueheader.png"],
                             [UIImage imageNamed:@"orangeheader.png"],
                             [UIImage imageNamed:@"redheader.png"],
                             [UIImage imageNamed:@"greenheader.png"]];
    
    // setting section info.
    
    switch (indexPath.section) {
        case 0:
            headerView.leaveHours.hidden = true;
            break;
        case 3:
            headerView.leaveHours.hidden = false;
            headerView.leaveHours.text = [NSString stringWithFormat:@"剩餘時數:%i",officialHolidayHours];
            break;
        
        case 4:
            headerView.leaveHours.hidden = false;
            headerView.leaveHours.text = [NSString stringWithFormat:@"剩餘時數:%i",annualLeaveHours];
            break;
    }
    
    headerView.headerLabel.text = statusArr[indexPath.section];
    headerView.headerImage.image = headerImage[indexPath.section];
    reusableView = headerView;
    
    return reusableView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (_schedulingCalendar.allowsMultipleSelection == true) {
        switch (section) {
            case 0:
                return 4;
                break;
            case 1:
                if (firstShiftArr > 0){
                    return firstShiftArr.count;
                }
                break;
            case 2:
                if (secondShiftArr > 0){
                    return secondShiftArr.count;
                }
                break;
            case 3:
                if (dayoff > 0){
                    return dayoff.count;
                }
                break;
            case 4:
                if (annualLeaveArr > 0){
                    return annualLeaveArr.count;
                }
                break;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            cell.schedulingCollevtionViewLabel.text = @[@"早",@"晚",@"例假",@"特休"][indexPath.row];
            break;
        case 1:
            
            cell.schedulingCollevtionViewLabel.text = firstShiftArr[indexPath.row];
            break;
        case 2:
            cell.schedulingCollevtionViewLabel.text = secondShiftArr[indexPath.row];
            break;
        case 3:
            cell.schedulingCollevtionViewLabel.text = dayoff[indexPath.row];
            break;
        case 4:
            cell.schedulingCollevtionViewLabel.text = annualLeaveArr[indexPath.row];
            break;
    }
    return cell;
}

#pragma - mark SegmentedControl Method

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    segmentIndex = segmentedControl.selectedSegmentIndex;
    
    switch (segmentedControl.selectedSegmentIndex ) {
        case 0:
            selectColor = [UIColor
                           colorWithRed:0.196
                           green:0.729
                           blue:0.682
                           alpha:1];
            classStr = @"早班";
            break;
            
        case 1:
            selectColor = [UIColor orangeColor];
            classStr = @"晚班";
            break;
            
        case 2:
            selectColor = [UIColor redColor];
            classStr = @"例休";
            break;
            
        case 3:
            selectColor = [UIColor
                           colorWithRed:0.196
                           green:0.792
                           blue:0.094
                           alpha:1];
            classStr = @"特休";
            break;
    }
}



-(void) reloadCollectionData {

    [_schedulingCollectionView reloadData];
    NSLog(@"reloadData");
}

@end
