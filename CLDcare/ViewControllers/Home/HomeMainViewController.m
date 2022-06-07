//
//  HomeMainViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/14.
//

#import "HomeMainViewController.h"
#import <Corebluetooth/CoreBluetooth.h>
//#import "ScanPeripheral.h"
#import "HistoryViewController.h"
#import "adv_data.h"
#import "DeviceManager.h"
#import "NDHistory.h"
#import <MBProgressHUD.h>
#import <Toast.h>
#import "MedicationViewController.h"
#import "DeviceViewController.h"
#import "SurveyPopUpViewController.h"
#import "NDMedication.h"
#import "NDHistory.h"
#import "ListCVCell.h"
#import "PopUpViewController.h"
#import "AdditionViewController.h"
#import "ClauseDetailViewController.h"
@import UserNotifications;

@interface HomeMainViewController () <CBCentralManagerDelegate, ScanPeripheralDelegate> {
    int tiltCnt;
    bool isTilt;
    int count;

    NSInteger         current_count;
    NSData*           deviceMac;
    NSString*         deviceName;
}

@property (weak, nonatomic) IBOutlet UIView *v_Noti;
@property (weak, nonatomic) IBOutlet UILabel *lb_Noti;
@property (weak, nonatomic) IBOutlet UIView *v_SelectedBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_SelectedBarLeading;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) ScanPeripheral *currentDevice;
@property (strong, nonatomic) MBProgressHUD* hud;
@property (strong, nonatomic) MedicationViewController *vc_Medication;
@property (strong, nonatomic) DeviceViewController *vc_Device;
//@property (assign, nonatomic) BOOL isSync;
@property (weak, nonatomic) IBOutlet UIStackView *stv_Temp;

@property (weak, nonatomic) IBOutlet UIView *v_Schedule;
@property (weak, nonatomic) IBOutlet UIView *v_DeviceBg;

@property (weak, nonatomic) IBOutlet UILabel *lb_StandardTime;
@property (weak, nonatomic) IBOutlet UILabel *lb_MedicationStatus;  //복약여부: 복용함 | -
@property (weak, nonatomic) IBOutlet UILabel *lb_MedicationTime;    //오전 11:30
@property (weak, nonatomic) IBOutlet UILabel *lb_RemainDay;         //남은시간: 1
@property (weak, nonatomic) IBOutlet UILabel *lb_RemainDayFix;      //일전
@property (weak, nonatomic) IBOutlet UILabel *lb_Today;             //복약 일정
@property (weak, nonatomic) IBOutlet UICollectionView *cv_List;
@property (weak, nonatomic) IBOutlet UILabel *lb_DateEmpty;

@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceName;
@property (weak, nonatomic) IBOutlet UIButton *btn_MedicationCount;
@property (weak, nonatomic) IBOutlet UILabel *lb_ConnectStatus;
@property (weak, nonatomic) IBOutlet UILabel *lb_Battery;
@property (weak, nonatomic) IBOutlet UIButton *btn_ConnectSetting;

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSString *str_ToDayMedication;

//로컬라이징
@property (weak, nonatomic) IBOutlet UILabel *lb_MedicationFix;         //복약 정보
@property (weak, nonatomic) IBOutlet UIButton *lb_MedicationYnFix;      //복약 여부
@property (weak, nonatomic) IBOutlet UIButton *btn_DrugSeeFix;          //약품정보 확인
@property (weak, nonatomic) IBOutlet UIButton *btn_RemainingTimeFix;    //남은 시간
@property (weak, nonatomic) IBOutlet UILabel *lb_DrugScheduleFix;       //복약 일정
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceNameFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_ConnectStatusFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_BatteryFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_DrugCountFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_ConnectYnFix;

@end

@implementation HomeMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UpdateStatus updateStatus = [Util needsUpdate];
    if( updateStatus == Optional ) {
        PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
        vc.isUpdateMode = true;
        vc.updateStatus = Optional;
        [vc setPopUpDismissBlock:^{
            NSString *str_AppStoreLink = [NSString stringWithFormat:@"itms://itunes.apple.com/app/apple-store/id%@?mt=8", APP_STORE_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str_AppStoreLink] options:@{} completionHandler:nil];
        }];
        [self presentViewController:vc animated:true completion:^{
            
        }];
    }

    [UIApplication sharedApplication].idleTimerDisabled = true;

    _lb_MedicationFix.text = NSLocalizedString(@"Med Info", nil);
    [_lb_MedicationYnFix setTitle:NSLocalizedString(@"Med Status", nil) forState:0];
    [_btn_DrugSeeFix setTitle:NSLocalizedString(@"Drug info", nil) forState:0];
    [_btn_RemainingTimeFix setTitle:NSLocalizedString(@"Next Med Time", nil) forState:0];
    _lb_DrugScheduleFix.text = NSLocalizedString(@"Med Tracer", nil);
    _lb_DeviceNameFix.text = NSLocalizedString(@"Sensor Device", nil);
    
    [_btn_ConnectStatusFix setTitle:NSLocalizedString(@"Pairing", nil) forState:0];
    [_btn_BatteryFix setTitle:NSLocalizedString(@"Battery", nil) forState:0];
    [_btn_DrugCountFix setTitle:NSLocalizedString(@"Pills Taken", nil) forState:0];
    [_btn_ConnectYnFix setTitle:NSLocalizedString(@"Device connect", nil) forState:0];

    _items = [NSMutableArray array];
    _lb_MedicationStatus.text = @"-";
    _lb_StandardTime.text = @"-";

    
    [Util updateAlarm];

    current_count = -1;
    
    dispatch_queue_t centralQueue = dispatch_queue_create("CB_QUEUE", DISPATCH_QUEUE_SERIAL);
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationDidEnterForeground:)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationDidEnterBackground:)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
    
#if DEBUG
//    _stv_Temp.hidden = false;
#endif
    
    _btn_ConnectSetting.clipsToBounds = true;
    _btn_ConnectSetting.layer.borderWidth = 1;
    _btn_ConnectSetting.layer.cornerRadius = 2;
    _btn_ConnectSetting.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;

    NSInteger nCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"count"];
    [self updateCountLabel:nCount];

}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [Util topRound:_v_Schedule];
    [Util topRound:_v_DeviceBg];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if( _centralManager.state == CBManagerStatePoweredOn ) {
        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
        [_centralManager scanForPeripheralsWithServices:@[[ScanPeripheral uartServiceUUID]] options:options];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Util checkReqUpdate:self];

    [self updateData];
    [self updateStatus];
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *pill = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_UserPill", email]]; //현재약품
    if( pill == nil || pill.length <= 0 ) {
        AdditionViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdditionViewController"];
        vc.isHideClose = true;
        [self presentViewController:vc animated:true completion:nil];
    }
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
                
                [self.items removeAllObjects];
                [self.cv_List reloadData];
                
                [self updateStatus];
            }];
            [self presentViewController:vc animated:true completion:^{
                
            }];
            return false;
        }
    }
    return true;
}

- (void)applicationDidEnterForeground:(NSNotification *)notification {
    [self updateData];
}

- (void)updateData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    _lb_Today.text = [dateFormatter stringFromDate:[NSDate date]];
    
    [self updateMedicationList];
}

- (void)updateStatus {
    if( IS_CONNECTED ) {
        _lb_DeviceName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        _lb_ConnectStatus.text = NSLocalizedString(@"Connect", nil);
//        _lb_ConnectStatus.textColor = [UIColor whiteColor];
        NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
        _lb_Battery.text = [NSString stringWithFormat:@"%ld%%", nBattery];
        [_btn_ConnectSetting setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
    } else {
        _lb_DeviceName.text = NSLocalizedString(@"Pair your device", nil);
        _lb_ConnectStatus.text = NSLocalizedString(@"Not paired", nil);
//        _lb_ConnectStatus.textColor = [UIColor colorWithHexString:@"afafaf"];
        _lb_Battery.text = @"-";
        [_btn_ConnectSetting setTitle:NSLocalizedString(@"Setting", nil) forState:UIControlStateNormal];
        [_btn_MedicationCount setTitle:@"-" forState:UIControlStateNormal];
    }
}

- (void)updateInfo:(dispenser_manuf_data_t *)md {
    if( md != nil ) {
        [self updateCountLabel:md->count];
    }
}

- (void)updateCountLabel:(NSInteger)count {
    [_btn_MedicationCount setTitle:[NSString stringWithFormat:@"%ld%@", count, NSLocalizedString(@"ea", nil)] forState:UIControlStateNormal];
}

- (void)updateMedicationList {
    [self.items removeAllObjects];

    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( deviceName.length > 0 && email.length > 0 ) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSString *dateString = [format stringFromDate:[NSDate date]];

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:email forKey:@"mem_email"];
//        [dicM_Params setObject:dateString forKey:@"pairing_datetime"];
        [dicM_Params setObject:deviceName forKey:@"device_id"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/select/caregiverinfo" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
                [Util showAlert:NSLocalizedString(@"Invalid ID or password", nil) withVc:self];
                return;
            }
            
            if( msgCode == NO_INFORMATION ) {
                //해당정보 없을 시
                [self.cv_List reloadData];
                return;
            }
            
            NSString *str_Warning = resulte[@"warning_medication"];
            if( [str_Warning isEqualToString:@"Y"] ) {
                //푸시 발송
                NSString *str_Caregiver = resulte[@"caregiver_info"];
                [self sendPush:str_Caregiver];
            }
            
            NSArray *ar_Alarm = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];

            NSLog(@"%@", resulte);
            NSDate *lastDate = nil;
            NSArray *ar_List = resulte[@"timeline_list"];
            if( ar_List.count > 0 ) {
                for( NSArray *sub in ar_List ) {
                    if( sub[0] != nil && sub[1] != nil ) {
                        NSString *dateString = sub[0];
                        NSDateFormatter *format = [[NSDateFormatter alloc] init];
                        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                        NSDate *date = [format dateFromString:dateString];

                        MedicationStatusCode code = UNKNOW;
                        NSString *msg = @"";
                        NSString *type = sub[1];
                        if( [type isEqualToString:@"timeset"] ) {
                            msg = NSLocalizedString(@"Med taken", nil);
                        } else if( [type isEqualToString:@"timeset1"] ) {
//                            code = TIMESET1;
                            msg = NSLocalizedString(@"This is the first med time", nil);
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[0];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                            }
                        } else if( [type isEqualToString:@"timeset2"] ) {
                            msg = NSLocalizedString(@"This is the second med time", nil);
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[1];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                            }
                        } else if( [type isEqualToString:@"timeset3"] ) {
                            msg = NSLocalizedString(@"This is the third med time", nil);
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[2];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                            }
                        } else if( [type isEqualToString:@"dose"] ) {
                            msg = NSLocalizedString(@"Med taken", nil);
                            lastDate = date;
                        } else if( [type isEqualToString:@"survey"] ) {
                            msg = NSLocalizedString(@"Completed the survey", nil);
                        } else if( [type isEqualToString:@"confirm"] ) {
                            msg = NSLocalizedString(@"Checked the alarm", nil);
                        } else if( [type isEqualToString:@"snooze"] ) {
                            msg = NSLocalizedString(@"Postponed the alarm", nil);
                        }

                        self.str_ToDayMedication = resulte[@"today_medication"];
                        NDMedication *item = [[NDMedication alloc] initWithTime:[date timeIntervalSince1970] withType:code withMsg:msg];
                        [self.items addObject:item];
                    }
                }
            }

            if( [self.str_ToDayMedication isEqualToString:@"Y"] ) {
                if( lastDate != nil ) {
                    self.lb_MedicationTime.hidden = false;

                    NSString * language = [[NSLocale preferredLanguages] firstObject];
                    NSLog(@"%@", language);
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
                    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
                    [dateFormatter setDateFormat:@"a hh:mm"];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.lb_MedicationTime.text = [dateFormatter stringFromDate:lastDate];
                        self.lb_MedicationStatus.text = NSLocalizedString(@"Taken", nil);
                    });
                }
            }
            
            //남은시간
            NSInteger nWatingHour = -1;
            NSInteger nWatingMin = -1;
            NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *str_NowDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld",
                                     comp.year, comp.month, comp.day, comp.hour, comp.minute];
            NSDate *nowDate = [format dateFromString:str_NowDate];

            NSArray *arM_Alarms = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];
            if( arM_Alarms.count > 0 ) {
                for( NSDictionary *dic in arM_Alarms ) {
                    NSInteger nHour = [dic[@"hour"] integerValue];
                    NSInteger nMin = [dic[@"min"] integerValue];

                    NSString *str_AlarmDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld",
                                               comp.year, comp.month, comp.day, nHour, nMin];
                    NSDate *alarmDate = [format dateFromString:str_AlarmDate];
                    
                    NSDateComponents *compareComp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:alarmDate toDate:nowDate options:0];
                    NSLog(@"%ld", compareComp.hour);
                    NSLog(@"%ld", compareComp.minute);
                    if( compareComp.hour == 0 && compareComp.minute == 0 ) {
                        nWatingMin = 0;
                        break;
                    } else if( compareComp.hour < 0 || compareComp.minute < 0 ) {
                        nWatingHour = compareComp.hour * -1;
                        nWatingMin = compareComp.minute * -1;
                        break;
                    }
                }
                
                self.lb_RemainDayFix.hidden = false;

                if( nWatingHour > 0 ) {
                    self.lb_RemainDay.text = [NSString stringWithFormat:@"%ld", nWatingHour];
                    self.lb_RemainDayFix.text = NSLocalizedString(@"Hour(s) later", nil);
                } else if( nWatingMin >= 0 ) {
                    self.lb_RemainDay.text = [NSString stringWithFormat:@"%ld", nWatingMin];
                    self.lb_RemainDayFix.text = NSLocalizedString(@"Minute(s) later", nil);
                } else if( nWatingHour < 0 && nWatingHour < 0 ) {
                    self.lb_RemainDay.text = @"1";
                    self.lb_RemainDayFix.text = NSLocalizedString(@"Day(s) later", nil);
                }
            } else {
                self.lb_RemainDayFix.hidden = true;
                self.lb_RemainDay.text = @"-";
            }

            //나의 복약 정보 날짜
            self.lb_StandardTime.text = [NSString stringWithFormat:@"%@ 기준", [format stringFromDate:[NSDate date]]];

            [self.cv_List reloadData];
            
//            if( self.items.count > 0 ) {
////                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tbv_List numberOfRowsInSection:0] - 1) inSection:0];
////                [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
//                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//                [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
//            }
        }];
    } else {
        [self.cv_List reloadData];
//        if( self.items.count > 0 ) {
////            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tbv_List numberOfRowsInSection:0] - 1) inSection:0];
////            [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
//            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//            [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
//        }
    }
}
//- (void)applicationDidEnterForeground:(NSNotification *)notification {
//    if( _centralManager.state == CBManagerStatePoweredOn ) {
//        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
//        [_centralManager scanForPeripheralsWithServices:@[[ScanPeripheral uartServiceUUID]] options:options];
//    }
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.isSync = false;
//    });
//}
//
//- (void)applicationDidEnterBackground:(NSNotification *)notification {
//
//}

- (void)sendPush:(NSString *)targetEmail {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSTimeInterval pushTime = [[NSUserDefaults standardUserDefaults] doubleForKey:[NSString stringWithFormat:@"%@_PushTime", email]];
    NSLog(@"%f", [[NSDate date] timeIntervalSince1970] - pushTime);
    if( [[NSDate date] timeIntervalSince1970] - pushTime < 60 ) {
        //1분안에 또 푸시를 보내는것을 방지
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:targetEmail forKey:@"caregiver_email"];
    [dicM_Params setObject:@"warning" forKey:@"request_type"];
    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];
    [dicM_Params setObject:str_NowDate forKey:@"reg_datetime"];

//    [[WebAPI sharedData] pushAsyncWebAPIBlock:@"caregiver/comments" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"caregiver/comments" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        [self.hud hideAnimated:true];
        self.hud = nil;

        if( error != nil ) {
            return;
        }
        
        if( msgCode == SUCCESS ) {
            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:[NSString stringWithFormat:@"%@_PushTime", email]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

//- (void)countSync:(NSInteger)index {
- (void)setSerial {
    if( _centralManager != nil && _currentDevice != nil ) {
        if (self.hud == nil) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        self.hud.label.text = NSLocalizedString(@"Pairing your device. Pleasewait.", nil);
        [self.hud showAnimated:true];

        DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
        [deviceManager getSerial];
        [deviceManager setSerialNoCompleteBlock:^(NSString *serialNo, NSString *serialChar, NSString *mac) {
            NSLog(@"%@", serialNo);
            [[NSUserDefaults standardUserDefaults] setObject:serialChar forKey:@"serialChar"];
            [[NSUserDefaults standardUserDefaults] setObject:serialNo forKey:@"serialNo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
}

- (void)timeSync {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) { return; }

    if( _centralManager != nil && _currentDevice != nil ) {
        if (self.hud == nil) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        self.hud.label.text = NSLocalizedString(@"Setting the time...", nil);
        [self.hud showAnimated:true];

        DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
        [deviceManager setTime];
        [deviceManager setTimeSyncCompleteBlock:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:true];
                self.hud = nil;
            });
        }];
    }
}

- (void)countSync:(NSArray *)ar {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) { return; }
    
    if( _centralManager != nil && _currentDevice != nil ) {
        if (self.hud == nil) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        self.hud.label.text = NSLocalizedString(@"Synchronizing data...", nil);
        [self.hud showAnimated:true];

        DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
        [deviceManager start:ar];
        [deviceManager setHistoryCompleteBlock:^(NSArray<NDHistory *> * _Nonnull result) {
            NSLog(@"%@", result);
            
//            NSMutableArray *arM_Temp = [NSMutableArray array];
//            for( NSInteger i = 0; i < 2; i++ ) {
//                [arM_Temp addObject:result[i]];
//            }
//            result = arM_Temp;
            
            NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
            NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
            
            NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];

            NSMutableString *strM_Count = [NSMutableString stringWithString:@"["];
            NSMutableString *strM_Time = [NSMutableString stringWithString:@"["];
            for( NDHistory *history in result ) {
                [strM_Count appendString:[NSString stringWithFormat:@"%ld,", history.nIdx]];
                [strM_Time appendString:[NSString stringWithFormat:@"%04ld %ld %ld %ld:%ld:%ld,",
                                         history.year, history.month, history.day, history.hour, history.minute, history.second]];
            }
            
            if( [strM_Count hasSuffix:@","] ) {
                [strM_Count deleteCharactersInRange:NSMakeRange([strM_Count length]-1, 1)];
            }
            [strM_Count appendString:@"]"];

            if( [strM_Time hasSuffix:@","] ) {
                [strM_Time deleteCharactersInRange:NSMakeRange([strM_Time length]-1, 1)];
            }
            [strM_Time appendString:@"]"];

            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:email forKey:@"mem_email"];
            [dicM_Params setObject:strM_Count forKey:@"dose_count"];
            [dicM_Params setObject:strM_Time forKey:@"datetime"];
            [dicM_Params setObject:str_NowDate forKey:@"datetime_realtime"];
            [dicM_Params setObject:deviceName forKey:@"device_id"];
            [dicM_Params setObject:macAddr forKey:@"device_mac_address"];
            [dicM_Params setObject:@"N" forKey:@"mapping_status"];                  //처방내역 연동여부
            [dicM_Params setObject:@"" forKey:@"mapping_pill_name"];                //처방 약품 이름
            [dicM_Params setObject:str_SerialNo forKey:@"serial_num"];    //시리얼 넘버

            [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/missingDose" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                [self.hud hideAnimated:true];
                self.hud = nil;

                if( error != nil ) {
                    return;
                }
                
                NSLog(@"%@", result);
                [self.vc_Medication reloadList];
            }];
        }];
    }
}

- (void)resetCount {
    if( _centralManager != nil && _currentDevice != nil ) {

        if (self.hud == nil) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }

        self.hud.label.text = NSLocalizedString(@"Initializing data...", nil);
        [self.hud showAnimated:true];

        DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
        [deviceManager resetCount];
        [deviceManager setResetCountCompleteBlock:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                if( isSuccess ) {
//                    [self.view makeToast:@"리셋 성공"];
//                } else {
//                    [self.view makeToast:@"리셋 실패"];
//                }
                [self.hud hideAnimated:true];
                self.hud = nil;
            });
        }];
    }
}

- (IBAction)goSync:(id)sender {
    [self countSync:0];
}

- (IBAction)goReset:(id)sender {
    [self resetCount];
}

- (IBAction)goShowMedicineInfo:(id)sender {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *pill = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_UserPill", email]]; //현재약품
    if( pill.length > 0 ) {
        NSInteger nMedicineCode = 0;
        if( [pill hasPrefix:@"아모잘탄엑스큐정"] ) {
            nMedicineCode = 202007696;
        } else if( [pill hasPrefix:@"얼리다정"] ) {
            nMedicineCode = 202009334;
        } else {
            return;
        }
        ClauseDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClauseDetailViewController"];
        vc.hidesBottomBarWhenPushed = true;
        vc.str_Title = @"의약품 상세정보";
        vc.str_Url = [NSString stringWithFormat:@"https://nedrug.mfds.go.kr/pbp/CCBBB01/getItemDetail?itemSeq=%ld", nMedicineCode];
        [self.navigationController pushViewController:vc animated:true];
    }
}

- (void)onTiltCheck:(NSData *)manufData {
    dispenser_tilt_data_t *md_tilt = (dispenser_tilt_data_t*)manufData.bytes;

    self->isTilt = false;
    NSLog(@"%@", @(md_tilt->count));
    NSLog(@"%d", self->count);
    if( self->count == md_tilt->count ) {
        NSLog(@"서버전송");
        NSLog(@"%u", md_tilt->epochtime1);
        
        [self sendTiltData:manufData idx:0];
//        [self sendTiltData:manufData idx:1];
//        [self sendTiltData:manufData idx:2];

    }
    if( self->count > [@(md_tilt->count) intValue] ) {
        NSLog(@"토출함");
    }
}

- (void)sendTiltData:(NSData *)manufData idx:(NSInteger)idx {
    dispenser_tilt_data_t *md_tilt = (dispenser_tilt_data_t*)manufData.bytes;

    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];
    NSString *str_DoseDate = @"";
    int ir = 0;
    switch (idx) {
        case 0:
            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime1)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            ir = md_tilt->info_ir1;
            break;
        case 1:
            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime2)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            ir = md_tilt->info_ir2;
            break;
        case 2:
            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime3)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            ir = md_tilt->info_ir3;
            break;
        default:
            break;
    }
    
    NSString *str_StatusInfo = [NSString stringWithFormat:@"%@,%@,%@", @(md_tilt->info_identifier[0]),@(md_tilt->info_identifier[1]),@(md_tilt->info_identifier[2])];
    NSLog(@"%@", str_StatusInfo);
//    NSArray *ar_StatusInfo = @[@(md_tilt->info_identifier[0]), @(md_tilt->info_identifier[1]), @(md_tilt->info_identifier[2])];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@(md_tilt->info_count) forKey:@"information_idx"];   //디바이스 정보 인덱스
    [dicM_Params setObject:@(self->count) forKey:@"dose_count"];                //토출갯수
    [dicM_Params setObject:str_StatusInfo forKey:@"status_info"];                     //커맨드 값
    [dicM_Params setObject:@(ir) forKey:@"ir_value"];                           //기울기 값
    [dicM_Params setObject:deviceName forKey:@"device_id"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nBattery] forKey:@"device_battery"];
    [dicM_Params setObject:str_DoseDate forKey:@"datetime"];
    [dicM_Params setObject:str_NowDate forKey:@"datetime_realtime"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/dispenerinfo" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        [self.hud hideAnimated:true];
        self.hud = nil;

        if( error != nil ) {
            return;
        }

        NSLog(@"idx : %ld, %@", idx, resulte);

        if( idx == 0 ) {
            if( [resulte[@"device_error"] isEqualToString:@"Y"] ) {
                PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
                vc.isReport = true;
                [vc setPopUpDismissBlock:^{
                    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedBackViewController"];
                    [self.navigationController pushViewController:vc animated:true];
                }];
                [self presentViewController:vc animated:true completion:^{
                    
                }];
            }
            [self sendTiltData:manufData idx:1];
            [self sendTiltData:manufData idx:2];
        }
    }];
}



#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if( central.state == CBManagerStatePoweredOn ) {
        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
        [_centralManager scanForPeripheralsWithServices:@[[ScanPeripheral uartServiceUUID]] options:options];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSData* manufData = advertisementData[CBAdvertisementDataManufacturerDataKey];
        if( manufData == nil ) {
            return;
        }
        
        dispenser_manuf_data_t* md = (dispenser_manuf_data_t *)manufData.bytes;
        dispenser_tilt_data_t *md_tilt = (dispenser_tilt_data_t*)manufData.bytes;

        if (md->company_identifier != (0x4d<<8 | 0x4f)) { return; }
        
        if( IS_CONNECTED == false ) {
            [self.btn_MedicationCount setTitle:@"-" forState:UIControlStateNormal];
            return;
        }
        
        NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
        NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
        NSString *ble_uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"ble_uuid"];
        NSString *current_ble_uuid = [peripheral.identifier UUIDString];

//        NSInteger macAddrLength = sizeof(md->mac) - 1;
//        NSMutableString *currentMacAddr = [NSMutableString stringWithCapacity:macAddrLength];
//        for (NSInteger i = macAddrLength; i >= 0; i--) {
//            [currentMacAddr appendString:[NSString stringWithFormat:@"%02x", (unsigned int) md->mac[i]]];
//            if( i > 0 ) {
//                [currentMacAddr appendString:@":"];
//            }
//        }

        
        NSString *currentLastMacAddr = [NSString stringWithFormat:@"%02x", (unsigned int) md->addr[0]];
        NSArray *ar_MacAddr = [macAddr componentsSeparatedByString:@":"];

        //기울기 감지
        if( weakSelf.currentDevice != nil && weakSelf.currentDevice.peripheral == peripheral ) {
            self->count = md->count;
            if( [currentLastMacAddr isEqualToString:[ar_MacAddr lastObject]] == false && self->isTilt == false ) {
                NSLog(@"b2 : %@", @(md_tilt->bat));

//            if( [currentMacAddr isEqualToString:macAddr] == false && self->isTilt == false ) {
//            if( [current_ble_uuid isEqualToString:macAddr] == false && self->isTilt == false ) {
//                NSLog(@"기울기 감지");
//                NSString *str = [NSString stringWithFormat:@"%02x", (unsigned int) md_tilt->mac_identifier];    //95
//                //md_tilt->info_identifier : 08 07 07 22
//                NSLog(@"%@", str);
//                NSInteger macAddrLength = sizeof(md_tilt->info_identifier) - 1;
//                NSMutableString *currentMacAddr = [NSMutableString stringWithCapacity:macAddrLength];
//                for (NSInteger i = macAddrLength; i >= 0; i--) {
//                    [currentMacAddr appendString:[NSString stringWithFormat:@"%02x", (unsigned int) md_tilt->info_identifier[i]]];
//                    if( i > 0 ) {
//                        [currentMacAddr appendString:@":"];
//                    }
//                }
                if( self->tiltCnt < md_tilt->info_count ) {
                    self->tiltCnt = md_tilt->info_count;
                    NSLog(@"count1 : %hu", md_tilt->count);
                    NSLog(@"count2 : %hu", md->count);
                    NSLog(@"md_tilt->info_count : %d", md_tilt->info_count);
                    self->isTilt = true;
                    [self performSelector:@selector(onTiltCheck:) withObject:manufData afterDelay:5.0f];
                }
//                NSLog(@"md_tilt->info_count : %d", md_tilt->info_count);
            } else {
                NSLog(@"b : %@", @(md->bat));
            }
        }
        ////////////////////////////

        
        
//        NSLog(@"call macAddr : %@", currentMacAddr);
        //d4:06:41:32:3a:85
        if( current_ble_uuid != nil && current_ble_uuid.length > 0 && [ble_uuid isEqualToString:current_ble_uuid] ) {
//        if( macAddr != nil && macAddr.length > 0 && [currentMacAddr isEqualToString:macAddr] ) {
//        if( macAddr != nil && macAddr.length > 0 && [[peripheral.identifier UUIDString] isEqualToString:macAddr] ) {
            if( weakSelf.currentDevice == nil || weakSelf.currentDevice.peripheral != peripheral ) {
                weakSelf.currentDevice = [ScanPeripheral initWithPeripheral:peripheral];
            }

//            NSLog(@"connection macAddr : %@", currentMacAddr);

            [[NSUserDefaults standardUserDefaults] setObject:@(md->bat) forKey:@"battery"];
            [[NSUserDefaults standardUserDefaults] setInteger:md->count forKey:@"count"];
            [[NSUserDefaults standardUserDefaults] synchronize];

//            [self updateInfo:md];
            [self.btn_MedicationCount setTitle:[NSString stringWithFormat:@"%u%@", md->count, NSLocalizedString(@"ea", nil)] forState:UIControlStateNormal];

//            BOOL isInitDevice = [[NSUserDefaults standardUserDefaults] boolForKey:@"isInitDevice"];
//            if( isInitDevice != true && md->count > 0 ) {
//                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isInitDevice"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                [self resetCount];
//            }
//            if( self.isSync == false ) {
//                NSLog(@"SyncSyncSyncSyncSyncSync");
//
//                self.isSync = true;
//
//                NSInteger nLastIdx = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastIdx"];
//                NSLog(@"nLastIdx: %ld", nLastIdx);
//                NSLog(@"md->count in: %u", md->count);
//                if( nLastIdx < md->count ) {
//                    [self countSync:nLastIdx];
//                }
//            }
            
//            [weakSelf.vc_Medication updateInfo:md];
//            [weakSelf.vc_Device updateInfo:md];

            if( md->count == 0 || self->current_count == -1 ) {
                self->current_count = md->count;
            } else {
                if( self->current_count != md->count ) {
                    
                    self->current_count = md->count;

                    NSString *str_SerialNo = [Util convertSerialNo];
                    if( str_SerialNo == nil ) {
                        [self.view makeToast:@"시리얼 번호를 얻어오지 못했습니다.\n약통을 다시 연결해 주세요."];
                        return;
                    }

    //                NSInteger doseCnt = md->count - self->current_count;
                    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];
                    NSString *str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime1)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *nowDate = [format dateFromString:str_NowDate];
                    NSDateComponents *nowComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear| NSCalendarUnitHour | NSCalendarUnitMinute fromDate:nowDate];
                    NSDate *doseDate = [format dateFromString:str_DoseDate];
                    NSDateComponents *doseComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear| NSCalendarUnitHour | NSCalendarUnitMinute fromDate:doseDate];
                    BOOL isTimeSycing = false;
                    if( nowComp.year != doseComp.year ||
                       nowComp.month != doseComp.month ||
                       nowComp.day != doseComp.day ||
                       nowComp.hour != doseComp.hour ||
                       nowComp.minute != doseComp.minute ) {
                        isTimeSycing = true;
//                        [self timeSync];
                    }

                    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                    [dicM_Params setObject:email forKey:@"mem_email"];
                    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self->current_count] forKey:@"dose_count"];
                    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nBattery] forKey:@"device_battery"];
                    [dicM_Params setObject:str_DoseDate forKey:@"datetime"];                  //토출시간
                    [dicM_Params setObject:str_NowDate forKey:@"datetime_realtime"];         //현재시간
                    [dicM_Params setObject:@"9" forKey:@"dispenser_top"];                   //우선 9로 하드코딩
                    [dicM_Params setObject:@"9" forKey:@"dispenser_bottom"];                //우선 9로 하드코딩
                    [dicM_Params setObject:deviceName forKey:@"device_id"];
                    [dicM_Params setObject:macAddr forKey:@"device_mac_address"];
                    [dicM_Params setObject:@"N" forKey:@"mapping_status"];                  //처방내역 연동여부
                    [dicM_Params setObject:@"" forKey:@"mapping_pill_name"];                //처방 약품 이름
                    [dicM_Params setObject:str_SerialNo forKey:@"serial_num"];    //시리얼 넘버

                    [self.view makeToast:NSLocalizedString(@"took one medicine", nil)];
                    
                    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/dose" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                        if( error != nil ) {
                            return;
                        }
                        
                        //토출 시 다른값이 동일시간에 토출 된 경우 레포트 팝업 띄우기
                        NSString *deviceErr = resulte[@"device_error"];
                        if( [deviceErr isEqualToString:@"Y"] ) {
                            PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
                            vc.isReport = true;
                            [vc setPopUpDismissBlock:^{
                                UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedBackViewController"];
                                [self.navigationController pushViewController:vc animated:true];
                            }];
                            [self presentViewController:vc animated:true completion:^{
                                
                            }];
                            return;
                        }

                        NSInteger nTodayDoseCnt = [resulte[@"today_dose_cnt"] integerValue];
                        if( nTodayDoseCnt > 0 ) {
                            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%04ld%02ld%02ld", components.year, components.month, components.day] forKey:@"skipDate"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [Util skipTodayAlarm];
                        }

                        NSLog(@"%ld", [resulte[@"dispenser_count"] integerValue]);
    //                    [[NSUserDefaults standardUserDefaults] setInteger:[resulte[@"dispenser_count"] integerValue] forKey:@"lastIdx"];
    //                    [[NSUserDefaults standardUserDefaults] synchronize];

                        NSString *str_Duplicate = resulte[@"duplicate"];
                        if( [str_Duplicate isEqualToString:@"Y"] ) {
//                            [self.view makeToast:@"===== 테스트 메세지 =====\n중복 데이터"];
                            return;
                        }
                        
                        BOOL isMissing = [resulte[@"missing_cnt"] isEqualToString:@"Y"];
                        if( isMissing ) {
                            NSArray *ar_MissingList = resulte[@"missing_idx"];
                            if( ar_MissingList.count > 0 ) {
    //                            NSInteger nStartIdx = [[ar_MissingList firstObject] integerValue];
                                [self countSync:ar_MissingList];
                            }
                        } else {
                            if( [resulte[@"reset_time"] isEqualToString:@"Y"] || isTimeSycing == true ) {
                                [self timeSync];
                            }
                        }
                        
                        dispenser_manuf_data_t* md_tmp = (dispenser_manuf_data_t *)manufData.bytes;
                        NSString *str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tmp->epochtime2)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                        [dicM_Params setObject:str_DoseDate forKey:@"datetime"];
                        [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/dose" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                            dispenser_manuf_data_t* md_tmp = (dispenser_manuf_data_t *)manufData.bytes;
                            NSString *str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tmp->epochtime3)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                            [dicM_Params setObject:str_DoseDate forKey:@"datetime"];
                            [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/dose" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                            }];
                        }];
                    }];

                    [self addList:md->epochtime1];
                    [self updateMedicationList];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DoseNoti" object:nil];
                }
            }
        }
    });
}


- (void)addList:(NSTimeInterval)time {
    BOOL isHave = false;
    NDMedication *item = [[NDMedication alloc] initWithTime:time withType:DOSE withMsg:@"약을 복용했습니다."];
    for( NDMedication *obj in _items ) {
        if( item.time == obj.time ) {
            isHave = true;
            break;
        }
    }
    
    if( isHave == false ) {
        [_items addObject:item];
        [_cv_List reloadData];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connected ...");
    [_currentDevice findService];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnected..");
//    [self scanForPeripherals:YES];
    if( _centralManager.state != CBManagerStatePoweredOn ) {
        return;
    }
    
    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
    [_centralManager scanForPeripheralsWithServices:@[[ScanPeripheral uartServiceUUID]] options:options];
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                               ascending:YES];
    NSArray *sortArray = [_items sortedArrayUsingDescriptors:@[sortDescriptor]];
    _items = [NSMutableArray arrayWithArray:sortArray];

    if( _cv_List.bounds.size.width < 110 * _items.count ) {
        _cv_List.contentOffset = CGPointMake((110 * _items.count) - self.view.bounds.size.width + 20, 0);
    }
    return _items.count;
}
 
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCVCell" forIndexPath:indexPath];

    if( _items.count - 1 < indexPath.row ) {
        return cell;
    }
    
    if( _items.count == 1 ) {
        cell.v_LeftDot.hidden = true;
        cell.v_RightDot.hidden = true;
    } else if( indexPath.row == 0 ) {
        cell.v_LeftDot.hidden = true;
        cell.v_RightDot.hidden = false;
    } else if( indexPath.row == _items.count - 1 ) {
        cell.v_LeftDot.hidden = false;
        cell.v_RightDot.hidden = true;
    } else {
        cell.v_LeftDot.hidden = false;
        cell.v_RightDot.hidden = false;
    }
    
    NDMedication *item = _items[indexPath.row];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(item.time)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    
    
    
    
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if( [language isEqualToString:@"ko"] ) {
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    } else {
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    
    
//    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setDateFormat:@"a hh:mm"];

    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    cell.lb_Time.text = [dateFormatter stringFromDate:date];
    cell.lb_Msg.text = item.msg;
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] + (60 * 60 * 9);
    nowTime += 60;
    if( item.time < nowTime ) {
        [cell setFill:true];
    } else {
        [cell setFill:false];
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(110, 150);
}

@end
