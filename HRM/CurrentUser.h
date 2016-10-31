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
@property (strong, nonatomic) NSMutableArray *applicationList;

+ (instancetype)sharedInstance;

- (void)updateUserDefaultsWithValue:(id)value andKey:(NSString *)key;

- (void)createUserAccount;

- (void)signInUserAccount;

- (void)downloadUserInfoForm:(FIRUser *)user;

- (void)uploadUserInfoWithDict:(NSMutableDictionary *)userInfo;

- (void)signOutUserAccount;

- (void)downloadAppcationList;

- (void)uploadApplicationWithDict:(NSDictionary *)Application;

@end
