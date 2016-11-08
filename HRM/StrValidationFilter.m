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

+ (BOOL)emailValidationWithStr:(NSString *)str {
    
    NSArray *subStr = [str componentsSeparatedByString:@"@"];
    if (subStr.count == 2) {
        
        NSString *regexStr = [NSString stringWithFormat:@"@%@%@-._", LEGAL_ALPHA, LEGAL_NUMBER];
        NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:regexStr] invertedSet];
        subStr = [str componentsSeparatedByCharactersInSet:charSet];
        return (subStr.count == 1);
        
    }
    return (subStr.count == 2);

}

+ (BOOL)passwordValidationWithStr:(NSString *)str {
    
    if (str.length >= 6) {
        
        NSString *regexStr = [NSString stringWithFormat:@"%@%@", LEGAL_ALPHA, LEGAL_NUMBER];
        NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:regexStr] invertedSet];
        NSArray *subStr = [str componentsSeparatedByCharactersInSet:charSet];
        return (subStr.count == 1);
        
    }
    return (str.length >= 6);
    
}

@end
