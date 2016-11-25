//
//  NSDateNSStringExchange.m
//  DateTest
//
//  Created by huang on 2016/10/15.
//  Copyright © 2016年 Huang. All rights reserved.
//

#import "NSDateNSStringExchange.h"

@implementation NSDateNSStringExchange


+ (NSString *)stringFromCurrentDate:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
    NSString *strFromDate = [formatter stringFromDate:date];
    return strFromDate;
}

+ (NSString *)stringFromUpdateDate:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strFromDate = [formatter stringFromDate:date];
    return strFromDate;
}

+ (NSString *)stringFromChosenDate:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strFromDate = [formatter stringFromDate:date];
    return strFromDate;
}

+ (NSString *)stringFromYearAndMonth:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *strFromDate = [formatter stringFromDate:date];
    return strFromDate;
}

+ (NSString *)stringFromDays:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd"];
    NSString *strFromDate = [formatter stringFromDate:date];
    return strFromDate;
}

+ (NSString *)stringFromTimes:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *strFromDate = [formatter stringFromDate:date];
    return strFromDate;
}


+ (NSDate *)yearAndMonthFromString:(NSString *)string {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM"];
    NSDate *date=[formatter dateFromString:string];
    return date;
}

+ (NSDate *)daysFromString:(NSString *)string {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd"];
    NSDate *date=[formatter dateFromString:string];
    return date;
}

+ (NSDate *)timesFromString:(NSString *)string {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *date=[formatter dateFromString:string];
    return date;
}

+ (NSString *)getCurrentTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *strFromDate = [formatter stringFromDate:date];
    return strFromDate;
}


@end
