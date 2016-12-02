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

typedef NS_ENUM(NSInteger, ShiftStatus) { // CollectionViewSection
    ScheduleStatus = 0,
    FirstShift,
    SecondShift,
    DayOff,
    AnnualLeave
};

typedef NS_ENUM(NSInteger, SegmentStatus) { // SegmentItems
    
    FirstShiftSegment = 0,
    SecondShiftSegment,
    DayOffSegment,
    AnnualLeaveSegment
};

typedef NS_ENUM(NSInteger, ScheduleItemStatus) { // CollrctionViewCell
    FirstShiftCell = 0,
    SecondShiftCell,
    DayOffCell,
    AnnualLeaveCell
};


@interface SchedulingViewController ()<FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *schedulingCalendar;
@property (weak, nonatomic) IBOutlet UICollectionView *schedulingCollectionView;



@end

@implementation SchedulingViewController
{
    NSInteger segmentIndex;
    UIColor *selectColor;
    NSString *classStr;
    
    // 路徑：上傳班表
    FIRDatabaseReference *updateSchedulingRef;
    //下載上傳特休路徑 update & downLoad AL hours.
    FIRDatabaseReference *annualLeaveRef;
    // 用來儲存當月休假時數跟LocalUser 的特休時數
    int defaultDayOffHours;
    int defaultAnnualLeaveHours;
    int dayOffResult;
    int annualLeaveResult;
    NSMutableDictionary *colorForVactionDic, *attendanceSheetForNextMonthDic, *shiftStatusDict, *shiftTableForDayDict;
    
    //儲存local user 的排班,準備上傳
    NSMutableArray *firstShiftArr, *secondShiftArr, *dayoff, *annualLeaveArr;
    NSArray *allShiftTableStatus;
    
    //用來儲存排班的現況 save for shiftTable's situation
    NSMutableArray *firShiftArr, *secShiftArr, *dayOffArr, *specialArr;
    
    CurrentUser *staffInfo;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    staffInfo = [CurrentUser sharedInstance];
    
    colorForVactionDic = [NSMutableDictionary new];
    attendanceSheetForNextMonthDic = [NSMutableDictionary new];
    shiftTableForDayDict = [NSMutableDictionary new];
    shiftStatusDict = [NSMutableDictionary new];
    // for collectionView
    firstShiftArr = [NSMutableArray new];
    secondShiftArr = [NSMutableArray new];
    dayoff = [NSMutableArray new];
    annualLeaveArr = [NSMutableArray new];
    
    _schedulingCollectionView.delegate = self;
    _schedulingCollectionView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadCollectionData) name:NOTIFICATION_KEY object:nil];
    
    
    NSDate *nextMonth = [_schedulingCalendar dateByAddingMonths:1 toDate:[NSDate date]];
    // 設定排班功能月曆顯示月份
    [_schedulingCalendar setCurrentPage:nextMonth];
    
    updateSchedulingRef = [[[[[FIRDatabase database]reference]
                             child:@"Secheduling"]
                            child:[NSDateNSStringExchange stringFromYearAndMonth:nextMonth]]
                           child:staffInfo.displayName];
    
    //-- Loading Next Month VacationHours --//
    // 下載排班狀況
    FIRDatabaseReference *downloadSchedulingRef = [[[[FIRDatabase database]reference]child:@"Secheduling"]child:[NSDateNSStringExchange stringFromYearAndMonth:nextMonth]];
    NSLog(@"nextMonths:%@",nextMonth);
    [downloadSchedulingRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value != [NSNull null]){
            shiftStatusDict = snapshot.value;
        }
        NSLog(@"dict for scheduling : %@",shiftStatusDict);
        
    }];
    
    FIRDatabaseReference *officialHolidayRef = [[[FIRDatabase database]reference] child:@"vacation"];
    [officialHolidayRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) { // 下載當月例假時數
        
        NSMutableDictionary *dict = snapshot.value;
        NSString *nextMonthKey = [NSDateNSStringExchange stringFromYearAndMonth:nextMonth];
        defaultDayOffHours = [dict[nextMonthKey] intValue];
        dayOffResult = [dict[nextMonthKey] intValue];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NOTIFICATION_KEY //Notification以一個字串(Name)下去辨別
         object:self
         userInfo:nil];
    }];
    
    annualLeaveRef = [[[[[FIRDatabase database]reference]
                        child:@"StaffInformation"]
                       child:staffInfo.displayName]
                      child:@"AnnualLeave"];
    
    [annualLeaveRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // 下載個人特休時數
        NSDictionary *dict = snapshot.value;
        defaultAnnualLeaveHours = [dict[@"2016"]intValue];
        annualLeaveResult = [dict[@"2016"]intValue];
        
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
    [updateSchedulingRef updateChildValues:attendanceSheetForNextMonthDic withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Update Scheduling Error : %@",error);
        }
    }];
    NSString *ALHours = [NSString stringWithFormat:@"%i",annualLeaveResult];
    
    [annualLeaveRef updateChildValues:@{@"2016":ALHours} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Update AL Error: %@",error);
        }
    }];
    [self alertController:@"上傳完成" alertMessage:@"即將離開本畫面" dissmiddVC:true];
    
}

#pragma - mark SegmentedControl Method

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    segmentIndex = segmentedControl.selectedSegmentIndex;
    
    switch (segmentedControl.selectedSegmentIndex ) {
        case FirstShiftSegment:
            selectColor = [UIColor
                           colorWithRed:0.196
                           green:0.729
                           blue:0.682
                           alpha:1];
            classStr = @"早班";
            break;
            
        case SecondShiftSegment:
            selectColor = [UIColor orangeColor];
            classStr = @"晚班";
            break;
            
        case DayOffSegment:
            selectColor = [UIColor redColor];
            classStr = @"例休";
            break;
            
        case AnnualLeaveSegment:
            selectColor = [UIColor
                           colorWithRed:0.196
                           green:0.792
                           blue:0.094
                           alpha:1];
            classStr = @"特休";
            break;
    }
}

#pragma -mark Calendar

-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    
    NSString  *selectDateStr = [NSDateNSStringExchange stringFromChosenDate:date];
    
    //顯示目前排班狀態
    // for search schedule array
    firShiftArr = [NSMutableArray new];
    secShiftArr = [NSMutableArray new];
    dayOffArr = [NSMutableArray new];
    specialArr = [NSMutableArray new];
    NSArray *staffNameArr ;
    if (shiftStatusDict != nil) {
        
        staffNameArr =  shiftStatusDict.allKeys;
        
    }else{
        staffNameArr = [NSArray new];
    }
    
    for (int i = 0; i < staffNameArr.count ; i++) {
        NSString *name = staffNameArr[i];
        NSString *keyForDate = [NSDateNSStringExchange stringFromChosenDate:date];
        // 個人班表
        NSMutableDictionary *personalShiftTableInfoDict = [shiftStatusDict valueForKey:name];
        NSString *kindOfShiftStr = [personalShiftTableInfoDict valueForKey:keyForDate];
        if ([kindOfShiftStr isEqualToString:@"早班"]) {
            [firShiftArr addObject:name];
        }else if ([kindOfShiftStr isEqualToString:@"晚班"]) {
            [secShiftArr addObject:name];
        }else if ([kindOfShiftStr isEqualToString:@"例休"]) {
            [dayOffArr addObject:name];
        }else if ([kindOfShiftStr isEqualToString:@"特休"]){
            [specialArr addObject:name];
        }
        
    }
    allShiftTableStatus = @[firShiftArr,secShiftArr,dayOffArr,specialArr];
    NSLog(@"allshift: %@",allShiftTableStatus);
    
    // for collectionView
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd"];
    NSString *monthAndDay = [formatter stringFromDate:date];
    
    switch (segmentIndex) {
        case FirstShiftSegment:
            [firstShiftArr addObject:monthAndDay];
            break;
        case SecondShiftSegment:
            [secondShiftArr addObject:monthAndDay];
            break;
        case DayOffSegment:
            if (dayOffResult > 0 ) {
                dayOffResult = dayOffResult - 8;
                [dayoff addObject:monthAndDay];
                
            }
            NSLog(@"defaultDayoff: %i",defaultDayOffHours);
            break;
        case AnnualLeaveSegment:
            if (annualLeaveResult > 0){
                annualLeaveResult = annualLeaveResult - 8;
                [annualLeaveArr addObject:monthAndDay];
                
                
            }
            NSLog(@"annDefault: %i",defaultAnnualLeaveHours);
            break;
        default:
            break;
    }
    //update firebase data
    [colorForVactionDic setValue:selectColor forKey:selectDateStr];
    [attendanceSheetForNextMonthDic setObject:classStr forKey:selectDateStr];
    [self reloadCollectionData];
    NSLog(@"加入班別時間: %@",attendanceSheetForNextMonthDic);
}

-(BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date{
    
    if (segmentIndex == DayOffSegment && dayOffResult == 0) {
        [self alertController:@"" alertMessage:@"休假時數已達上限" dissmiddVC:false];
        return false;
    } else if (segmentIndex == AnnualLeaveSegment && annualLeaveResult == 0){
        [self alertController:@"" alertMessage:@"特休時數已達上限" dissmiddVC:false];
        return false;
    }
    
    return true;
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
    
    if (segmentIndex == DayOffSegment && dayOffResult < defaultDayOffHours) {
        
        dayOffResult = dayOffResult + 8;
        
    }else if (segmentIndex == AnnualLeaveSegment && annualLeaveResult < defaultAnnualLeaveHours) {
        annualLeaveResult = annualLeaveResult + 8;
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

// setting section
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
        case ScheduleStatus:
        case FirstShift:
        case SecondShift:
            headerView.leaveHours.hidden = true;
            break;
            
        case DayOff:
            headerView.leaveHours.hidden = false;
            headerView.leaveHours.text = [NSString stringWithFormat:@"剩餘時數:%i",dayOffResult];
            break;
            
        case AnnualLeave:
            headerView.leaveHours.hidden = false;
            headerView.leaveHours.text = [NSString stringWithFormat:@"剩餘時數:%i",annualLeaveResult];
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
            case ScheduleStatus:
                return allShiftTableStatus.count;
                break;
            case FirstShift:
                if (firstShiftArr > 0){
                    return firstShiftArr.count;
                }
                break;
            case SecondShift:
                if (secondShiftArr > 0){
                    return secondShiftArr.count;
                }
                break;
            case DayOff:
                if (dayoff > 0){
                    return dayoff.count;
                }
                break;
            case AnnualLeave:
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
        case ScheduleStatus:
            
            switch (indexPath.row) {
                case FirstShiftCell:
                {
                    NSArray *arr = allShiftTableStatus[indexPath.row];
                    cell.schedulingCollevtionViewLabel.text = [NSString stringWithFormat:@"早班:%lu人",arr.count];
                    
                    break;
                }
                case SecondShiftCell:
                {
                    NSArray *arr = allShiftTableStatus[indexPath.row];
                    cell.schedulingCollevtionViewLabel.text = [NSString stringWithFormat:@"晚班:%lu人",arr.count];
                    
                    break;
                }
                case DayOffCell:
                {
                    NSArray *arr = allShiftTableStatus[indexPath.row];
                    cell.schedulingCollevtionViewLabel.text = [NSString stringWithFormat:@"休假:%lu人",arr.count];
                    
                    break;
                }
                case AnnualLeaveCell:
                {
                    NSArray *arr = allShiftTableStatus[indexPath.row];
                    cell.schedulingCollevtionViewLabel.text = [NSString stringWithFormat:@"特休:%lu人",arr.count];
                    
                    break;
                }
                    
            }
            break;
        case FirstShift:
            
            cell.schedulingCollevtionViewLabel.text = firstShiftArr[indexPath.row];
            break;
        case SecondShift:
            cell.schedulingCollevtionViewLabel.text = secondShiftArr[indexPath.row];
            break;
        case DayOff:
            cell.schedulingCollevtionViewLabel.text = dayoff[indexPath.row];
            break;
        case AnnualLeave:
            cell.schedulingCollevtionViewLabel.text = annualLeaveArr[indexPath.row];
            break;
    }
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == ScheduleStatus) {
        return true;
    } else {
        return false;
    }
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *shifts = @[@"早班人員",@"晚班人員",@"休假人員",@"特休人員"];
    NSString *personnel = @"";
    for (int i = 0; i < [allShiftTableStatus[indexPath.row] count]; i++) {
        
        personnel = [personnel stringByAppendingFormat:@"%@ ",allShiftTableStatus[indexPath.row][i]];
    }
    
    NSLog(@"personnel: %@", personnel);
    
    if (indexPath.section == ScheduleStatus) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:shifts[indexPath.row] message:personnel preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
    }
}

-(void) reloadCollectionData {
    
    [_schedulingCollectionView reloadData];
    [_schedulingCalendar reloadData];
    NSLog(@"reloadData");
}

-(void) alertController:(NSString *)tittle alertMessage:(NSString *)message dissmiddVC:(BOOL) dissmissVC {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tittle message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (dissmissVC == true) {
            
            [self dissmissThisPage];
        }
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
    
}

-(void) dissmissThisPage {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end


