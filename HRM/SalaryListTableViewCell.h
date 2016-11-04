//
//  SalaryListTableViewCell.h
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalaryListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *staffImage;
@property (weak, nonatomic) IBOutlet UILabel *staffNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *basicSalaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *salaryLabel;

@end
