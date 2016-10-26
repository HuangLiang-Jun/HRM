//
//  SalarySums.m
//  HRM
//
//  Created by JimSu on 2016/10/22.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "SalarySums.h"

@implementation SalarySums

static int payCut, fullAttendanceBonus;
static double hourSalary;

//接本薪參數並回傳時薪的方法
- (double) hourSalary:(int)monthlySalary totalHours:(double)totalHours {
    
    hourSalary = (double)monthlySalary / (double)totalHours;
    
    return hourSalary;
}

// 回傳請假扣薪薪水的方法
- (int) askForLeave:(int)leaveHour hourSalary:(int)hourSalary {
    
    payCut = leaveHour * hourSalary;
    
    return payCut;
}

// 回傳全勤獎金的方法
- (int) fullAttendance:(int)leaveHour {
    
    if (leaveHour == 0) {
        fullAttendanceBonus = 1000;
    } else {
        fullAttendanceBonus = 0;
    }
    return fullAttendanceBonus;
}


@end
