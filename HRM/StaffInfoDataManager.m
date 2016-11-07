//
//  StaffInfoDataManager.m
//  HRM
//
//  Created by huang on 2016/11/7.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffInfoDataManager.h"

@implementation StaffInfoDataManager

+(instancetype) sharedInstance{
    
    static StaffInfoDataManager *_staffInfo;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _staffInfo = [StaffInfoDataManager new];
    });
    
    return _staffInfo;
}

-(void) downLoadStaffInfo{
    
    
    FIRDatabaseReference *staffInfoRef = [[[FIRDatabase database]reference]child:@"StaffInformation"];
    
    [staffInfoRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.allStaffInfoDict = snapshot.value;
        NSLog(@"StaffInformation : %@",self.allStaffInfoDict);
    }];
    
}


@end
