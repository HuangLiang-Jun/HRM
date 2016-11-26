//
//  ServerCommunicator.h
//  HRM
//
//  Created by huang on 2016/11/26.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GROUP_NAME @"HRManager"
#define USER_NAME  @"HuangLiangJun"

#define USER_NAME_KEY      @"UserName"
#define BULLETIN_TITLE_KEY @"Title"
#define DEVICETOKEN_KEY    @"DeviceToken"
#define GROUP_NAME_KEY     @"GroupName"
#define DATA_KEY           @"data"


typedef void(^DoneHandler)(NSError *error,id result);

@interface ServerCommunicator : NSObject

+ (instancetype) shareInstance;

- (void) updateDeviceToken: (NSString *)deviceToken
                completion:(DoneHandler)done;

- (void) snedBulletinMessage:(NSString*)title
                  completion:(DoneHandler) done;

@end
