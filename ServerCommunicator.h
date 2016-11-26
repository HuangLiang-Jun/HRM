//
//  ServerCommunicator.h
//  HRM
//
//  Created by huang on 2016/11/26.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GROUP_NAME @"HRManagerTest"
#define USER_NAME @"HuangLiangJun"

typedef void(^DoneHandler)(NSError *error,id result);

@interface ServerCommunicator : NSObject

+ (instancetype) shareInstance;

- (void) updateDeviceToken: (NSString *)deviceToken completion:(DoneHandler)done;


@end
