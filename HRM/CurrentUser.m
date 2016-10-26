//
//  CurrentUser.m
//  HRM
//
//  Created by 李家舜 on 2016/10/18.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

+ (instancetype)sharedInstance {
    static CurrentUser *_localUser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _localUser = [CurrentUser new];
    });
    return _localUser;
}

+ (void)signOutUserAccount {
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (error) {
        NSLog(@"Error (Sign out): %@", error);
    }
}

- (void)createUserAccount {
    [[FIRAuth auth] createUserWithEmail:_email password:_password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (user != nil) {
            _uid = user.uid;
            _downloadState = @1;
            [[NSUserDefaults standardUserDefaults] setValue:_uid forKey:@"UID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            NSLog(@"Error (Account creation): %@", error);
        }
    }];
}

- (void)signInUserAccount {
    [[FIRAuth auth] signInWithEmail:_email password:_password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (user != nil) {
            _uid = user.uid;
            _downloadState = @1;
            [[NSUserDefaults standardUserDefaults] setValue:_uid forKey:@"UID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self fetchLocalUserInfoForm:user];
        } else {
            NSLog(@"Error (Sign in): %@", error);
        }
    }];
}

- (void)fetchLocalUserInfoForm:(FIRUser *)user {
    FIRDatabaseReference *_ref = [[[[FIRDatabase database] reference] child:@"UID"] child:_uid];
    [_ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        _displayName = snapshot.value;
        [[NSUserDefaults standardUserDefaults] setValue:_displayName forKey:@"DisplayName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _downloadState = @2;
        FIRDatabaseReference *_ref = [[[[FIRDatabase database] reference] child:_displayName] child:@"Auth"];
        [_ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            _auth = snapshot.value;
            [[NSUserDefaults standardUserDefaults] setValue:_auth forKey:@"Auth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _downloadState = @3;
        }];
    }];
}

- (void)updateUserInfoWithDict:(NSMutableDictionary *)userInfo {
    _auth = @0;
    NSString *dateString = [NSDateNSStringExchange stringFromUpdateDate:[NSDate date]];
    NSDictionary *userInfoDetail = @{@"Auth": _auth, @"Email": _email, @"Info": (NSDictionary *)userInfo, @"SignUpDate": dateString, @"UID": _uid};
    [[NSUserDefaults standardUserDefaults] setValue:_auth forKey:@"Auth"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    FIRDatabaseReference *_ref = [[FIRDatabase database] reference];
    [[_ref child:_displayName] updateChildValues:userInfoDetail];
    [[[_ref child:@"UID"] child:_uid] setValue:_displayName];
}

- (void)updateApplicationInfoWithDict:(NSDictionary *)application {
    FIRDatabaseReference *_ref = [[FIRDatabase database] reference];
    [[[_ref child:_displayName] child:@"ApplicationList"] updateChildValues:application];
}

- (void)downloadAppcationList {
    FIRDatabaseReference *_ref = [[[[FIRDatabase database] reference] child:_displayName] child:@"ApplicationList"];
    [_ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *applicationListDict = snapshot.value;
        _applicationList = [NSMutableArray new];
        for (NSString *key in [applicationListDict allKeys]) {
            NSDictionary *application = @{key: [applicationListDict valueForKey:key]};
            [_applicationList addObject:application];
        }
        _applicationDownloadState = @1;
    }];
    
}

@end
