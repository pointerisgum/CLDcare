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
#import "iOSDFULibrary-Swift.h"
#import "CLDcare-Swift.h"
#import "FrimwareCheckPopupViewController.h"
#import "FWConnectingPopUpViewController.h"
#import "FWDownloadPopUpViewController.h"
#import "FWUpdateViewController.h"

@import UserNotifications;

static BOOL isFWUpdating = false;

@interface HomeMainViewController () <CBCentralManagerDelegate, ScanPeripheralDelegate, DFUProgressDelegate, DFUServiceDelegate> {
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
//@property (weak, nonatomic) IBOutlet UIButton *btn_MedicationCount;
@property (weak, nonatomic) IBOutlet UILabel *lb_ConnectStatus;
@property (weak, nonatomic) IBOutlet UILabel *lb_Battery;
//@property (weak, nonatomic) IBOutlet UIButton *btn_ConnectSetting;
@property (weak, nonatomic) IBOutlet UIButton *btn_TotalPills;
@property (weak, nonatomic) IBOutlet UIButton *btn_ToDayPills;

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
//@property (weak, nonatomic) IBOutlet UIButton *btn_DrugCountFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_ConnectYnFix;

@property (nonatomic, strong) NSMutableArray<CBUUID*>* services;

@property (nonatomic, strong) ScanPeripheral *dfuTargPeripheral;
@property (nonatomic, assign) BOOL isFirstEvent;
//@property (nonatomic, assign) BOOL startUART;
//@property (nonatomic, assign) BOOL uartConnect;
//@property (nonatomic, assign) BOOL isFirmWareUpdate;
//@property (nonatomic, assign) BOOL isUartFinish;

@property (weak, nonatomic) IBOutlet UILabel *lb_TotalPillsFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_ToDayPillsFix;

@property (nonatomic, assign) BOOL isFWUpdating;            //FW업데이트중인지
@property (nonatomic, assign) BOOL isExcuteFWUpdateMode;    //FW업데이트를 실행 했었는지

@property (nonatomic, strong) DFUServiceController *dfuController;
@property (nonatomic, strong) FWUpdateViewController *vc_FWUpdate;
@end

@implementation HomeMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect) name:@"DisConnect" object:nil];
    
    _services = [NSMutableArray array];
    [_services addObject:[ScanPeripheral uartServiceUUID]];
    
    UpdateStatus updateStatus = [Util needsUpdate];
    if( updateStatus == Optional ) {
        PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
        vc.isUpdateMode = true;
        vc.updateStatus = Optional;
        [vc setPopUpDismissBlock:^{
//            NSString *str_AppStoreLink = [NSString stringWithFormat:@"itms://itunes.apple.com/app/apple-store/id%@?mt=8", APP_STORE_ID];
            NSString *str_AppStoreLink = [NSString stringWithFormat:@"https://itunes.apple.com/kr/app/apple-store/id%@?mt=8", APP_STORE_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str_AppStoreLink] options:@{} completionHandler:nil];
        }];
        [self presentViewController:vc animated:true completion:^{
            
        }];
    }

    [UIApplication sharedApplication].idleTimerDisabled = true;

    _lb_MedicationFix.text = NSLocalizedString(@"Your Med", nil);
    [_lb_MedicationYnFix setTitle:NSLocalizedString(@"Med Status", nil) forState:0];
    [_btn_DrugSeeFix setTitle:NSLocalizedString(@"Drug info", nil) forState:0];
    [_btn_RemainingTimeFix setTitle:NSLocalizedString(@"Next Med Time", nil) forState:0];
    _lb_DrugScheduleFix.text = NSLocalizedString(@"Med Tracer", nil);
    _lb_DeviceNameFix.text = NSLocalizedString(@"Sensor Device", nil);
    
    [_btn_ConnectStatusFix setTitle:NSLocalizedString(@"Pairing", nil) forState:0];
    [_btn_BatteryFix setTitle:NSLocalizedString(@"Battery", nil) forState:0];
//    [_btn_DrugCountFix setTitle:NSLocalizedString(@"Pills Taken", nil) forState:0];
    [_btn_ConnectYnFix setTitle:NSLocalizedString(@"Device connect", nil) forState:0];

    _lb_TotalPillsFix.text = NSLocalizedString(@"Total Pills Taken from Bottle", nil);
    _lb_ToDayPillsFix.text = NSLocalizedString(@"Pills Taken Today", nil);


    
    _items = [NSMutableArray array];
    _lb_MedicationStatus.text = @"-";
    _lb_StandardTime.text = @"-";

    
    [Util updateAlarm];

    current_count = -1;
    
    dispatch_queue_t centralQueue = dispatch_queue_create("CB_QUEUE", DISPATCH_QUEUE_SERIAL);
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];

    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
    [_centralManager scanForPeripheralsWithServices:_services options:options];

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
    _stv_Temp.hidden = false;
#endif
    
//    _btn_ConnectSetting.clipsToBounds = true;
//    _btn_ConnectSetting.layer.borderWidth = 1;
//    _btn_ConnectSetting.layer.cornerRadius = 2;
//    _btn_ConnectSetting.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;

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
        [_centralManager scanForPeripheralsWithServices:_services options:options];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UpdateStatus updateStatus = [Util checkReqUpdate:self];
    if( updateStatus == Require ) {
        return;
    }

//    //펌웨어 체크 후 업데이트 필요시 업데이트
//    NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//    NSString *str_MyFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"];
////    NSString *str_MyFWVersion = @"0400";
//    if( (str_MyFWVersion != nil && str_NewFWVersion != nil) && ([str_NewFWVersion integerValue] > [str_MyFWVersion integerValue]) ) {
//        NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//        if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] == false ) {
//            //파일이 없는 경우 다운로드
//            [Util firmWareDownload:str_NewFWVersion];
//        }
//
//        [self setUARTMode];
//    }


    [self updateData];
    [self updateStatus];
    
//    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
//    NSString *pill = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_UserPill", email]]; //현재약품
//    if( pill == nil || pill.length <= 0 ) {
//        AdditionViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdditionViewController"];
//        vc.isHideClose = true;
//        [self presentViewController:vc animated:true completion:nil];
//    }
    
    _isFirstEvent = true;
}

- (void)appWillResignActive:(NSNotification *)noti {
    _isFirstEvent = true;
}

- (void)disconnect {
    NSLog(@"disconnect");
    [self.items removeAllObjects];
    [self.cv_List reloadData];
    [self updateStatus];
}

//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
//    return true;
//}

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
        _lb_ConnectStatus.text = NSLocalizedString(@"Paired", nil);
//        _lb_ConnectStatus.textColor = [UIColor whiteColor];
//        NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
//        _lb_Battery.text = [NSString stringWithFormat:@"%ld%%", nBattery];
//        [_btn_ConnectSetting setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
    } else {
        _lb_DeviceName.text = NSLocalizedString(@"Pair your device", nil);
        _lb_ConnectStatus.text = NSLocalizedString(@"Not Paired", nil);
//        _lb_ConnectStatus.textColor = [UIColor colorWithHexString:@"afafaf"];
        _lb_Battery.text = @"-";
//        [_btn_ConnectSetting setTitle:NSLocalizedString(@"Setting", nil) forState:UIControlStateNormal];
        [_btn_TotalPills setTitle:@"-" forState:UIControlStateNormal];
        [_btn_ToDayPills setTitle:@"-" forState:UIControlStateNormal];
    }
}

- (void)updateInfo:(dispenser_manuf_data_t *)md {
    if( md != nil ) {
        [self updateCountLabel:md->count];
    }
}

- (void)updateCountLabel:(NSInteger)count {
    [_btn_TotalPills setTitle:[NSString stringWithFormat:@"%ld%@", count, NSLocalizedString(@"", nil)] forState:UIControlStateNormal];
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
            
            NSDictionary *dic_FWInfo = resulte[@"firmware_update_info"];
            NSString *str_NewFWVersion = dic_FWInfo[@"firmware_version"];
            NSLog(@"firmware_version : %@", str_NewFWVersion);
            if( str_NewFWVersion.length > 0 ) {
                //펌웨어 최신 버전 저장
                [[NSUserDefaults standardUserDefaults] setObject:str_NewFWVersion forKey:@"NewFWVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }

            
            
//            //펌웨어 다운로드 링크
//            //http://15.164.79.24/downloads/firmware/dfu/firmware/version/0401.zip
//            NSDictionary *dic_FWInfo = resulte[@"firmware_update_info"];
//            NSString *str_NewFWVersion = dic_FWInfo[@"firmware_version"];
//            NSLog(@"firmware_version : %@", str_NewFWVersion);
//
////            NSString *str_MyFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"];
//            NSString *str_MyFWVersion = @"0400";
//            if( (str_MyFWVersion != nil && str_NewFWVersion != nil) && ([str_NewFWVersion integerValue] > [str_MyFWVersion integerValue]) ) {
//                //파일이 존재하는지 체크
//                NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//                if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
//                    //파일 존재하면 업데이트
//                    NSLog(@"펌웨어 파일 존재함");
//                } else {
//                    //파일이 없는 경우 다운로드
//                    [Util firmWareDownload:str_NewFWVersion];
//                    NSLog(@"펌웨어 파일 다운받음");
//                }
//                [[NSUserDefaults standardUserDefaults] setObject:str_NewFWVersion forKey:@"NewFWVersion"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }

            NSString *str_Warning = resulte[@"warning_medication"];
            if( [str_Warning isEqualToString:@"Y"] ) {
                //푸시 발송
                NSString *str_Caregiver = resulte[@"caregiver_info"];
                [self sendPush:str_Caregiver];
            }
            
            NSArray *ar_Alarm = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];

            NSLog(@"%@", resulte);
            NSDate *lastDate = nil;
            NSInteger todayCnt = 0;
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
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[0];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                                NSString *ampm = @"AM";
                                if( [dic[@"hour"] integerValue] >= 12 ) {
                                    ampm = @"PM";
                                }
                                msg = [NSString stringWithFormat:@"%@ %@%ld:%@ %@",
                                       NSLocalizedString(@"Med alarm time", nil),
                                       ampm,
                                       [dic[@"hour"] integerValue] > 12 ? [dic[@"hour"] integerValue] - 12 : [dic[@"hour"] integerValue],
                                       dic[@"min"],
                                       NSLocalizedString(@"set up", nil)
                                ];
                            }
                        } else if( [type isEqualToString:@"timeset2"] ) {
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[1];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                                NSString *ampm = @"AM";
                                if( [dic[@"hour"] integerValue] >= 12 ) {
                                    ampm = @"PM";
                                }
                                msg = [NSString stringWithFormat:@"%@ %@%ld:%@ %@",
                                       NSLocalizedString(@"Med alarm time", nil),
                                       ampm,
                                       [dic[@"hour"] integerValue] > 12 ? [dic[@"hour"] integerValue] - 12 : [dic[@"hour"] integerValue],
                                       dic[@"min"],
                                       NSLocalizedString(@"set up", nil)
                                ];
                            }
                        } else if( [type isEqualToString:@"timeset3"] ) {
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[2];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                                NSString *ampm = @"AM";
                                if( [dic[@"hour"] integerValue] >= 12 ) {
                                    ampm = @"PM";
                                }
                                msg = [NSString stringWithFormat:@"%@ %@%ld:%@ %@",
                                       NSLocalizedString(@"Med alarm time", nil),
                                       ampm,
                                       [dic[@"hour"] integerValue] > 12 ? [dic[@"hour"] integerValue] - 12 : [dic[@"hour"] integerValue],
                                       dic[@"min"],
                                       NSLocalizedString(@"set up", nil)
                                ];
                            }
                        } else if( [type isEqualToString:@"dose"] ) {
                            msg = NSLocalizedString(@"Med taken", nil);
                            lastDate = date;
                            todayCnt++;
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
                [self.btn_ToDayPills setTitle:[NSString stringWithFormat:@"%ld", todayCnt] forState:0];
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
        self.hud.label.text = NSLocalizedString(@"Pairing your device. Please wait.", nil);
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

//- (void)uartConnectCheck {
//    if( _uartConnect == false ) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.hud hideAnimated:true];
//            self.hud = nil;
//
//            //uartmode 에러 발생시 초기화
//            if( self.currentDevice.peripheral != nil ) {
//                self.services = [NSMutableArray arrayWithObject:[ScanPeripheral uartServiceUUID]];
//
//                NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
//                [self.centralManager scanForPeripheralsWithServices:self.services options:options];
//
//                [self.currentDevice.peripheral discoverServices:@[[ScanPeripheral uartServiceUUID]]];
//            }
//        });
//    }
//}

//- (void)uartMode {
//    if( _centralManager != nil && _currentDevice != nil ) {
//        static BOOL isConnecting = false;
//        if( isConnecting == true ) {
//            return;
//        }
//        isConnecting = true;
//        [NSTimer scheduledTimerWithTimeInterval:1 repeats:false block:^(NSTimer * _Nonnull timer) {
//            isConnecting = false;
//        }];
//
//        NSLog(@"uartMode");
//        if (self.hud == nil) {
//            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        }
//        self.hud.label.text = NSLocalizedString(@"FirmWare Update...", nil);
//
//        _uartConnect = false;
//        [self performSelector:@selector(uartConnectCheck) withObject:nil afterDelay:3.0f];
//
//        DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
//        [deviceManager firmWareUART];
//        [deviceManager setFirmwareUARTCompleteBlock:^(BOOL isSuccess) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.uartConnect = true;
//
//                [self.hud hideAnimated:true];
//                self.hud = nil;
//
//                //UART 설정 완료가 되면 UART 서비스만 감지하던걸 전체 감지로 변경
//                [self.services removeAllObjects];
//
//                NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
//                [self.centralManager scanForPeripheralsWithServices:self.services options:options];
//
//                isConnecting = false;
//            });
//        }];
//    }
//}

//- (void)test1 {
//    NSLog(@"start");
//    NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//    NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"0401" withExtension:@"zip" subdirectory:@"Firmwares/nRF52832"];
////    DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL URLWithString:filePath]];
//    DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
//    DFUServiceInitiator *initiator =[ [DFUServiceInitiator alloc]initWithQueue:dispatch_get_main_queue() delegateQueue:dispatch_get_main_queue() progressQueue:dispatch_get_main_queue() loggerQueue:dispatch_get_main_queue()];
//    initiator = [initiator withFirmware:firmware];
//    initiator.progressDelegate = self;
//    initiator.delegate = self;
//    initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = false;
//    initiator.dataObjectPreparationDelay = 2.0f;
//    DFUServiceController *controller = [initiator startWithTarget:self.dfuTargPeripheral.peripheral];
//
//    //업데이트 완료 후 내부 저장소에 펌웨어 버전도 업데이트
//    [[NSUserDefaults standardUserDefaults] setObject:str_NewFWVersion forKey:@"FWVersion"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//}

//- (void)firmwareUpdate {
//    if( isFWUpdating == true ) { return; }
//    if( _dfuTargPeripheral == nil ) { return; }
//
//    NSLog(@"firmwareUpdate");
//
//    isFWUpdating = true;
//
//    [_dfuTargPeripheral.peripheral discoverServices:@[[ScanPeripheral uartServiceUUID]]];
//
//    DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_dfuTargPeripheral withManager:_centralManager];
//    [deviceManager updateConnect];
//    [deviceManager setFirmwareUARTCompleteBlock:^(BOOL isSuccess) {
//        NSLog(@"setFirmwareUARTCompleteBlock");
//        if( isSuccess ) {
//            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//            NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip", str_NewFWVersion]];
//            DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL fileURLWithPath:filePath]]; //URLWithString 로 했다가 한참 삽질 함
////            NSURL *url = [[NSBundle mainBundle] URLForResource:@"0401" withExtension:@"zip" subdirectory:@"Firmwares/nRF52832"];
////            DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
//
//            DFUServiceInitiator *initiator =[ [DFUServiceInitiator alloc]initWithQueue:dispatch_get_main_queue() delegateQueue:dispatch_get_main_queue() progressQueue:dispatch_get_main_queue() loggerQueue:dispatch_get_main_queue()];
//            initiator = [initiator withFirmware:firmware];
//            initiator.progressDelegate = self;
//            initiator.delegate = self;
//            initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = false;
//            initiator.dataObjectPreparationDelay = 2.0f;
//            [initiator startWithTarget:self.dfuTargPeripheral.peripheral];
//        }
//    }];
//}



#pragma mark - FW Update
- (void)setUARTMode:(void (^)(BOOL isSuccess))completion {
    if( _isExcuteFWUpdateMode == true ) { return; }
    __block NSTimer *tm = [NSTimer scheduledTimerWithTimeInterval:0.1f repeats:true block:^(NSTimer * _Nonnull timer) {
        if( self.centralManager != nil && self.currentDevice != nil && self.isFWUpdating == false ) {
            NSLog(@"uartMode");
//            dispatch_async(dispatch_get_main_queue(), ^{
////                [Util keyWindow].userInteractionEnabled = false;
//            });

            self.isFWUpdating = true;

//            if (self.hud == nil) {
//                self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            }
//            self.hud.label.text = NSLocalizedString(@"Checking FirmWare Update...", nil);
            
//            //3초간 커넥션에 대한 반응이 없는 경우 userInteractionEnabled 취소
//            __block BOOL isCheck = false;
//            [NSTimer scheduledTimerWithTimeInterval:3.0f repeats:false block:^(NSTimer * _Nonnull timer) {
//                if( isCheck == false ) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
////                        [Util keyWindow].userInteractionEnabled = true;
//                    });
//                }
//            }];
//            //////////////////////////////////////////////////////////

            //1. UART 모드 진입
            DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:self.currentDevice withManager:self.centralManager];
            [deviceManager firmWareUART];
            [deviceManager setFirmwareUARTCompleteBlock:^(BOOL isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{

//                    [self.hud hideAnimated:true];
//                    self.hud = nil;

                    //UART 설정 완료가 되면 UART 서비스만 감지하던걸 전체 감지로 변경
                    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
                    [self.centralManager scanForPeripheralsWithServices:@[] options:options];
                    
                    __block NSTimer *uartTm = [NSTimer scheduledTimerWithTimeInterval:0.1f repeats:true block:^(NSTimer * _Nonnull timer) {
                        if( self.dfuTargPeripheral != nil ) {
                            //2. UART 모드로 진입 완료 된 경우
                            NSLog(@"uartTm");
//                            isCheck = true;
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(true);
//                                [self firmwareUpdate];
                            });
                            [uartTm invalidate];
                        }
                    }];
                });
            }];
            [tm invalidate];
        }
    }];
}

- (void)firmwareUpdate {
//    dispatch_async(dispatch_get_main_queue(), ^{
////        [Util keyWindow].userInteractionEnabled = false;
//    });

    [_dfuTargPeripheral.peripheral discoverServices:@[[ScanPeripheral uartServiceUUID]]];
    
//    //3초간 커넥션에 대한 반응이 없는 경우 userInteractionEnabled 취소
//    __block BOOL isCheck = false;
//    [NSTimer scheduledTimerWithTimeInterval:3.0f repeats:false block:^(NSTimer * _Nonnull timer) {
//        if( isCheck == false ) {
//            dispatch_async(dispatch_get_main_queue(), ^{
////                [Util keyWindow].userInteractionEnabled = true;
//            });
//        }
//    }];
//    //////////////////////////////////////////////////////////


    DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_dfuTargPeripheral withManager:_centralManager];
    [deviceManager updateConnect];
    [deviceManager setFirmwareUARTCompleteBlock:^(BOOL isSuccess) {
        NSLog(@"setFirmwareUARTCompleteBlock");
        if( isSuccess ) {
//            isCheck = true;
//            dispatch_async(dispatch_get_main_queue(), ^{
////                [Util keyWindow].userInteractionEnabled = false;
//            });

#ifdef DEBUG //펌웨어 업데이트 테스트 코드
            //파일로 번들에 갖고 있을 경우
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"0603" withExtension:@"zip" subdirectory:@""];
            DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
            NSLog(@"%@", firmware);
#else
            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
            //이건 다운받아서 로컬에 저장한 경우
            NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip", str_NewFWVersion]];
            DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL fileURLWithPath:filePath]]; //URLWithString 로 했다가 한참 삽질 함
#endif

            DFUServiceInitiator *initiator =[ [DFUServiceInitiator alloc]initWithQueue:dispatch_get_main_queue() delegateQueue:dispatch_get_main_queue() progressQueue:dispatch_get_main_queue() loggerQueue:dispatch_get_main_queue()];
            initiator = [initiator withFirmware:firmware];
            initiator.progressDelegate = self;
            initiator.delegate = self;
            initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = false;
            initiator.dataObjectPreparationDelay = 2.0f;
            self.dfuController = [initiator startWithTarget:self.dfuTargPeripheral.peripheral];
        }
    }];
}





- (IBAction)goSync:(id)sender {
//    [Util firmWareDownload:@"0401"];
    [self countSync:@[@(0)]];
}

- (IBAction)goReset:(id)sender {
    [self resetCount];
}

- (IBAction)goTimeSync:(id)sender {
    [self timeSync:^(BOOL isFinish) {
    
    }];
}

- (IBAction)goFWUpdate:(id)sender {
//    if( _centralManager != nil && _currentDevice != nil ) {
//
//        if (self.hud == nil) {
//            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        }
//
//        self.hud.label.text = NSLocalizedString(@"FirmWare Update...", nil);
//        [self.hud showAnimated:true];
//
////        NSData *data = [@"**" dataUsingEncoding:NSUTF8StringEncoding];
////        NSLog(@"%@", data);
//
////        NSArray *peripherals = [_centralManager retrievePeripheralsWithIdentifiers:@[_currentDevice.peripheral.identifier]];
////        if( peripherals.count <= 0 ) {
////            return;
////        }
////        [_centralManager connectPeripheral:peripherals[0] options:nil];
////        CBPeripheral *p = peripherals[0];
////        NSUInteger mtu = [p maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
////
////        NSData *data = [@"**" dataUsingEncoding:NSUTF8StringEncoding];
////        NSLog(@"%@", data);
////        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////        NSLog(@"%@", newStr);
////
//////        NSString *ascii = [NSString stringWithFormat:@"%c%c", @"*", @"*"];
//////        NSLog(@"%@", ascii);
////
////        NSString *str = @"**";
////        NSData* data2 = [NSData dataWithBytes:str.UTF8String length:str.length];
////        NSLog(@"%@", data2);
////
////
////
////        [p writeValue:data2 forCharacteristic:self.currentDevice.tx type:CBCharacteristicWriteWithoutResponse];
//
//
//        DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
//        [deviceManager firmWareUART];
//        [deviceManager setFirmwareUARTCompleteBlock:^(BOOL isSuccess) {
//            dispatch_async(dispatch_get_main_queue(), ^{
////                if( isSuccess ) {
////                    [self.view makeToast:@"리셋 성공"];
////                } else {
////                    [self.view makeToast:@"리셋 실패"];
////                }
//                [self.hud hideAnimated:true];
//                self.hud = nil;
//
//                //UART 설정 완료가 되면 UART 서비스만 감지하던걸 전체 감지로 변경
//                [self.services removeAllObjects];
//                NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
//                [self.centralManager scanForPeripheralsWithServices:self.services options:options];
//
//            });
//        }];
//
//    }
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

- (NDHistory *)makeHistoryData:(NSDate *)date withIdx:(NSInteger)idx {
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDateComponents *comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    
    NDHistory *history = [[NDHistory alloc] init];
    history.year = comp.year;
    history.month = comp.month;
    history.day = comp.day;
    history.hour = comp.hour;
    history.minute = comp.minute;
    history.second = comp.second;
    history.nIdx = idx;
    return history;
}

- (void)reqSync:(NSArray<NDHistory *> *)list {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) {
        [self.hud hideAnimated:true];
        self.hud = nil;
        return;
    }
    if( list.count <= 0 ) {
        [self.hud hideAnimated:true];
        self.hud = nil;
        return;
    }
    
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];

    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];

    NSMutableString *strM_Count = [NSMutableString stringWithString:@"["];
    NSMutableString *strM_Time = [NSMutableString stringWithString:@"["];
    for( NDHistory *history in list ) {
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

    if( [strM_Time isEqualToString:@"[]"] ) {
        [self.hud hideAnimated:true];
        self.hud = nil;
        return;
    }

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

//        [self.vc_Medication reloadList];
        [self updateMedicationList];
    }];
}

- (void)countSync:(NSArray *)ar {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) {
        return;
    }

    if( _centralManager != nil && _currentDevice != nil && ar.count > 0 ) {
        if (self.hud == nil) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        } else {
            [self.hud hideAnimated:true];
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
            
            [self reqSync:result];
        }];
    }
}

- (void)timeSync:(void (^)(BOOL))block {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) { return; }

    if( _centralManager != nil && _currentDevice != nil ) {
        if (self.hud == nil) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        } else {
            [self.hud hideAnimated:true];
        }
        self.hud.label.text = NSLocalizedString(@"Setting the time...", nil);
        [self.hud showAnimated:true];
 
        DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
        [deviceManager setTime];
        [deviceManager setTimeSyncCompleteBlock:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:true];
                self.hud = nil;
                block(true);
            });
        }];
    }
}

- (void)onTiltCheck:(NSData *)manufData {
    dispenser_tilt_data_t_v2 *md_tilt = (dispenser_tilt_data_t_v2*)manufData.bytes;

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

- (void)FWReset {
    if( _dfuController ) {
        BOOL isStoped = [_dfuController abort];
        NSLog(@"%d", isStoped);
    }
    
    _isFWUpdating = false;
    _dfuTargPeripheral = nil;

//    [_centralManager cancelPeripheralConnection:_dfuTargPeripheral.peripheral];
//    _dfuTargPeripheral.peripheral.delegate = nil;

    _services = [NSMutableArray arrayWithObject:[ScanPeripheral uartServiceUUID]];
    
//    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
//    [_centralManager scanForPeripheralsWithServices:_services options:options];
    
    [_currentDevice.peripheral discoverServices:@[[ScanPeripheral uartServiceUUID]]];
    
//    _dfuTargPeripheral = nil;
//    _isFWUpdating = false;
    _isExcuteFWUpdateMode = false;
    _dfuController = nil;
    
    [_currentDevice findService];
}

- (void)startFWUpdate {
    __weak typeof(self) weakSelf = self;
    self.vc_FWUpdate = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FWUpdateViewController"];
    self.vc_FWUpdate.isInitMode = true;
    [self.vc_FWUpdate setStartFirmwareUpdate:^{
        [weakSelf firmwareUpdate];
        NSLog(@"firmware update start");
    }];
    [self.vc_FWUpdate setPauseFirmwareUpdate:^{
        [weakSelf.dfuController pause];
        NSLog(@"firmware update pause");
    }];
    [self.vc_FWUpdate setResumeFirmwareUpdate:^{
        [weakSelf.dfuController resume];
        NSLog(@"firmware update resume");
    }];
    [self.vc_FWUpdate setCancelFirmwareUpdate:^{
        BOOL isStop = [weakSelf.dfuController abort];
        [weakSelf FWReset];
        NSLog(@"firmware update cancel : %d", isStop);
    }];
    [self.vc_FWUpdate setCloseFirmwareUpdate:^{
        [weakSelf FWReset];
        NSLog(@"firmware update close");
    }];
    [self.vc_FWUpdate setFinishFirmwareUpdate:^{
        NSLog(@"firmware update success");
    }];
    [self presentViewController:self.vc_FWUpdate animated:true completion:nil];

}

- (IBAction)goShowFWStatus:(id)sender {
    if( IS_CONNECTED ) {
        
#ifdef DEBUG //펌웨어 업데이트 테스트 코드
        [[NSUserDefaults standardUserDefaults] setObject:@"0401" forKey:@"FWVersion"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0603" forKey:@"NewFWVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
#endif

        
        
        
        __weak typeof(self) weakSelf = self;

        FrimwareCheckPopupViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FrimwareCheckPopupViewController"];
        [vc setFirmwareUpdate:^{
            __block FWConnectingPopUpViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FWConnectingPopUpViewController"];
            [weakSelf presentViewController:vc animated:true completion:nil];
            [weakSelf setUARTMode:^(BOOL isSuccess) {
                [vc dismissViewControllerAnimated:true completion:nil];
                
#ifdef DEBUG //펌웨어 업데이트 테스트 코드
                [weakSelf startFWUpdate];
#else
                NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
                NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
                if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] == false ) {
                    //파일이 없는 경우 다운로드
                    FWDownloadPopUpViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FWDownloadPopUpViewController"];
                    [weakSelf presentViewController:vc animated:true completion:nil];
                    [Util firmWareDownload:str_NewFWVersion withCompletion:^(BOOL isSuccess) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [vc dismissViewControllerAnimated:true completion:^{
                                [weakSelf startFWUpdate];
                            }];
                        });
                    }];
                } else {
                    [weakSelf startFWUpdate];
                }
#endif
            }];
            
//            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//            NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//            if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] == false ) {
//                //파일이 없는 경우 다운로드
//                [Util firmWareDownload:str_NewFWVersion];
//            }
//
//            [self setUARTMode];
        }];
        [self presentViewController:vc animated:true completion:nil];
    } else {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchDeviceViewController"];
        [self.navigationController pushViewController:vc animated:true];
    }
}

- (void)sendTiltData:(NSData *)manufData idx:(NSInteger)idx {
    dispenser_tilt_data_t_v2 *md_tilt = (dispenser_tilt_data_t_v2*)manufData.bytes;
    
//    if( kCryptoMode ) {
//        md_tilt = (dispenser_tilt_data_t_v2 *)[self decrypt:[manufData mutableCopy]];
//    }
    
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];
//    int ir = 0;
//    switch (idx) {
//        case 0:
//            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime1)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//            ir = md_tilt->info_ir1;
//            break;
//        case 1:
//            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime2)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//            ir = md_tilt->info_ir2;
//            break;
//        case 2:
//            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime3)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//            ir = md_tilt->info_ir3;
//            break;
//        default:
//            break;
//    }
    
    NSString *str_BodyDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->reserved)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

//    NSString *str_StatusInfo = [NSString stringWithFormat:@"%@,%@,%@", @(md_tilt->info_identifier[0]),@(md_tilt->info_identifier[1]),@(md_tilt->info_identifier[2])];
    
    
    NSString *str_DoseDate = @"";
    NSString *str_StatusInfo = @"";
    switch (idx) {
        case 0:
            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime1)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            str_StatusInfo = [NSString stringWithFormat:@"%@", @(md_tilt->info_identifier[0])];
            break;
        case 1:
            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime2)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            str_StatusInfo = [NSString stringWithFormat:@"%@", @(md_tilt->info_identifier[1])];
            break;
        case 2:
            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime3)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            str_StatusInfo = [NSString stringWithFormat:@"%@", @(md_tilt->info_identifier[2])];
            break;
    }
//    NSLog(@"%@", str_StatusInfo);
//    NSArray *ar_StatusInfo = @[@(md_tilt->info_identifier[0]), @(md_tilt->info_identifier[1]), @(md_tilt->info_identifier[2])];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@(md_tilt->info_count) forKey:@"information_idx"];   //디바이스 정보 인덱스
//    [dicM_Params setObject:@(self->count) forKey:@"dose_count"];                //토출갯수
    [dicM_Params setObject:str_StatusInfo forKey:@"status_info"];                     //커맨드 값
//    [dicM_Params setObject:@(ir) forKey:@"ir_value"];                           //기울기 값
    [dicM_Params setObject:deviceName forKey:@"device_id"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nBattery] forKey:@"device_battery"];
    [dicM_Params setObject:str_DoseDate forKey:@"datetime"];
    [dicM_Params setObject:str_NowDate forKey:@"datetime_realtime"];
    [dicM_Params setObject:@(md_tilt->body_identifier) forKey:@"body_info"];
    [dicM_Params setObject:str_BodyDate forKey:@"datetime_body"];

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

//- (void)uartFlagDelay {
//    _startUART = false;
//}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if( central.state == CBManagerStatePoweredOn ) {
        NSLog(@"centralManagerDidUpdateState");
        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
        [_centralManager scanForPeripheralsWithServices:_services options:options];
    }
}

//1

- (Byte *)decrypt:(NSData *)manufData {
    //암호화 적용 된 펌웨어의 경우 복호화 처리 기능
    uint8_t xor_val[27] = {
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99 , 0xaa,
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99 , 0xaa,
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
    };
    
    int8_t revert_rotate_val[27] = {
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        -2, -2, -2, -2, -2, -2, -2
    };
                
    Byte *data = (Byte*)[manufData bytes];
    for( int j = 2; j < manufData.length; j++ ) {
        if( revert_rotate_val[j-2] < 0 ) {        // rotate left
            data[j] = (Byte)( (data[j] << (-revert_rotate_val[j-2])) | ( (Byte)(~((Byte)0x80 >> (8-(-revert_rotate_val[j-2])-1) )) & (Byte)(data[j] >> (8-(-revert_rotate_val[j-2]) )) ) );
            data[j] = (Byte)(data[j] ^ xor_val[j-2]);
        } else if( revert_rotate_val[j-2] > 0 ) {   // rotate right
            data[j] = (Byte)(( (~((Byte)0x80 >> (revert_rotate_val[j-2]-1))) & (Byte)(data[j] >> revert_rotate_val[j-2]) ) | (Byte)(data[j] << (8-revert_rotate_val[j-2])) );
            data[j] = (Byte)(data[j] ^ xor_val[j-2]);
        }
    }
    
    return data;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    __weak typeof(self) weakSelf = self;

//    NSLog(@"RSSI : %@", peripheral.name);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( self.isFWUpdating == true ) {
//            if( [peripheral.name.lowercaseString rangeOfString:@"dfutarg"].location != NSNotFound ) {
            if( [peripheral.name.lowercaseString hasPrefix:@"dfutarg"] ) {
                if( self.dfuTargPeripheral != nil ) {
                    return;
                }
                self.dfuTargPeripheral = [ScanPeripheral initWithPeripheral:peripheral];
            }
            return;
        }

        NSData* manufData = advertisementData[CBAdvertisementDataManufacturerDataKey];
        if( manufData == nil ) {
            return;
        }
        
        dispenser_manuf_data_t* md = (dispenser_manuf_data_t *)manufData.bytes;
        dispenser_tilt_data_t_v2 *md_tilt = (dispenser_tilt_data_t_v2*)manufData.bytes;
        
        if( kCryptoMode ) {
            md = (dispenser_manuf_data_t *)[self decrypt:manufData];
            md_tilt = (dispenser_tilt_data_t_v2 *)[self decrypt:[manufData mutableCopy]];
        }

        
        if (md->company_identifier != (0x4d<<8 | 0x4f)) { return; }
        
        if( IS_CONNECTED == false ) {
            [self.btn_TotalPills setTitle:@"-" forState:UIControlStateNormal];
            [self.btn_ToDayPills setTitle:@"-" forState:UIControlStateNormal];
            return;
        }
        
        if( self.isFirstEvent == true ) {
            self.isFirstEvent = false;
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

        NSString *str_CoverDate_test = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime_cover)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSLog(@"%@", str_CoverDate_test);
        //1665753943
        NSString *currentLastMacAddr = [NSString stringWithFormat:@"%02x", (unsigned int) md->addr[0]];
        NSArray *ar_MacAddr = [macAddr componentsSeparatedByString:@":"];

        
//#ifdef DEBUG
//#else
        //기울기 감지
        if( weakSelf.currentDevice != nil && weakSelf.currentDevice.peripheral == peripheral ) {
            self->count = md->count;
            if( [currentLastMacAddr isEqualToString:[ar_MacAddr lastObject]] == false && self->isTilt == false ) {

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
//                    NSLog(@"md_tilt->body_identifier : %c", md_tilt->body_identifier);
//                    NSLog(@"md_tilt->body_identifier : %@", @(md_tilt->body_identifier));
//                    NSLog(@"md_tilt->body_identifier : %d", md_tilt->body_identifier);
//                    NSLog(@"md_tilt->body_identifier : %@", [NSString stringWithFormat:@"%02x", md_tilt->body_identifier]);
                    self->tiltCnt = md_tilt->info_count;
//                    NSLog(@"count1 : %hu", md_tilt->count);
//                    NSLog(@"count2 : %hu", md->count);
//                    NSLog(@"md_tilt->info_count : %d", md_tilt->info_count);
                    self->isTilt = true;
                    [self performSelector:@selector(onTiltCheck:) withObject:manufData afterDelay:5.0f];
                }
//                NSLog(@"md_tilt->info_count : %d", md_tilt->info_count);
            } else {
//                NSLog(@"b : %@", @(md->bat));
            }
        }
        ////////////////////////////
//#endif

        
        
//        NSLog(@"call macAddr : %@", currentMacAddr);
        //d4:06:41:32:3a:85
        if( current_ble_uuid != nil && current_ble_uuid.length > 0 && [ble_uuid isEqualToString:current_ble_uuid] ) {
//        if( macAddr != nil && macAddr.length > 0 && [currentMacAddr isEqualToString:macAddr] ) {
//        if( macAddr != nil && macAddr.length > 0 && [[peripheral.identifier UUIDString] isEqualToString:macAddr] ) {
            if( weakSelf.currentDevice == nil || weakSelf.currentDevice.peripheral != peripheral ) {
                weakSelf.currentDevice = [ScanPeripheral initWithPeripheral:peripheral];
            }

//            //펌웨어 체크
//            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
////            NSString *str_MyFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"];
//            NSString *str_MyFWVersion = @"0400";
//            if( (str_MyFWVersion != nil && str_NewFWVersion != nil) && ([str_NewFWVersion integerValue] > [str_MyFWVersion integerValue]) ) {
//                //파일이 존재하는지 체크
//                NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//                if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
//                    //파일 존재하면 UART 모드 진입
//                    if( self.startUART == false && self.isUartFinish == false ) {
//                        self.startUART = true;
//                        [self performSelector:@selector(uartFlagDelay) withObject:nil afterDelay:1];
//                        [self uartMode];
//                    }
//                    if( self.isUartFinish == false ) {
//                        return;
//                    }
//                }
//            }

//            NSLog(@"connection macAddr : %@", currentMacAddr);
            self.lb_Battery.text = [NSString stringWithFormat:@"%ld%%", [@(md->bat) integerValue]];
            [[NSUserDefaults standardUserDefaults] setObject:@(md->bat) forKey:@"battery"];
            [[NSUserDefaults standardUserDefaults] synchronize];

//            [weakSelf.vc_Medication updateInfo:md];
//            [weakSelf.vc_Device updateInfo:md];

//            [self updateInfo:md];
            
            
//            NSLog(@"count : %@", @(md->count));
            
            [self.btn_TotalPills setTitle:[NSString stringWithFormat:@"%u%@", md->count, NSLocalizedString(@"", nil)] forState:UIControlStateNormal];

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
                    
                    //펌웨어 업데이트 후 md->count가 0으로 내려올때가 있어 전체 동기화가 됨
                    if( self.isFWUpdating == true || self.isExcuteFWUpdateMode == true) {
                        if( self->current_count <= 0 ) {
                            self->current_count = md->count;
                        }
                    }
                    
                    if( md->count - self->current_count > 1 ) {
                        NSLog(@"자동 동기화 처리 진행");
                        //1개 이상 복약 했을때 동기화 처리
                        [[NSUserDefaults standardUserDefaults] setInteger:md->count forKey:@"count"];
//                        [[NSUserDefaults standardUserDefaults] setDouble:md->epochtime1 forKey:@"lastDoseTime"];
                        [[NSUserDefaults standardUserDefaults] synchronize];

                        if( md->count - self->current_count <= 3 ) {
                            //3개보다 작으면 어도브타이즈먼트 이용하기
                            NSMutableArray<NDHistory *> *ar = [NSMutableArray array];
                            NDHistory *history3 = [self makeHistoryData:[NSDate dateWithTimeIntervalSince1970:(md->epochtime3)] withIdx:md->count - 3];
                            [ar addObject:history3];
                            NDHistory *history2 = [self makeHistoryData:[NSDate dateWithTimeIntervalSince1970:(md->epochtime2)] withIdx:md->count - 2];
                            [ar addObject:history2];
                            NDHistory *history1 = [self makeHistoryData:[NSDate dateWithTimeIntervalSince1970:(md->epochtime1)] withIdx:md->count - 1];
                            [ar addObject:history1];
                            [self reqSync:ar];
                        } else {
                            //동기화 할 데이터 생성
                            NSMutableArray *arM_MissingCount = [NSMutableArray array];
                            NSInteger nOldTemp = self->current_count;
                            if( self->current_count > 1 ) {
                                nOldTemp--;
                            }
                            
                            while (nOldTemp < md->count) {
                                [arM_MissingCount addObject:@(nOldTemp)];
                                nOldTemp++;
                            }
                            [self countSync:arM_MissingCount];
                        }
                        
                        self->current_count = md->count;
                        return;
                    }
                    
                    self->current_count = md->count;

                    NSString *str_SerialNo = [Util convertSerialNo];
                    if( str_SerialNo == nil ) {
                        [self.view makeToast:NSLocalizedString(@"Failed to get serial number.\nPlease reconnect the medicine case.", nil)];
                        return;
                    }
                    
                    if( md->count <= 0 ) {
                        return;
                    }
                    
                    
    //                NSInteger doseCnt = md->count - self->current_count;
                    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];
                    NSString *str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime1)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    NSString *str_CoverDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime_cover)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

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
//                    if( self->current_count == 1 ) {
//                        [dicM_Params setObject:@"0" forKey:@"dose_count"];
//                    } else {
//                        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self->current_count - 1] forKey:@"dose_count"];
//                    }
                    
                    
                    NSInteger doseCount = [@(md->count) integerValue];
                    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", doseCount] forKey:@"dose_count"];
                    
                    
                    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nBattery] forKey:@"device_battery"];
                    [dicM_Params setObject:str_DoseDate forKey:@"datetime"];                  //토출시간
                    [dicM_Params setObject:str_NowDate forKey:@"datetime_realtime"];         //현재시간
                    [dicM_Params setObject:@(md->cover_count) forKey:@"dispenser_top"];
                    [dicM_Params setObject:@(md->body_count) forKey:@"dispenser_bottom"];
                    [dicM_Params setObject:deviceName forKey:@"device_id"];
                    [dicM_Params setObject:macAddr forKey:@"device_mac_address"];
                    [dicM_Params setObject:@"N" forKey:@"mapping_status"];                  //처방내역 연동여부
                    [dicM_Params setObject:@"" forKey:@"mapping_pill_name"];                //처방 약품 이름
                    [dicM_Params setObject:str_SerialNo forKey:@"serial_num"];    //시리얼 넘버
                    [dicM_Params setObject:str_CoverDate forKey:@"datetime_cover"];
                    //SA-07C6
                    
                    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/dose" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                        if( error != nil ) {
                            return;
                        }

                        [self.view makeToast:NSLocalizedString(@"took one medicine", nil)];
                        NSLog(@"약 한 알을 복용 했습니다.");

//                        NSInteger nOldCnt = [[NSUserDefaults standardUserDefaults] integerForKey:@"count"];
//                        NSInteger nOverDoseCnt = md->count - nOldCnt;

                        [[NSUserDefaults standardUserDefaults] setInteger:md->count forKey:@"count"];
//                        [[NSUserDefaults standardUserDefaults] setDouble:md->epochtime1 forKey:@"lastDoseTime"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
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
#ifdef DEBUG
                            [self.view makeToast:@"===== 테스트 메세지 =====\n중복 데이터"];
#endif
                            return;
                        }

                        BOOL isMissing = [resulte[@"missing_cnt"] isEqualToString:@"Y"];
                        if( isMissing ) {
                            NSArray *ar_MissingServerList = resulte[@"missing_idx"];
                            if( ar_MissingServerList.count > 0 ) {
    //                            NSInteger nStartIdx = [[ar_MissingServerList firstObject] integerValue];
                                [self countSync:ar_MissingServerList];
                            }
                        } else {
                            if( [resulte[@"reset_time"] isEqualToString:@"Y"] || isTimeSycing == true ) {
                                [self timeSync:^(BOOL isSuccess) {
                                    
                                }];
                            }
                        }

                        //[self.vc_Medication updateStatus];

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
                        
//                        [weakSelf.vc_Medication addList:md->epochtime1];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DoseNoti" object:nil];
                        [self updateMedicationList];
                    }];
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
//    if( [peripheral.name isEqualToString:@"DfuTarg"] == false ) {
//    if( [peripheral.name.lowercaseString rangeOfString:@"dfutarg"].location == NSNotFound ) {
    if( [peripheral.name.lowercaseString hasPrefix:@"dfutarg"] == false ) {
        [_currentDevice findService];
    } else {
        if( _dfuTargPeripheral != nil ) {
            [_dfuTargPeripheral removeService];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnected..");
//    [self scanForPeripherals:YES];
//    if( [peripheral.name.lowercaseString hasPrefix:@"dfutarg"] ) {
//        if( self.hud != nil ) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.hud hideAnimated:true];
//                self.hud = nil;
//            });
//        }
//    }
    
    if( _centralManager.state != CBManagerStatePoweredOn ) {
        return;
    }
    
    self.isFWUpdating = false;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
////        [Util keyWindow].userInteractionEnabled = true;
//    });
    
    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
    [_centralManager scanForPeripheralsWithServices:_services options:options];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    self.isFWUpdating = false;
//    dispatch_async(dispatch_get_main_queue(), ^{
////        [Util keyWindow].userInteractionEnabled = true;
//    });
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
 
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ListCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCVCell" forIndexPath:indexPath];
    if( _items == nil || _items.count <= 0 ) {
        return cell;
    }

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
    [dateFormatter setDateFormat:@"a hh:mm:ss"];

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


#pragma mark - DFUProgressDelegate
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message {
    NSLog(@"%@", message);
    self.isFWUpdating = false;
    self.dfuController = nil;
}

- (void)dfuStateDidChangeTo:(enum DFUState)state {
    NSLog(@"status : %ld", state);
    if( state == 1 ) {
        //업데이트 시작
        self.isExcuteFWUpdateMode = true;
//        dispatch_async(dispatch_get_main_queue(), ^{
////            [Util keyWindow].userInteractionEnabled = false;
//        });

        self.isFWUpdating = true;

//        if (self.hud == nil) {
//            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        } else {
//            [self.hud hideAnimated:true];
//        }
        
//        self.hud.label.text = NSLocalizedString(@"FirmWare Update...", nil);
//        [self.hud showAnimated:true];
    }
    if( state == 6 ) {
        //완료 된 경우
        if( _currentDevice.peripheral != nil ) {
            _dfuTargPeripheral = nil;
            _services = [NSMutableArray arrayWithObject:[ScanPeripheral uartServiceUUID]];

            NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
            [_centralManager scanForPeripheralsWithServices:_services options:options];
            
            [_currentDevice.peripheral discoverServices:@[[ScanPeripheral uartServiceUUID]]];
            
            //업데이트 완료 후 내부 저장소에 펌웨어 버전도 업데이트
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            NSString *now = [dateFormatter stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setValue:now forKey:@"FWUpdateDate"];

            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
            [[NSUserDefaults standardUserDefaults] setObject:str_NewFWVersion forKey:@"FWVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //업데이트 후 타임싱크
            [self timeSync:^(BOOL isFinish) {
                if( isFinish ) {
                    NSLog(@"타임 싱크 완료");
                }
            }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
//            if( self.hud != nil ) {
//                [self.hud hideAnimated:true];
//                self.hud = nil;
//            }
            
            [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:false block:^(NSTimer * _Nonnull timer) {
                self.isFWUpdating = false;
                self.isExcuteFWUpdateMode = false;
//                [Util keyWindow].userInteractionEnabled = true;
                NSLog(@"펌웨어 업데이트 완료");
                self.dfuController = nil;
                [self.vc_FWUpdate updateFinish];
            }];
        });
    } else if( state == 7 || state == 5 ) {
        _isFWUpdating = false;
        _dfuTargPeripheral = nil;
    }
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
//    if( self.hud != nil ) {
//        NSString *msg = [NSString stringWithFormat:@"%@ %ld%%", NSLocalizedString(@"FirmWare Update...", nil), progress];
//        self.hud.label.text = msg;
//    }
    
    [self.vc_FWUpdate updatePer:progress];
}

- (void)updateFocusIfNeeded {
    NSLog(@"updateFocusIfNeeded");
}



@end
