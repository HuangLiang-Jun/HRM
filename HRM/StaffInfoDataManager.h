//
//  StaffInfoDataManager.h
//  HRM
//
//  Created by huang on 2016/11/7.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
@import FirebaseDatabase;

@interface StaffInfoDataManager : NSObject

@property (nonatomic,strong) NSMutableDictionary *staffInformation;

+(instancetype) sharedInstance;

-(id) init;

@end
