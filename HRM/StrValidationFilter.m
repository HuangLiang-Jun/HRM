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
    
    NSArray<NSString *> *subEmailStr = [email componentsSeparatedByString:@"@"];
    switch (subEmailStr.count) {
            
        case 2:
            
            if (subEmailStr.firstObject.length !=0 && subEmailStr.lastObject.length != 0) {
                
                NSString *regexStr = [NSString stringWithFormat:@"@%@%@-._", LEGAL_ALPHA, LEGAL_NUMBER];
                NSCharacterSet *regexCharSet = [NSCharacterSet characterSetWithCharactersInString:regexStr];
                NSCharacterSet *emailCharSet = [NSCharacterSet characterSetWithCharactersInString:email];
                return [regexCharSet isSupersetOfSet:emailCharSet];
                
            }
            return false;
            
        default:
            return false;
            
    }
}

+ (BOOL)passwordValidationFor:(NSString *)pwd {
    
    NSString *regexStr = [NSString stringWithFormat:@"%@%@", LEGAL_ALPHA, LEGAL_NUMBER];
    NSCharacterSet *regexCharSet = [NSCharacterSet characterSetWithCharactersInString:regexStr];
    
    NSCharacterSet *pwdCharSet = [NSCharacterSet characterSetWithCharactersInString:pwd];
    return [regexCharSet isSupersetOfSet:pwdCharSet];
    
}

+ (BOOL)birthdayValidationFor:(NSString *)birthday {
        
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:birthday];
    if (date) {
        
        return true;
        
    }
    return false;
    
}

+ (BOOL)idCardNumValidationFor:(NSString *)idCardNum {
    
    switch (idCardNum.length) {
            
        case 10: {
            
            NSString *letterStr = [idCardNum substringToIndex:1];
            NSString *regexLetterStr = LEGAL_ALPHA;
            if ([regexLetterStr containsString:letterStr]) {
                
                NSString *numStr = [idCardNum substringFromIndex:1];
                NSCharacterSet *numCharSet = [NSCharacterSet characterSetWithCharactersInString:numStr];
                NSString *regexNumStr = LEGAL_NUMBER;
                NSCharacterSet *regexCharSet = [NSCharacterSet characterSetWithCharactersInString:regexNumStr];
                if ([regexCharSet isSupersetOfSet:numCharSet]) {
                    
                    NSString *genderStr = [numStr substringToIndex:1];
                    if ([genderStr isEqualToString:@"1"] || [genderStr isEqualToString:@"2"]) {
                        
                        NSUInteger num = [numStr integerValue];
                        NSString *capitalizedLetterStr = [letterStr capitalizedString];
                        NSDictionary *activeLetters = @{@"A":@10, @"B":@11, @"C":@12, @"D":@13, @"E":@14, @"F":@15, @"G":@16, @"H":@17, @"I":@34, @"J":@18, @"K":@19, @"L":@20, @"M":@21, @"N":@22, @"O":@35, @"P":@23, @"Q":@24, @"R":@25, @"S":@26, @"T":@27, @"U":@28, @"V":@29, @"W":@32, @"X":@30, @"Y":@31, @"Z":@33};
                        int letterNum = [[activeLetters valueForKey:capitalizedLetterStr] intValue];
                        letterNum = letterNum/10+letterNum%10*9+(int)(num%10);
                        for (int i = 1; i < 9; i += 1) {
                            
                            num = num/10;
                            letterNum = letterNum+(int)(num%10)*i;
                            
                        }
                        return (letterNum%10 == 0);
                        
                    }
                    return false;
                    
                }
                return false;
                
            }
            return false;
            
        }
            
        default:
            return false;
            
    }
}

+ (BOOL)cellPhoneNumValidationFor:(NSString *)cellPhoneNum {
    
    switch (cellPhoneNum.length) {
            
        case 10:
            if ([cellPhoneNum hasPrefix:@"09"]) {
                
                return true;
                
            }
            return false;
            
        default:
            return false;

    }
}

+ (BOOL)applicationDateValidationFor:(NSString *)applicationDate {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:applicationDate];
    if (date) {
        
        return true;
        
    }
    return false;
    
}

@end
