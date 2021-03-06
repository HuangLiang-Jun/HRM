//
//  StaffInfoViewController.m
//  HRM
//
//  Created by huang on 2016/11/4.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "StaffInfoViewController.h"
#import "StaffInfoDataManager.h"
#import "CurrentUser.h"

#define CELLPHONENUM @"CellphoneNumber"

@interface StaffInfoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UISegmentedControl *authSegment;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *cellphoneTextField;
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
    FIRDatabaseReference *imageUrlRef;
    NSString *staffUID;
    NSString *newUrl;
    UIImage *SFImg;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _editStatus = false;
    dataManager = [StaffInfoDataManager sharedInstance];
    dataManager.imageStatus = false;
    updateInfoRef = [[[[[FIRDatabase database]reference]child:@"StaffInformation"]child:_nameStr]child:@"Info"];
    updateAuthRef =[[[[FIRDatabase database]reference]child:@"StaffInformation"]child:_nameStr];
    imageUrlRef = [[[FIRDatabase database]reference]child:@"thumbnail"];
    
    infoDict = [_staffInfoDict valueForKey:@"Info"];
    auth = [[_staffInfoDict valueForKey:@"Auth"]intValue];
    
    _nameTextField.text = _nameStr;
    _birthdayTextField.text = [infoDict valueForKey:@"Birthday"];
    _idTextField.text = [infoDict valueForKey:@"IDCardNumber"];
    _cellphoneTextField.text = [infoDict valueForKey:CELLPHONENUM];
    
    staffUID = dataManager.allStaffInfoDict[_nameStr][@"UID"];
    //下載個人照
    NSString *URLString = [dataManager.allStaffThumbnailDict valueForKey:staffUID];
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"download image fail: %@",error);
            return ;
        }
        SFImg = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (SFImg != nil){
                self.staffImageView.image = SFImg;
            }
            
        });
        
    }];
    
    [task resume];

    if (auth == 0) {
        _authSegment.selectedSegmentIndex = 0;
    }else {
        _authSegment.selectedSegmentIndex = 1;
    }
    

    editBtn = [[UIBarButtonItem alloc]initWithTitle:@"編輯" style:UIBarButtonItemStylePlain target:self action:@selector(editInfo)];
    doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishEditStaffInfo)];
    
    self.navigationItem.rightBarButtonItem = editBtn;
    
    
    //照片圓角
    _staffImageView.layer.cornerRadius = _staffImageView.frame.size.height *0.5;
    _staffImageView.layer.masksToBounds = true;
    _staffImageView.layer.borderWidth = 0.0;
    _staffImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
}

#pragma - mark Camera

- (IBAction)settingStaffPhotoRecognizer:(UITapGestureRecognizer *)sender {
    
    UIAlertController *alert =  [UIAlertController alertControllerWithTitle:@"選擇照片模式" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
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
    picker.delegate =self;
    picker.allowsEditing = true;
    //picker.mediaTypes = @[@"public.image",@"public.movie"];
    picker.mediaTypes = @[@"public.image"];
    
    picker.delegate = self;
    [self presentViewController:picker animated:true completion:nil];
    
}


-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    //UIImage *resizedImage = [self resizeFromImage:image];
    
    _staffImageView.image = image;
    
    NSData *data = UIImageJPEGRepresentation(image,1.0);
    
    // 編輯照片後上傳到db
    [dataManager upLoadStaffImage:data WiththumbnailName:staffUID withBlock:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error) {
            NSLog(@"upLoad error");
            return;
        }
        
        newUrl = metadata.downloadURL.absoluteString;

    }];
    
    dataManager.imageStatus = true;
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
    
    if (dataManager.imageStatus) {
        
        NSDictionary *imageUpdateDict = @{staffUID:newUrl};
        [imageUrlRef updateChildValues:imageUpdateDict];
    
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
