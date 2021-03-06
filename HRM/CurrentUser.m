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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:value forKey:key];
        [userDefaults synchronize];
        
    });
}

#pragma mark - Firebase Account Manage Func (Sign In)

- (void)signInUserAccount {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[FIRAuth auth] signInWithEmail:_email password:_password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            
            if (user != nil) {
                
                [self updateUserDefaultsWithValue:_email andKey:@"Email"];
                [self updateUserDefaultsWithValue:_password andKey:@"Password"];
                _uid = user.uid;
                [self updateUserDefaultsWithValue:_uid andKey:@"UID"];
                [self downloadUserInfoForm:user];
                
                
            } else {
                
                NSLog(@"Error (Sign in): %@", error);
                
                NSDictionary *errDict = error.userInfo;
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"LogInErr" object:nil userInfo:errDict];
                
            }
        }];
    });
}

- (void)downloadUserInfoForm:(FIRUser *)user {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"UID"] child:_uid];
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if ([snapshot exists]) {
                
                _displayName = snapshot.value;
                [self updateUserDefaultsWithValue:_displayName andKey:@"DisplayName"];
                
                FIRDatabaseReference *userAuthRef = [[[[[FIRDatabase database] reference] child:@"StaffInformation"]child:_displayName] child:@"Auth"];
                [userAuthRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    if ([snapshot exists]) {
                        
                        _auth = snapshot.value;
                        [self updateUserDefaultsWithValue:_auth andKey:@"Auth"];
                        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                        [notificationCenter postNotificationName:@"UserInfoDownloaded" object:nil];
                        
                    }
                }];
            }
        }];
    });
}

#pragma mark - Firebase Account Manage Func (Create)

- (void)createUserAccount {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[FIRAuth auth] createUserWithEmail:_email password:_password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            
            if (user != nil) {
                
                [self updateUserDefaultsWithValue:_email andKey:@"Email"];
                [self updateUserDefaultsWithValue:_password andKey:@"Password"];
                _uid = user.uid;
                [self updateUserDefaultsWithValue:_uid andKey:@"UID"];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"UserAccountCreated" object:nil];
                
            } else {
                
                NSLog(@"Error (Account creation): %@", error);
                
                NSDictionary *errDict = error.userInfo;
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"AccountCreationErr" object:nil userInfo:errDict];
                
            }
        }];
    });
}

- (void)uploadUserInfoWithDict:(NSMutableDictionary *)userInfo {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _auth = @0;
        [self updateUserDefaultsWithValue:_auth andKey:@"Auth"];
        NSDictionary *annualLeave = @{@"2016": @56};
        NSString *dateString = [NSDateNSStringExchange stringFromUpdateDate:[NSDate date]];
        NSDictionary *userInfoDetail = @{@"Auth": _auth, @"AnnualLeave": annualLeave,@"Email": _email, @"Info": (NSDictionary *)userInfo, @"SignUpDate": dateString, @"UID": _uid};
        
        FIRDatabaseReference *userInfoRef = [[[[FIRDatabase database] reference] child:@"StaffInformation"] child:_displayName];
        [userInfoRef updateChildValues:userInfoDetail withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            if (error) {
                
                NSLog(@"Error (Upload User Info): %@", error);
                
            }
            
        }];
        
        FIRDatabaseReference *userIdentityRef = [[[[FIRDatabase database] reference] child:@"UID"] child:_uid];
        [userIdentityRef setValue:_displayName ];
        
        [userIdentityRef setValue:_displayName withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            if (error) {
                
                NSLog(@"Error (Upload UID): %@", error);
                
            }
        }];
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
            
            NSLog(@"Error (Sign Out): %@", error);
            
        }
    });
}

- (void)uploadUserThumbnailWith:(NSData *)imageData {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRStorage *storage = [FIRStorage storage];
        
        FIRStorageReference *storageRef = [storage referenceForURL:@"gs://hrmanager-f9a98.appspot.com"];
        
        NSString *thumbnailName = [NSString stringWithFormat:@"%@.png", _displayName];
        FIRStorageReference *thumbnailRef = [[storageRef child:@"thumbnail"] child:thumbnailName];
        
        [thumbnailRef putData:imageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            
            if (error) {
                
                NSLog(@"Error (Upload Thumbnail): %@", error);
                
            } else {
                
                NSString *thumbnailStr = metadata.downloadURL.absoluteString;
                
                FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"thumbnail"] child:_displayName];
                
                [ref setValue:thumbnailStr withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    
                    if (error) {
                        
                        NSLog(@"Error (Upload Thumbnail URL): %@", error);
                        
                    }
                }];
            }
        }];
    });
}


#pragma mark - Firebase Application Sync Func

- (void)downloadAppcationList {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        switch (_auth.intValue) {
                
            case 0: {
                
                FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"Application"] child:_displayName];
                [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    if ([snapshot exists]) {
                        
                        NSDictionary *applicationListDict = snapshot.value;
                        NSArray *sortedKeys = [[applicationListDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
                        [_applicationList removeAllObjects];
                        for (long long i = sortedKeys.count-1; i > -1; i -= 1) {
                            
                            NSString *applyDateStr = sortedKeys[i];
                            NSDictionary *infoDict = [applicationListDict objectForKey:applyDateStr];
                            NSDictionary *applicationDict = @{applyDateStr: infoDict};
                            [_applicationList addObject:applicationDict];
                            
                        }
                        
                    }
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"ApplicationListDownloaded" object:nil];
                    
                }];
                break;
                
            }
                
            case 1: {
                
                FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"Signoff"];
                [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    if ([snapshot exists]) {
                        
                        NSDictionary *signoffFormListDict = snapshot.value;
                        NSArray *sortedKeys = [[signoffFormListDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
                        [_applicationList removeAllObjects];
                        for (long long i = sortedKeys.count-1; i > -1; i -= 1) {
                            
                            NSString *newApplyDateStr = sortedKeys[i];
                            NSDictionary *infoDict = [signoffFormListDict objectForKey:newApplyDateStr];
                            NSDictionary *signoffFormDict = @{newApplyDateStr: infoDict};
                            [_applicationList addObject:signoffFormDict];
                            
                        }
                        
                    }
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"ApplicationListDownloaded" object:nil];
                    
                }];
                break;
                
            }
        }
    });
}

- (void)uploadApplicationWithDict:(NSDictionary *)applicationDict {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRDatabaseReference *applicationListRef = [[[[FIRDatabase database] reference] child:@"Application"]child:_displayName];
        [applicationListRef updateChildValues:applicationDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            if (error) {
                
                NSLog(@"Error (Upload Application): %@", error);
                
            }
            
        }];
        
        
        NSString *applyDateStr = [applicationDict allKeys].firstObject;
        NSString *newApplyDateStr = [NSString stringWithFormat:@"%@@%@", applyDateStr, _displayName];
        NSDictionary *infoDict = [applicationDict allValues].firstObject;
        NSDictionary *signoffFormDict = @{newApplyDateStr: infoDict};
        FIRDatabaseReference *signoffListRef = [[[FIRDatabase database] reference] child:@"Signoff"];
        [signoffListRef updateChildValues:signoffFormDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            NSLog(@"Error (Upload Sign Off Form): %@", error);
            
        }];
    });
}

- (void)removeApplicationWhichAppliedAt:(NSString *)applyDateStr {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRDatabaseReference *applicationRef = [[[[[FIRDatabase database] reference] child:@"Application"]child:_displayName] child:applyDateStr];
        [applicationRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            if (error) {
                
                NSLog(@"Error (Remove Application): %@", error);
                
            }
            
        }];
        
        NSString *newApplyDateStr = [NSString stringWithFormat:@"%@@%@", applyDateStr, _displayName];
        FIRDatabaseReference *signoffFormRef = [[[[FIRDatabase database] reference] child:@"Signoff"] child:newApplyDateStr];
        [signoffFormRef removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            if (error) {
                
                NSLog(@"Error (Remove Sign Off Form): %@", error);
                
            }
        }];
    });
}

- (void)signoffApplicationWith:(NSString *)newApplyDateStr andAgreement:(NSNumber *)agreementNum {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        FIRDatabaseReference *signoffListRef = [[[[[FIRDatabase database] reference] child:@"Signoff"] child:newApplyDateStr] child:@"Agree"];
        [signoffListRef setValue:agreementNum withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            if (error) {
                
                NSLog(@"Error (Sign Off Sign Off Form): %@", error);
                
            }
        }];
        
        NSArray<NSString *> *subNewApplyDateStr = [newApplyDateStr componentsSeparatedByString:@"@"];
        NSString *applyDateStr = subNewApplyDateStr.firstObject;
        NSString *usernameStr = subNewApplyDateStr.lastObject;
        FIRDatabaseReference *applicationRef = [[[[[[FIRDatabase database] reference] child:@"Application"]child:usernameStr] child:applyDateStr] child:@"Agree"];
        [applicationRef setValue:agreementNum withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            NSLog(@"Error (Sign Off Application): %@", error);
            
        }];
    });
}

@end
