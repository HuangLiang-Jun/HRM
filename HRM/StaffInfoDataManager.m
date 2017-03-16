//
//  StaffInfoDataManager.m
//  HRM
//
//  Created by huang on 2016/11/7.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffInfoDataManager.h"

@implementation StaffInfoDataManager
{
    UITableView *_tableView;
}

+ (instancetype) sharedInstance{
    
    static StaffInfoDataManager *_staffInfo;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _staffInfo = [StaffInfoDataManager new];
    });
    
    return _staffInfo;
}

- (void) downLoadStaffInfo:(UITableView *)tableView {
    
    _tableView = tableView;

    FIRDatabaseReference *staffInfoRef = [[[FIRDatabase database]reference]child:@"StaffInformation"];
    
    if (_allStaffInfoDict == nil) {
        
        [staffInfoRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            self.allStaffInfoDict = snapshot.value;
            NSLog(@"StaffInformation : %@",self.allStaffInfoDict);
            [_tableView reloadData];
        }];
        
        FIRDatabaseReference *imageUrlRef = [[[FIRDatabase database]reference]child:@"thumbnail"];
    
        [imageUrlRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            if ([snapshot exists]) {
                _allStaffThumbnailDict = snapshot.value;
                NSLog(@"UrlDict: %@",_allStaffThumbnailDict);
                }
            
            [_tableView reloadData];
        }];
    }
}



- (void) refreshInfoData{
    
    _editStatus = false;
    
    FIRDatabaseReference *staffInfoRef = [[[FIRDatabase database]reference]child:@"StaffInformation"];
    
    [staffInfoRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.allStaffInfoDict = snapshot.value;
        
        NSLog(@"Refresh StaffInformation : %@",self.allStaffInfoDict);
        
        _editStatus = true;
        
        
    }];
    
}


- (void) upLoadStaffImage:(NSData *)imageData WiththumbnailName:(NSString *)uid withBlock:(Completion)block {
    
    FIRStorage *storage = [FIRStorage storage];
    
    FIRStorageReference *storageRef = [storage referenceForURL:@"gs://hrmanager-f9a98.appspot.com"];
    
    NSString *thumbnailName = [NSString stringWithFormat:@"%@.png", uid];
    FIRStorageReference *thumbnailRef = [[storageRef child:@"thumbnail"] child:thumbnailName];
    [thumbnailRef putData:imageData metadata:nil completion:
    ^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        
        block(metadata,error);
        
    }];
    _imageStatus = false;
}

@end
