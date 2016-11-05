//
//  CurrentUser.m
//  HRM
//
//  Created by 李家舜 on 2016/10/18.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

#pragma mark - Current User Singleton

+ (instancetype)sharedInstance {
    
    static CurrentUser *_localUser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _localUser = [[CurrentUser alloc] init];
        
    });
    return _localUser;
    
}

- (id)init {
    
    self = [super init];
    if (self) {

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:@"Email"] != nil) {
            
            _email = [userDefaults valueForKey:@"Email"];
            
        } else {
            
            _email = [NSString new];
            
        }
        if ([userDefaults objectForKey:@"Password"] != nil) {
            
            _password = [userDefaults valueForKey:@"Password"];
            
        } else {
            
            _password = [NSString new];
            
        }
        if ([userDefaults objectForKey:@"UID"] != nil) {
            
            _uid = [userDefaults valueForKey:@"UID"];
            
        }
        if ([userDefaults objectForKey:@"DisplayName"]) {
            
            _displayName = [userDefaults valueForKey:@"DisplayName"];
            
        }
        if ([userDefaults objectForKey:@"Auth"]) {
            
            _auth = [userDefaults valueForKey:@"Auth"];
            
        }
        _applicationList = [NSMutableArray new];
        
    }
    return self;
    
}

#pragma mark - Update User Defaults

- (void)updateUserDefaultsWithValue:(id)value andKey:(NSString *)key {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:key];
    [userDefaults synchronize];
    
}

#pragma mark - Firebase Account Manage Func (Sign In)

- (void)signInUserAccount {
    
    [[FIRAuth auth] signInWithEmail:_email password:_password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        if (user != nil) {
            
            [self updateUserDefaultsWithValue:_email andKey:@"Email"];
            [self updateUserDefaultsWithValue:_password andKey:@"Password"];
            _uid = user.uid;
            [self updateUserDefaultsWithValue:_uid andKey:@"UID"];
            [self downloadUserInfoForm:user];
            
        } else {
            
            NSLog(@"Error (Sign in): %@", error);
            
        }
    }];
}

- (void)downloadUserInfoForm:(FIRUser *)user {
    
    FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"UID"] child:_uid];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.value != [NSNull null]) {
            
            _displayName = snapshot.value;
            [self updateUserDefaultsWithValue:_displayName andKey:@"DisplayName"];
            FIRDatabaseReference *userAuthRef = [[[[[FIRDatabase database] reference] child:@"StaffInformation"]child:_displayName] child:@"Auth"];
            [userAuthRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                if (snapshot.value != [NSNull null]) {
                    
                    _auth = snapshot.value;
                    [self updateUserDefaultsWithValue:_auth andKey:@"Auth"];
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"UserInfoDownloaded" object:nil];
                    
                }
            }];
        }
    }];
}

#pragma mark - Firebase Account Manage Func (Create)

- (void)createUserAccount {
    
    [[FIRAuth auth] createUserWithEmail:_email password:_password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        if (user != nil) {
            
            [self updateUserDefaultsWithValue:_email andKey:@"Email"];
            [self updateUserDefaultsWithValue:_password andKey:@"Password"];
            _uid = user.uid;
            [self updateUserDefaultsWithValue:_uid andKey:@"UID"];
            
        } else {
            
            NSLog(@"Error (Account creation): %@", error);
            
        }
    }];
}

- (void)uploadUserInfoWithDict:(NSMutableDictionary *)userInfo {
    
    _auth = @0;
    [self updateUserDefaultsWithValue:_auth andKey:@"Auth"];
    NSString *dateString = [NSDateNSStringExchange stringFromUpdateDate:[NSDate date]];
    NSDictionary *userInfoDetail = @{@"Auth": _auth, @"Email": _email, @"Info": (NSDictionary *)userInfo, @"SignUpDate": dateString, @"UID": _uid};
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRDatabaseReference *userInfoRef = [[[FIRDatabase database] reference] child:_displayName];
        [userInfoRef updateChildValues:userInfoDetail];
        
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRDatabaseReference *userIdentityRef = [[[[FIRDatabase database] reference] child:@"UID"] child:_uid];
        [userIdentityRef setValue:_displayName];
        
    });
}

#pragma mark - Firebase Account Manage Func (Sign Out)

- (void)signOutUserAccount {
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error;
        [[FIRAuth auth] signOut:&error];
        if (!error) {
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"UserSignedOut" object:nil];
            [_applicationList removeAllObjects];
            
        } else {
            
            NSLog(@"Error (Sign in): %@", error);
            
        }
    });
}

#pragma mark - Firebase Application Sync Func

- (void)downloadAppcationList {
    
    FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:_displayName] child:@"ApplicationList"];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.value != [NSNull null]) {
            
            NSDictionary *applicationListDict = snapshot.value;
            [_applicationList removeAllObjects];
            if (applicationListDict.count > 0) {
                
                for (NSString *key in [applicationListDict allKeys]) {
                    
                    NSDictionary *application = @{key: [applicationListDict valueForKey:key]};
                    [_applicationList addObject:application];
                    
                }
                
            }
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"applicationListDownloaded" object:nil];
            
        }
    }];
}

- (void)uploadApplicationWithDict:(NSDictionary *)application {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRDatabaseReference *applicationListRef = [[[[FIRDatabase database] reference] child:_displayName] child:@"ApplicationList"];
        [applicationListRef updateChildValues:application];
        
    });
}

@end
