//
//  ServerCommunicator.m
//  HRM
//
//  Created by huang on 2016/11/26.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ServerCommunicator.h"
#import <AFNetworking/AFNetworking.h>
#import "CurrentUser.h"

//#define BASE_URL @"http://192.168.196.156:8888/apnsphp"
#define BASE_URL @"http://103.17.8.124/food/apnsphp"

#define SENDMESSAGE_URL [BASE_URL stringByAppendingPathComponent:@"sendMessage.php"]

#define UPDATEDEVICETOKEN_URL [BASE_URL stringByAppendingPathComponent:@"updateDeviceToken.php"]

static ServerCommunicator *_singletonCommunicator = nil;

@implementation ServerCommunicator
{
    
}


+ (instancetype) shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonCommunicator = [ServerCommunicator new];
    });
    
    return _singletonCommunicator;
}


/**
 Update Device's DeviceToken to Server
 

 @param done        DoneHandler: Done Block will be executed when job is done.
 */
- (void) updateDeviceToken:(DoneHandler)done{

    CurrentUser *localUser = [CurrentUser sharedInstance];
    if (localUser.deviceToken != nil) {
    // Prepare parameters
    NSDictionary *parameters = @{USER_NAME_KEY:localUser.displayName,DEVICETOKEN_KEY:localUser.deviceToken,GROUP_NAME_KEY:GROUP_NAME};
    
    // Do Post Job
    [self doPostJobWithURLString:UPDATEDEVICETOKEN_URL
                      parameters:parameters
                      completion:done];
        
    }else {
        NSLog(@"DeviceToken is nil");
    }

}

- (void) sendBulletinMessage:(NSString*)title
                  completion:(DoneHandler) done{
    
    // Prepare Post ANPS JOb.
    NSDictionary *jsonObj = @{BULLETIN_TITLE_KEY:title,GROUP_NAME_KEY:GROUP_NAME};
    
    // Do Post Job
    [self doPostJobWithURLString:SENDMESSAGE_URL
                      parameters:jsonObj
                      completion:done];
    
    
}

#pragma mark - General Post Method


- (void) doPostJobWithURLString:(NSString *) urlString
                     parameters:(NSDictionary *) parameters
                     completion:(DoneHandler) done{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"doPost Parameters:%@",jsonString);
    
    NSDictionary *finalParameters = @{DATA_KEY:jsonString};
    
    // AFNetworking 指定我接受server回傳哪些type的內容
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
    // progress:如果是大型檔案可以回傳完成進度給我們
    [manager POST:urlString parameters:finalParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // responseObject：會自動幫我們轉換成陣列
        NSLog(@"doPOST OK : %@",responseObject);
        
        if(done != nil){
            done(nil,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"doPOST fail : %@",error);
        if(done != nil) {
            done(error,nil);
        }
    }];
    
}


#pragma mark - Post to FBDB

- (void) downLoadBulletinsFromFBDB{
    
    FIRDatabaseReference *ref = [[[FIRDatabase database]reference]child:@"Bulletin"];
    
    [ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if(snapshot.value != [NSNull null]){
            _bulletinsDict = snapshot.value;
            
            [[NSNotificationCenter defaultCenter]postNotificationName:RELOAD_DATA object:self userInfo:nil];
        }
        
    }];
    
}

- (void) sendNewBulletinToFBDB:(NSDictionary *)bulletin
                    completion:(DoneHandler)done{
    
    FIRDatabaseReference *ref = [[[FIRDatabase database]reference]child:@"Bulletin"];
    
    [ref updateChildValues:bulletin withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (done != nil) {
            NSLog(@"done Ref: %@",ref);
            done(error,ref);
        }
        
    }];
    
}






@end







