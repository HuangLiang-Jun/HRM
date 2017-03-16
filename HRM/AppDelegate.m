//
//  AppDelegate.m
//  HRM
//
//  Created by JimSu on 2016/9/22.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "AppDelegate.h"
#import "CurrentUser.h"
#import "ServerCommunicator.h"
#import "EmployeeTabBarController.h"
#import "ManagerTabBarController.h"
#import <UserNotifications/UserNotifications.h>

@import Firebase;

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation AppDelegate
{
    CurrentUser *user;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [FIRApp configure];
    [[FIRDatabase database] persistenceEnabled];
    
    user = [CurrentUser sharedInstance];
    
    // APNS Ask user's permission(詢問使用者是否同意推播通知)雖然建議使用ios10的新方法 但目前為了支援舊版本所以繼續使用就方法
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"注册失败");
            }
        }];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
        //iOS8 - iOS10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
        
    }else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        //iOS8系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
//    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
//    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
//    [application registerUserNotificationSettings:settings];
//    NSLog(@"launch");
//    // Ask deviceToken from APNS(去要DeviceToken)
//    [application registerForRemoteNotifications];

    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotif) {
        
        NSLog(@"remoteNotif:%@",remoteNotif);
        [self handleRemoteNotification:application didReceiveRemoteNotification:remoteNotif];
        
    }
    
    return YES;
}

// 負責傳回deviceToken結果的
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSLog(@"DeviceToken: %@",deviceToken.description);
    // 取代字串 拿到符合我們要的格式
    // <44928c24 f650074e ee268ffc 47ffcca1 82e2ca7e 68ae29f1 a2849f64 ce4459ec>
    // ==> 44928c24f650074eee268ffc47ffcca182e2ca7e68ae29f1a2849f64ce4459ec
    NSString *finalDeviceToken = deviceToken.description;
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"finalDeviceToken: %@",finalDeviceToken);
    CurrentUser *localUser = [CurrentUser sharedInstance];
    localUser.deviceToken = finalDeviceToken;
    
    }

-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@",error);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    NSLog(@"將要去背景ResignActive5");

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"回到背景1");
    

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    NSLog(@"將要回到前景2");

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    NSLog(@"回到前景3");

     
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"回到背景4 ");

}


// App在背景時 點擊推播進入APP時一定會執行的方法
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"notifi" object:nil];
    NSLog(@"點推播APP從背景到前景");
    
    
}

// 自定義方法 ：點擊推播啟動App時會執行的方法
-(void) handleRemoteNotification: (UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationLaunchOptionsRemoteNotificationKey object:nil];
    [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"notifi"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"點推播後啟動app");

}

@end
