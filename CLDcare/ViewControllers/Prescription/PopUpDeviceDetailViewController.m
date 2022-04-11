//
//  PopUpDeviceDetailViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import "PopUpDeviceDetailViewController.h"

@interface PopUpDeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_ModelName;
@property (weak, nonatomic) IBOutlet UILabel *lb_PrescripName;
@property (weak, nonatomic) IBOutlet UILabel *lb_SerialNo;
@end

@implementation PopUpDeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
//    NSString *str_Key = [NSString stringWithFormat:@"%@_Device", email];
//    NSDictionary *dic_Device = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    _lb_ModelName.text = _device.deviceModel;
    _lb_PrescripName.text = _device.deviceUse;
    _lb_SerialNo.text = _device.productNo;
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
