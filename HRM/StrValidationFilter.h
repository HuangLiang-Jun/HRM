//
//  StrValidationFilter.h
//  HRM
//
//  Created by 李家舜 on 2016/11/8.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StrValidationFilter : NSObject

+ (BOOL)emailValidationFor:(NSString *)email;

+ (BOOL)passwordValidationFor:(NSString *)pwd;

+ (BOOL)birthdayValidationFor:(NSString *)birthday;

+ (BOOL)idCardNumValidationFor:(NSString *)idCardNum;

+ (BOOL)cellPhoneNumValidationFor:(NSString *)cellPhoneNum;

@end
