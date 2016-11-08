//
//  StrValidationFilter.m
//  HRM
//
//  Created by 李家舜 on 2016/11/8.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StrValidationFilter.h"

#define LEGAL_ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define LEGAL_NUMBER @"0123456789"

@implementation StrValidationFilter

- (BOOL)emailValidationWithStr:(NSString *)str {
    
    NSString *acceptableStr = [LEGAL_ALPHA stringByAppendingString:LEGAL_NUMBER];
    NSCharacterSet *unacceptableSet  = [[NSCharacterSet characterSetWithCharactersInString:[acceptableStr stringByAppendingString:@"_.-"]] invertedSet];
    if ([[str componentsSeparatedByString:@"@"] count] == 2) {
        
        BOOL validationFilter = ([[str componentsSeparatedByCharactersInSet:unacceptableSet] count] <= 1);
        return validationFilter;
        
    }
    return false;
}

@end
