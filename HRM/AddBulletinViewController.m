//
//  AddBulletinViewController.m
//  HRM
//
//  Created by huang on 2016/11/26.
//  Copyright © 2016年 JimSu. All rights reserved.
//

#import "AddBulletinViewController.h"
#import "ServerCommunicator.h"
#import "NSDateNSStringExchange.h"


@interface AddBulletinViewController ()
@property (weak, nonatomic) IBOutlet UITextField *setTittleTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextField;

@end

@implementation AddBulletinViewController

{
    ServerCommunicator *comm;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    comm = [ServerCommunicator shareInstance];
    
    // KeyBoard add TooLbar & DoneBtn.
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem * barBtnPressed = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:barBtnPressed, btnSpace, doneButton, nil];
 
    [topView setItems:buttonsArray];
    [_detailTextField setInputAccessoryView:topView];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sendNewBulletinBtnPressed:(UIButton *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"新增公告確認?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateNewBulletin];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

-(IBAction) textFieldDoneEditing: (id) sender
{
    [sender resignFirstResponder];
}

- (void) updateNewBulletin {
    // UpdateData to FBDB & APNS.
    NSString *dateStr = [NSDateNSStringExchange stringFromYearMonthDay:[NSDate date]];
    NSString *now = [NSDateNSStringExchange stringFromChosenDate:[NSDate date]];
    NSDictionary *bulletinDict = @{BULLETIN_TITLE_KEY:_setTittleTextField.text,@"Detail":_detailTextField.text,@"UpdateDate":now};
    NSDictionary *updateFBDBDict = @{dateStr:bulletinDict};
    [comm sendNewBulletinToFBDB:updateFBDBDict completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"UpdateBulletin Error: %@",error);
        }
        
        [comm snedBulletinMessage:_setTittleTextField.text
                       completion:^(NSError *error, id result) {
                           if (error) {
                               NSLog(@"SendPushTitle is Error : %@",error);
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [self.navigationController popViewControllerAnimated:YES];
                               });
                               return;
                           }
                           NSLog(@"SendPushTitle is OK : %@",[result description]);
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self.navigationController popViewControllerAnimated:YES];
                           });
                           
                       }];
        
    }];
    
   
}

-(IBAction)dismissKeyBoard
{
    [_detailTextField resignFirstResponder];
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
