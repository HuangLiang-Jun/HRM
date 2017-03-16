//
//  EmployeeTabBarController.m
//  
//
//  Created by huang on 2016/12/6.
//
//

#import "EmployeeTabBarController.h"

@interface EmployeeTabBarController ()

@end

@implementation EmployeeTabBarController

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


@end
