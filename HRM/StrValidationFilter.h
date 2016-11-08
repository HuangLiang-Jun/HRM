//
//  StrValidationFilter.h
//  HRM
//
//  Created by 李家舜 on 2016/11/8.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StrValidationFilter : NSObject

+ (BOOL)emailValidationWithStr:(NSString *)str;

+ (BOOL)passwordValidationWithStr:(NSString *)str;

@end
