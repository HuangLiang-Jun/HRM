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

@import Firebase;
@import FirebaseDatabase;

@interface SchedulingViewController ()<FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *schedulingCalendar;
@property (weak, nonatomic) IBOutlet UICollectionView *schedulingCollectionView;


@property (strong,nonatomic)  NSDate *nextMonth;
@end

@implementation SchedulingViewController
{
    NSInteger segmentIndex;
    NSDate *selectDate;
    UIColor *selectColor;
    NSMutableDictionary *snapShotDic;
    FIRDatabaseReference *vacationRef;
    FIRDatabaseReference *updateRef;
    int vacationHours;
    NSMutableDictionary *colorForVactionDic;
    NSMutableDictionary *attendanceSheetForNextMonthDic;
    NSString *classStr;
    NSMutableArray *onDuty,*offDuty,*dayoff,*annualLeave;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    colorForVactionDic = [NSMutableDictionary new];
    snapShotDic = [NSMutableDictionary new];
    attendanceSheetForNextMonthDic = [NSMutableDictionary new];
 
    // for collectionView
    onDuty = [NSMutableArray new];
    offDuty = [NSMutableArray new];
    dayoff = [NSMutableArray new];
    annualLeave = [NSMutableArray new];
    
    _schedulingCollectionView.delegate = self;
    _schedulingCollectionView.dataSource = self;
    
    // claendar不可編輯&換頁
    _schedulingCalendar.allowsSelection = false;
    _schedulingCalendar.pagingEnabled = false;
    
    NSDate *today = [NSDate date];
    _nextMonth = [_schedulingCalendar dateByAddingMonths:1 toDate:today];
    // 設定排班功能月曆顯示月份
    [_schedulingCalendar setCurrentPage:_nextMonth];
    // firebase Ref
    updateRef = [[[[[FIRDatabase database]reference]child:@"Secheduling"] child:[NSDateNSStringExchange stringFromYearAndMonth:_nextMonth]]child:@"黃亮鈞"];
    
    //-- Loading Next Month VacationHours --//
    vacationRef = [[[FIRDatabase database]reference] child:@"vacation"];
    [vacationRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        snapShotDic = snapshot.value;
        
        NSLog(@"snapShot: %@",snapshot.value);
        
        
        
        NSString *nextMonthKey = [NSDateNSStringExchange stringFromYearAndMonth:_nextMonth];
        vacationHours = [snapShotDic[nextMonthKey] intValue];
        
        NSLog(@"vacationHours: %i",vacationHours);
        
    }];
    

    

    selectDate = [NSDate date];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:@[ [UIImage imageNamed: @"morningDeselect.png"],[UIImage imageNamed:@"nightDeselect.png"],[UIImage imageNamed:@"offDayDeselect.png"],[UIImage imageNamed:@"specialDeselect.png"]] sectionSelectedImages:@[[UIImage imageNamed:@"morningSelect.png"],[UIImage imageNamed:@"nightSelect.png"],[UIImage imageNamed:@"offDaySelect.png"],[UIImage imageNamed:@"specialSelect.png"]]];
    
    segmentedControl.frame = CGRectMake(0, 0, viewWidth, 40);
    segmentedControl.selectionIndicatorHeight = 2.0f;
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    
//    // setting WorkingClassChoseBtn
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
//    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionImages:@[@"morningDeselect.png",@"nightDeselect.png",@"offDayDeselect.png",@"specialDeselect.png"] sectionSelectedImages:@[@"morningSelect.png",@"nightSelect.png",@"offDaySelect.png",@"specialSelect.png"]];
//    segmentedControl.frame = CGRectMake(0, 0, viewWidth, 40);
//    segmentedControl.selectionIndicatorHeight = 4.0f;
//    segmentedControl.backgroundColor = [UIColor clearColor];
//    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
//    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;

    
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventAllEvents];
    [self.view addSubview:segmentedControl];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (IBAction)submitBtnPressed:(UIButton *)sender {
    [updateRef setValue:attendanceSheetForNextMonthDic withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Update Scheduling Error : %@",error);
        }
    }];
  
}

#pragma - mark SegmentedControl Method

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    segmentIndex = segmentedControl.selectedSegmentIndex;
    _schedulingCalendar.allowsMultipleSelection = true;
    _schedulingCalendar.allowsSelection = true;
    if (_schedulingCalendar.allowsMultipleSelection == true ) {
   
        switch (segmentedControl.selectedSegmentIndex ) {
            case 0:
                selectColor = [UIColor blueColor];
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
                selectColor = [UIColor purpleColor];
                classStr = @"特休";
                break;
            default:
                break;
        }
    }
}


#pragma -mark Calendar Method



-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    
    NSString  *selectDateStr = [NSDateNSStringExchange stringFromChosenDate:date];
    // for collectionView
    if (_schedulingCalendar.allowsMultipleSelection == true) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MM/dd"];
        NSString *monthAndDay = [formatter stringFromDate:date];
        switch (segmentIndex) {
        
            case 0:
                [onDuty addObject:monthAndDay];
                break;
            case 1:
                [offDuty addObject:monthAndDay];
                break;
            case 2:
                [dayoff addObject:monthAndDay];
                break;
            case 3:
                [annualLeave addObject:monthAndDay];
                break;
            default:
                break;
        }
       
        //update firebase data
        [colorForVactionDic setValue:selectColor forKey:selectDateStr];
        [attendanceSheetForNextMonthDic setObject:classStr forKey:selectDateStr];
        NSLog(@"加入班別時間: %@",attendanceSheetForNextMonthDic);
        
        [_schedulingCalendar reloadData];
        [_schedulingCollectionView reloadData];
    }
}

-(void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date{
    
    NSString *dateStr = [NSDateNSStringExchange stringFromChosenDate:date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd"];
    NSString *removeStr = [formatter stringFromDate:date];
    
    NSMutableArray *classArr = [[NSMutableArray alloc]initWithObjects:onDuty,offDuty,dayoff,annualLeave, nil];
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

#pragma -MARK CollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 4;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = nil;
    
    RecipeCollectionHeaderView *headerView = [_schedulingCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    
    NSArray *arr = @[@"早班",@"晚班",@"例休",@"特休"];
    headerView.headerLabel.text = arr[indexPath.section];
    reusableView = headerView;
    
    return reusableView;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    if (_schedulingCalendar.allowsMultipleSelection == true) {
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
    
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            
            cell.schedulingCollevtionViewLabel.text = onDuty[indexPath.row];
            break;
        case 1:
            cell.schedulingCollevtionViewLabel.text = offDuty[indexPath.row];
             break;
        case 2:
            cell.schedulingCollevtionViewLabel.text = dayoff[indexPath.row];
            break;
        case 3:
            cell.schedulingCollevtionViewLabel.text = annualLeave[indexPath.row];
             break;
        default:
            break;
    }
    return cell;
}

@end
