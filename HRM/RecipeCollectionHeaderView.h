//
//  RecipeCollectionHeaderView.h
//  HRM
//
//  Created by huang on 2016/10/24.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeCollectionHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *specialVacHours;

@end
