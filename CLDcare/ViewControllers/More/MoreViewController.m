//
//  MoreViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/25.
//

#import "MoreViewController.h"
#import "ClauseDetailViewController.h"
#import "PopUpViewController.h"
#import "SearchDeviceViewController.h"
@import UserNotifications;

@interface MoreViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Email;
@property (weak, nonatomic) IBOutlet UISwitch *sw_Alarm;
@property (weak, nonatomic) IBOutlet UISwitch *sw_Survey;
@property (weak, nonatomic) IBOutlet UILabel *lb_Version;
@property (weak, nonatomic) IBOutlet UIButton *btn_Update;
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_LogOut;
@property (weak, nonatomic) IBOutlet UILabel *lb_AccountFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_AlarmFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_ClauseFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_AppInfoFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_AddtionInfoFix;  //추가정보
@property (weak, nonatomic) IBOutlet UIButton *btn_DoseAlarmFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_PrivacyFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_TermsFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_FeedBackFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_VersionInfo;
@property (weak, nonatomic) IBOutlet UIButton *btn_DisConnect;
@property (assign, nonatomic) UpdateStatus updateStatus;
@property (weak, nonatomic) IBOutlet UIView *v_Addtion;
@property (weak, nonatomic) IBOutlet UIButton *btn_Leave;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _v_Addtion.hidden = true;
    
    _lb_TitleFix.text = NSLocalizedString(@"Settings", nil);
    [_btn_LogOut setTitle:NSLocalizedString(@"LogOut", nil) forState:0];
    _lb_AccountFix.text = NSLocalizedString(@"User Account", nil);
    _lb_AlarmFix.text = NSLocalizedString(@"Reminder Setting", nil);
    _lb_ClauseFix.text = NSLocalizedString(@"Policy and Terms of Service", nil);
    _lb_AppInfoFix.text = NSLocalizedString(@"App Infomation", nil);
    [_btn_AddtionInfoFix setTitle:NSLocalizedString(@"Setting for additional information", nil) forState:0];
    [_btn_DoseAlarmFix setTitle:NSLocalizedString(@"Reminder Times", nil) forState:0];
    [_btn_PrivacyFix setTitle:NSLocalizedString(@"Privacy Policy", nil) forState:0];
    [_btn_TermsFix setTitle:NSLocalizedString(@"Terms of Service", nil) forState:0];
    [_btn_FeedBackFix setTitle:NSLocalizedString(@"Send Feedback", nil) forState:0];
    [_btn_VersionInfo setTitle:NSLocalizedString(@"Version", nil) forState:0];
    [_btn_Update setTitle:NSLocalizedString(@"Update", nil) forState:0];
    [_btn_DisConnect setTitle:NSLocalizedString(@"Unpair Sensor Device", nil) forState:0];
    [_btn_Leave setTitle:NSLocalizedString(@"Delete Account", nil) forState:0];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Util checkReqUpdate:self];

    NSString *str_Email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( str_Email.length > 0 ) {
        _lb_Email.text = str_Email;
    } else {
        _lb_Email.text = @"";
    }
    
    _sw_Alarm.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"Alarm"];
    _sw_Survey.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"SurveyAlarm"];

    NSString *str_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _lb_Version.text = [NSString stringWithFormat:@"v%@", str_Version];

    _updateStatus = [Util needsUpdate];
    if( _updateStatus != Latest ) {
//    _isNeedUpdate = [Util needsUpdate];
//    if( _isNeedUpdate ) {
        [self enableBtn:_btn_Update];
    } else {
        [self disableBtn:_btn_Update];
    }

    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if( settings.alertStyle == UNAlertStyleNone ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sw_Alarm.on = false;
            });
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"Alarm"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center removeAllPendingNotificationRequests];
        }
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    if( _sw_Alarm.on == false ) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    if( _sw_Alarm.on == false ) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }
}

- (void)applicationDidEnterForeground:(NSNotification *)notification {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if( settings.alertStyle == UNAlertStyleNone ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sw_Alarm.on = false;
            });
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"Alarm"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)leave:(NSString *)email {
    NSString *myEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( [myEmail isEqualToString:email] == false ) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@""
                                             message:NSLocalizedString(@"Email does not match.", nil)
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[NSLocalizedString(@"Confirm", nil)]
                                            tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        }];
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/delete" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        
        if( msgCode == SUCCESS ) {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@""
                                                 message:NSLocalizedString(@"Success Delete Account\nThank you for your use.", nil)
                                       cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@[NSLocalizedString(@"Confirm", nil)]
                                                tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AccToken"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InphrToken"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UId"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RefToken"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserEmail"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InphrEmail"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserPw"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginType"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [SCENE_DELEGATE showLoginView];
            }];
        }
    }];
}


#pragma mark - Action
- (IBAction)goLogOut:(id)sender {
    [UIAlertController showAlertInViewController:self
                                       withTitle:NSLocalizedString(@"Would you like to log out?", nil)
                                         message:@""
                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[NSLocalizedString(@"confirm", nil)]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        if( action.style == UIAlertActionStyleDefault ) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AccToken"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InphrToken"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RefToken"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InphrEmail"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserPw"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [SCENE_DELEGATE showLoginView];
        }
    }];
}

- (IBAction)goAlarmToggle:(id)sender {
    if( _sw_Alarm.on ) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if( settings.alertStyle == UNAlertStyleNone ) {
                    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"Alarm"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    self.sw_Alarm.on = false;
                    
                    [UIAlertController showAlertInViewController:self
                                                       withTitle:@""
                                                         message:NSLocalizedString(@"The push is off.\nDo you want to change the settings?", nil)
                                               cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@[NSLocalizedString(@"confirm", nil)]
                                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                        if( buttonIndex == 2 ) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                            }];
                        }
                    }];
                } else {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:self.sw_Alarm.on forKey:@"Alarm"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if( self.sw_Alarm.on ) {
                        [Util updateAlarm];
                    } else {
                        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                        [center removeAllPendingNotificationRequests];
                    }
                }
            });
        }];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:self.sw_Alarm.on forKey:@"Alarm"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }
}

//- (IBAction)goAlarmDetail:(id)sender {
//    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlarmDetailViewController"];
//    [self.navigationController pushViewController:vc animated:true];
//}

- (IBAction)goClause1:(id)sender {
    ClauseDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClauseDetailViewController"];
    vc.hidesBottomBarWhenPushed = true;
    vc.str_Title = NSLocalizedString(@"privacy policy", nil);
    vc.str_Url = @"https://coledycred.com/terms/privacy";
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)goClause2:(id)sender {
    ClauseDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClauseDetailViewController"];
    vc.hidesBottomBarWhenPushed = true;
    vc.str_Title = NSLocalizedString(@"terms of use", nil);
    vc.str_Url = @"https://coledycred.com/terms/service";
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)goSurveyAlarmToggle:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.sw_Survey.on forKey:@"SurveyAlarm"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)goSendFeedBack:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedBackViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)goUpdate:(id)sender {
    if( _updateStatus != Latest ) {
//        NSString *str_AppStoreLink = [NSString stringWithFormat:@"itms://itunes.apple.com/app/apple-store/id%@?mt=8", APP_STORE_ID];
        NSString *str_AppStoreLink = [NSString stringWithFormat:@"https://itunes.apple.com/kr/app/apple-store/id%@?mt=8", APP_STORE_ID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str_AppStoreLink] options:@{} completionHandler:nil];
    }
}

//복약 알림 리포트
- (IBAction)goReport:(id)sender {
    
}

- (IBAction)goDisConnect:(id)sender {
    if( IS_CONNECTED ) {
        PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
        [vc setPopUpDismissBlock:^{
            [Util deleteData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DisConnect" object:nil];
        }];
        [self presentViewController:vc animated:true completion:^{
            
        }];
    }
}

- (IBAction)goFirmwareUpdate:(id)sender {
    SearchDeviceViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchDeviceViewController"];
    vc.allMode = true;
    [self.navigationController pushViewController:vc animated:true];

}

//회원탈퇴
- (IBAction)goLeave:(id)sender {
    //탈퇴하기
    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:NSLocalizedString(@"If you leave, all information will be deleted\nand will not be recovered.\nDo you want to leave?", nil)
                               cancelButtonTitle:NSLocalizedString(@"No", nil)
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[NSLocalizedString(@"Yes", nil)]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        if( buttonIndex == 2 ) {
            UIAlertController *alert= [UIAlertController
                                       alertControllerWithTitle:@""
                                       message:NSLocalizedString(@"Please enter email", nil)
                                       preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action){
                UITextField *textField = alert.textFields[0];
                NSLog(@"text was %@", textField.text);
                [self leave:textField.text];
                
            }];
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:ok];
            [alert addAction:cancel];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = NSLocalizedString(@"Please enter email", nil);
                textField.keyboardType = UIKeyboardTypeEmailAddress;
            }];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
