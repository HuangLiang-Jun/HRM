//
//  CurrentUser.h
//  HRM
//
//  Created by 李家舜 on 2016/10/18.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDateNSStringExchange.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface CurrentUser : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSNumber *auth;
@property (strong, nonatomic) NSNumber *downloadState;
@property (strong, nonatomic) NSMutableArray *applicationList;
@property (strong, nonatomic) NSNumber *applicationDownloadState;

+ (instancetype)sharedInstance;

+ (void)signOutUserAccount;

- (void)createUserAccount;

- (void)signInUserAccount;

- (void)fetchLocalUserInfoForm:(FIRUser *)user;

- (void)updateUserInfoWithDict:(NSMutableDictionary *)userInfo;

- (void)updateApplicationInfoWithDict:(NSDictionary *)Application;

- (void)downloadAppcationList;

@end
