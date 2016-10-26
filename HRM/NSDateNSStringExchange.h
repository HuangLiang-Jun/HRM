//
//  NSDateNSStringExchange.h
//  DateTest
//
//  Created by huang on 2016/10/15.
//  Copyright © 2016年 Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateNSStringExchange : NSObject



+ (NSString *)stringFromYearAndMonth:(NSDate *)date;
+ (NSString *)stringFromDays:(NSDate *)date;
+ (NSString *)stringFromTimes:(NSDate *)date;
+ (NSString *)stringFromCurrentDate:(NSDate *)date;
+ (NSString *)stringFromUpdateDate:(NSDate *)date;
+ (NSString *)stringFromChosenDate:(NSDate *)date;
+ (NSString *)getCurrentTime;

+ (NSDate *)yearAndMonthFromString:(NSString *)string;
+ (NSDate *)daysFromString:(NSString *)string;
+ (NSDate *)timesFromString:(NSString *)string;

@end
