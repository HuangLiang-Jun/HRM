//
//  SalarySums.h
//  HRM
//
//  Created by JimSu on 2016/10/22.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalarySums : NSObject

- (double) hourSalary:(int)monthlySalary totalHours:(double)totalHours;

- (int) askForLeave:(int)leaveHour hourSalary:(int)hourSalary;

- (int) fullAttendance:(int)leaveHour;

@end
