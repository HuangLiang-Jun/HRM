//
//  AttendanceViewController.m
//  HRM
//
//  Created by huang on 2016/10/20.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "AttendanceViewController.h"
#import "CurrentUser.h"
#import "NSDateNSStringExchange.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@import Firebase;
@import FirebaseDatabase;

#define COMPANY_LOCATION_LATITUDE 24.967726
#define COMPANY_LOCATION_LONGITUDE 121.191679
@interface AttendanceViewController () <MKMapViewDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;


@property (nonatomic,strong) NSArray *classArr;
@property (nonatomic,strong) FIRDatabaseReference *attendanceRef;
@end

@implementation AttendanceViewController
{
    CLLocation * myLocation;
    NSDate *currentDate;
    NSTimer *myTimer;
    CLLocationManager *locationManager;
    CLLocationDistance distance;
    CLLocation *companyLocation;
    CurrentUser *userData;
    NSString *countStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userData = [CurrentUser sharedInstance];
    
    currentDate = [NSDate date];
    NSString *yearAndMonthStr = [NSDateNSStringExchange stringFromYearAndMonth:currentDate];
    NSString *days = [NSDateNSStringExchange stringFromDays:currentDate];
    _attendanceRef = [[[[[[FIRDatabase database]reference] child:@"Attendance"] child:userData.displayName] child:yearAndMonthStr] child:days];
    
    
   myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showCurrentTimeOnLabel) userInfo:nil repeats:true];
    _currentTimeLabel.adjustsFontSizeToFitWidth = true;

    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = CLActivityTypeOtherNavigation;
    [locationManager startUpdatingLocation];
    
    companyLocation = [[CLLocation alloc]initWithLatitude:COMPANY_LOCATION_LATITUDE longitude:COMPANY_LOCATION_LONGITUDE];

}

- (IBAction)onDutyBtnPressed:(UIButton *)sender {
    
    if (distance <= 10) {
        [_attendanceRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSUInteger dicCount = 10;
            if(snapshot.hasChildren){
                NSDictionary *dic = snapshot.value;
                NSLog(@"%@",dic);
                dicCount = dicCount + dic.count;
                NSLog(@"dicCOunt: (%lu)",dicCount);
                
            }
            
            countStr = [NSString stringWithFormat:@"time%lu",dicCount];
            NSLog(@"countStr:%@",countStr);
            
        }];
        
        if (countStr) {
            
            [_attendanceRef updateChildValues:@{countStr:[NSDateNSStringExchange getCurrentTime]} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"打卡異常: %@",error);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self completeToRecordAttendance];
                });
            
            }];
            
        }
        
    }else{
        
        NSLog(@"你不在公司哦！");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!!"
                                                                       message:@"您與公司距離過遠"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma -mark LocationManager

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    myLocation = locations.lastObject;
    
    distance = [myLocation distanceFromLocation:companyLocation];
   
    static dispatch_once_t changeRegionToken = 0;
    dispatch_once(&changeRegionToken, ^{
        NSLog(@"Come in dispitch once");
        MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
        
        MKCoordinateRegion region = MKCoordinateRegionMake(myLocation.coordinate, span);
        
        [_mainMapView setRegion:region animated:true];

    });
}


-(void) completeToRecordAttendance{
    
    NSString *stringFromCurrentDate = [NSDateNSStringExchange getCurrentTime];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"打卡成功"
                                                                   message:stringFromCurrentDate
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}



-(void) showCurrentTimeOnLabel {
    
    NSDate *date = [NSDate date];
    NSString *strFromDate = [NSDateNSStringExchange stringFromCurrentDate:date];
    _currentTimeLabel.text = strFromDate;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    if (myTimer != nil) {
        [myTimer invalidate];
        myTimer = nil;
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
