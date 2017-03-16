//
//  ManagerTabBarController.m
//  HRM
//
//  Created by huang on 2016/12/6.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "ManagerTabBarController.h"

@interface ManagerTabBarController ()

@end

@implementation ManagerTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotificationInfo) name:@"notifi" object:nil];
    BOOL notifi = [[NSUserDefaults standardUserDefaults]boolForKey:@"notifi"];
    
    if (notifi) {
        [self handleNotificationInfo];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"notifi"];
    }

    
}


-(void) handleNotificationInfo{
    [self setSelectedIndex:2];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
