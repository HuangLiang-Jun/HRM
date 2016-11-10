//
//  StaffInfoViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffInfoViewController.h"
#import "StaffInfoDataManager.h"

@interface StaffInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *staffImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *authSegment;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneTextField;

@property (nonatomic,assign)BOOL editStatus;
@end

@implementation StaffInfoViewController{
    StaffInfoDataManager *dataManager;
    UIBarButtonItem *editBtn;
    UIBarButtonItem *doneBtn;
    NSMutableDictionary *info;
    int auth;
    FIRDatabaseReference *updateInfoRef;
    FIRDatabaseReference *updateAuthRef;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _editStatus = false;
    
    dataManager = [StaffInfoDataManager sharedInstance];
    updateInfoRef = [[[[[FIRDatabase database]reference]child:@"StaffInformation"]child:_nameStr]child:@"Info"];
    updateAuthRef =[[[[FIRDatabase database]reference]child:@"StaffInformation"]child:_nameStr];
    NSLog(@"staffDetail:%@",_staffInfoDict);
    info = [_staffInfoDict valueForKey:@"Info"];
    NSLog(@"info :%@",info);
    auth = [[_staffInfoDict valueForKey:@"Auth"]intValue];
    
    _nameTextField.text = _nameStr;
    _birthdayTextField.text = [info valueForKey:@"Birthday"];
    _idTextField.text = [info valueForKey:@"IDCardNumber"];
    _cellphoneTextField.text = [info valueForKey:@"CellphoneNumber"];
    
    if (auth == 0) {
         _authSegment.selectedSegmentIndex = 0;
    }else {
        _authSegment.selectedSegmentIndex = 1;
    }

    editBtn = [[UIBarButtonItem alloc]initWithTitle:@"編輯" style:UIBarButtonItemStylePlain target:self action:@selector(editInfo)];
    doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishEditStaffInfo)];
    
    self.navigationItem.rightBarButtonItem = editBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) editInfo {
    
    self.navigationItem.rightBarButtonItem = doneBtn;
    _authSegment.enabled = true;
    _cellphoneTextField.enabled = true;
    
    NSLog(@"edit");

}

-(void) finishEditStaffInfo{
    self.navigationItem.rightBarButtonItem = editBtn;
    _authSegment.enabled = false;
    _cellphoneTextField.enabled = false;
    NSLog(@"Done");
    
    if (auth != _authSegment.selectedSegmentIndex) {
        NSLog(@"authChange %lu",_authSegment.selectedSegmentIndex);
        //資料有變就加到Dict中
        //auth = _authSegment.selectedSegmentIndex;
        NSNumber *chanegeAuth = @(_authSegment.selectedSegmentIndex);
        [updateAuthRef updateChildValues:@{@"Auth":chanegeAuth}];
        _editStatus = true;
    }

    if (![[info valueForKey:@"CellphoneNumber"] isEqualToString:_cellphoneTextField.text]) {
        NSLog(@"CellphoneChange");
        [updateInfoRef updateChildValues:@{@"CellphoneNumber":_cellphoneTextField.text}];
        _editStatus = true;
    }
    
    if (_editStatus) {
        [dataManager refreshInfoData];
    }
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
