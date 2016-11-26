//
//  ServerCommunicator.m
//  HRM
//
//  Created by huang on 2016/11/26.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ServerCommunicator.h"

static ServerCommunicator *_singletonCommunicator = nil;

@implementation ServerCommunicator

+ (instancetype) shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonCommunicator = [ServerCommunicator new];
    });
    
    return _singletonCommunicator;
}

- (void) updateDeviceToken:(NSString *)deviceToken completion:(DoneHandler)done{



}

@end
