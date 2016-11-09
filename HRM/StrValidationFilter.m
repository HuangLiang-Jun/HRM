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

+ (BOOL)emailValidationFor:(NSString *)email {
    
    NSArray *subStr = [email componentsSeparatedByString:@"@"];
    if (subStr.count == 2) {
        
        NSString *regexStr = [NSString stringWithFormat:@"@%@%@-._", LEGAL_ALPHA, LEGAL_NUMBER];
        NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:regexStr] invertedSet];
        subStr = [email componentsSeparatedByCharactersInSet:charSet];
        return (subStr.count == 1);
        
    }
    return (subStr.count == 2);

}

+ (BOOL)passwordValidationFor:(NSString *)pwd {
    
    if (pwd.length >= 6) {
        
        NSString *regexStr = [NSString stringWithFormat:@"%@%@", LEGAL_ALPHA, LEGAL_NUMBER];
        NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:regexStr] invertedSet];
        NSArray *subStr = [pwd componentsSeparatedByCharactersInSet:charSet];
        return (subStr.count == 1);
        
    }
    return (pwd.length >= 6);
    
}

@end
