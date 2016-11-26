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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendNewBulletinBtnPressed:(UIButton *)sender {
    
    [comm snedBulletinMessage:_setTittleTextField.text
                   completion:^(NSError *error, id result) {
                       if (error) {
                           NSLog(@"SendPushTitle is Error : %@",error);
                       }
                       
                       NSLog(@"SendPushTitle is OK : %@",[result description]);
                   }];
}

-(IBAction) textFieldDoneEditing: (id) sender
{
    [sender resignFirstResponder];
}

- (void) updateNewBulletin {
    
    NSString *dateStr = [NSDateNSStringExchange stringFromUpdateDate:[NSDate date]];
    NSDictionary *bulletinDict = @{BULLETIN_TITLE_KEY:_setTittleTextField.text,@"Detail":_detailTextField.text,@"UpdateDate":dateStr};
    NSDictionary *updateFBDBDict = @{dateStr:bulletinDict};
    [comm sendNewBulletinToFBDB:updateFBDBDict completion:^(NSError *error, id result) {
        if (error) {
            NSLog(@"UpdateBulletin Error: %@",error);
        }
    }];
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
