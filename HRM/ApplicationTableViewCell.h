//
//  ApplicationTableViewCell.h
//  HRM
//
//  Created by 李家舜 on 2016/11/22.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplicationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *applicationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end
