//
//  DeviceViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/14.
//

#import "DeviceViewController.h"
#import "PopUpViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface DeviceViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceName;
@property (weak, nonatomic) IBOutlet UILabel *lb_MedicationCount;
@property (weak, nonatomic) IBOutlet UILabel *lb_ConnectStatus;
@property (weak, nonatomic) IBOutlet UILabel *lb_Battery;
@property (weak, nonatomic) IBOutlet UIButton *btn_AlramSetting;
@property (weak, nonatomic) IBOutlet UIButton *btn_ConnectSetting;
@end

@implementation DeviceViewController
- (void)test {
    //Get all previous noti..
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
    notification.alertBody = @"24 hours passed since last visit :(";
    notification.soundName = @"bell.mp3";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self test];
    
    _btn_AlramSetting.clipsToBounds = true;
    _btn_AlramSetting.layer.borderWidth = 1;
    _btn_AlramSetting.layer.cornerRadius = 2;
    _btn_AlramSetting.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;
    
    _btn_ConnectSetting.clipsToBounds = true;
    _btn_ConnectSetting.layer.borderWidth = 1;
    _btn_ConnectSetting.layer.cornerRadius = 2;
    _btn_ConnectSetting.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;

    NSInteger nCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"count"];
    [self updateCountLabel:nCount];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateStatus];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    if( [identifier isEqualToString:@"SearchDeviceSegue"] ) {
        if( IS_CONNECTED ) {
            PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
            [vc setPopUpDismissBlock:^{
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mac"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"battery"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"battery"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"serialNo"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self updateStatus];
            }];
            [self presentViewController:vc animated:true completion:^{
                
            }];
            return false;
        }
    }
    return true;
}

- (void)updateStatus {
    if( IS_CONNECTED ) {
        _lb_DeviceName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        _lb_ConnectStatus.text = @"연동 완료";
        _lb_ConnectStatus.textColor = [UIColor colorWithHexString:@"222222"];
        NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
        _lb_Battery.text = [NSString stringWithFormat:@"%ld%%", nBattery];
        [_btn_ConnectSetting setTitle:@"연결 해제" forState:UIControlStateNormal];
    } else {
        _lb_DeviceName.text = @"복약기를 연결해주세요";
        _lb_ConnectStatus.text = @"미연결";
        _lb_ConnectStatus.textColor = [UIColor colorWithHexString:@"afafaf"];
        _lb_Battery.text = @"-";
        [_btn_ConnectSetting setTitle:@"연결하기" forState:UIControlStateNormal];
    }
}

- (void)updateInfo:(dispenser_manuf_data_t *)md {
    if( md != nil ) {
        [self updateCountLabel:md->count];
    }
}

- (void)updateCountLabel:(NSInteger)count {
    _lb_MedicationCount.text = [NSString stringWithFormat:@"지금까지 %ld알 먹었어요!", count];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goSetAlarm:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

@end
