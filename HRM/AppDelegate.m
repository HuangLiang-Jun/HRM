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
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [FIRApp configure];
    [CurrentUser sharedInstance];
    
    // APNS Ask user's permission(詢問使用者是否同意推播通知)雖然建議使用ios10的新方法 但目前為了支援舊版本所以繼續使用就方法
    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    [application registerUserNotificationSettings:settings];
    
    // Ask deviceToken from APNS(去要DeviceToken)
    [application registerForRemoteNotifications];
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
    
    // Update DeviceToken to Server
    ServerCommunicator *comm = [ServerCommunicator shareInstance];
    
    [comm updateDeviceToken:finalDeviceToken
                 completion:^(NSError *error, id result) {
                     
                     if (error) {
                         NSLog(@"updayeDeviceToken fail : %@",error);
                         return ;
                         
                     }
                     
                     NSLog(@"updateDeviceToken OK : %@",[result description]);
                     
                 }];
    
}

-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@",error);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
