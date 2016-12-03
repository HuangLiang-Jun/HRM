//
//  StaffInfoViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffInfoViewController.h"
#import "StaffInfoDataManager.h"

#define CELLPHONENUM @"CellphoneNumber"

@interface StaffInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UISegmentedControl *authSegment;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *staffImageView;

@property (nonatomic,assign)BOOL editStatus;
@end

@implementation StaffInfoViewController{
    StaffInfoDataManager *dataManager;
    UIBarButtonItem *editBtn;
    UIBarButtonItem *doneBtn;
    NSMutableDictionary *infoDict;
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
    infoDict = [_staffInfoDict valueForKey:@"Info"];
    NSLog(@"info :%@",infoDict);
    auth = [[_staffInfoDict valueForKey:@"Auth"]intValue];
    
    _nameTextField.text = _nameStr;
    _birthdayTextField.text = [infoDict valueForKey:@"Birthday"];
    _idTextField.text = [infoDict valueForKey:@"IDCardNumber"];
    _cellphoneTextField.text = [infoDict valueForKey:CELLPHONENUM];
    
    if (auth == 0) {
        _authSegment.selectedSegmentIndex = 0;
    }else {
        _authSegment.selectedSegmentIndex = 1;
    }
    
    editBtn = [[UIBarButtonItem alloc]initWithTitle:@"編輯" style:UIBarButtonItemStylePlain target:self action:@selector(editInfo)];
    doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishEditStaffInfo)];
    
    self.navigationItem.rightBarButtonItem = editBtn;
    
    
    //將照片變成圓形
    _staffImageView.layer.cornerRadius = _staffImageView.frame.size.height *0.5;
    _staffImageView.layer.masksToBounds = true;
    _staffImageView.layer.borderWidth = 0.0;
    _staffImageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

#pragma - mark Camera

- (IBAction)settingStaffPhotoRecognizer:(UITapGestureRecognizer *)sender {
    
    UIAlertController *alert =  [UIAlertController alertControllerWithTitle:@"請選擇照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相機" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceTypeCamera:UIImagePickerControllerSourceTypeCamera];
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"從相簿中選擇" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:Cancel];
    
    [self presentViewController:alert animated:true completion:nil];
    
    
}


-(void) launchImagePickerWithSourceTypeCamera:(UIImagePickerControllerSourceType)sourceType{
    //檢查source是否存在
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == false) {
        NSLog(@"Invalid Source Type.");
        return;
    }
    
    UIImagePickerController *picker = [UIImagePickerController new];
    
    picker.sourceType = sourceType ;
    
    //picker.mediaTypes = @[@"public.image",@"public.movie"];
    picker.mediaTypes = @[@"public.image"];
    
    picker.delegate = self;
    [self presentViewController:picker animated:true completion:nil];
    
}


-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //UIImage *resizedImage = [self resizeFromImage:image];
    
    _staffImageView.image = image;
    NSLog(@"有換照片");
    [picker dismissViewControllerAnimated:true completion:nil];
}


// 縮圖 這是正方形size..
-(UIImage *) resizeFromImage:(UIImage *)sourceImage{
    CGFloat maxLength = 1024.0;
    CGSize targetSize;
    UIImage *finalImage = nil;
    
    //Check if it's necessary to resize of will use original Image
    if (sourceImage.size.width <= maxLength && sourceImage.size.height <= 1024) {
        NSLog(@"if...");
        finalImage = sourceImage;
        targetSize = sourceImage.size;
    } else {
        //will do resize here and decide final size first.
        if (sourceImage.size.width >= sourceImage.size.height) {
            // Width > Heigh
            CGFloat ratio = sourceImage.size.width / maxLength;
            targetSize = CGSizeMake(maxLength, sourceImage.size.height/ratio);
            
        } else {
            // Heigh > Width
            CGFloat ratio = sourceImage.size.height / maxLength;
            targetSize = CGSizeMake(sourceImage.size.width/ratio,maxLength);
        }
        
        // Do resize Job here
        UIGraphicsBeginImageContext(targetSize);
        [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //釋放虛擬畫布的記憶體
        UIGraphicsEndImageContext(); //Important!!
        
    }
    
    
    finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); // Important!!!
    
    return finalImage;
    // 壓縮前 2448.000000x3264.000000 (2186859 bytes)
    // 壓縮後  768.000000x1024.000000 ( 252417 bytes)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) editInfo {
    
    self.navigationItem.rightBarButtonItem = doneBtn;
    _authSegment.enabled = true;
    _cellphoneTextField.enabled = true;
    _staffImageView.userInteractionEnabled = true;
    
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
    
    if (![[infoDict valueForKey:CELLPHONENUM] isEqualToString:_cellphoneTextField.text]) {
        NSLog(@"CellphoneChange");
        [updateInfoRef updateChildValues:@{CELLPHONENUM:_cellphoneTextField.text}];
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
