//
//  BulletinBoardTableViewCell.h
//  HRM
//
//  Created by huang on 2016/11/3.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BulletinBoardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;

@end
