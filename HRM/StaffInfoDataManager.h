//
//  StaffInfoDataManager.h
//  HRM
//
//  Created by huang on 2016/11/7.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import Firebase;
@import FirebaseDatabase;
@import FirebaseStorage;


@interface StaffInfoDataManager : NSObject

@property (nonatomic,strong) NSMutableDictionary *allStaffInfoDict;
@property (nonatomic,assign) BOOL editStatus;

+(instancetype) sharedInstance;

-(void) downLoadStaffInfo:(UITableView *)tableView ;

-(void) refreshInfoData;


@end
