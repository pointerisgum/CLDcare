//
//  HomeMainViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/14.
//

#import "HomeMainViewController.h"
#import <Corebluetooth/CoreBluetooth.h>
//#import "ScanPeripheral.h"
#import "Device.h"
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
#import "SeparatViewController.h"
#import "MediSetUpViewController.h"
#import "MDMediSetUpData.h"
#import "MediRecordCell.h"
#import "DeviceInfoViewController.h"
#import "ResetPopUpViewController.h"
@import UserNotifications;

static BOOL isFWUpdating = false;
static BOOL isPairing = false;

@interface HomeMainViewController () <CBCentralManagerDelegate, ScanPeripheralDelegate, DFUProgressDelegate, DFUServiceDelegate> {
    int tiltCnt;
    bool isTilt;
    int count;
    
    NSInteger         current_count;
    NSData*           deviceMac;
    NSString*         deviceName;
}
//@property (weak, nonatomic) IBOutlet UIScrollView *sv_MainMedi;
//@property (weak, nonatomic) IBOutlet UIScrollView *sv_MainDevice;
@property (weak, nonatomic) IBOutlet UIStackView *stv_MainMedi;
@property (weak, nonatomic) IBOutlet UIStackView *stv_MainDevice;


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

@property (weak, nonatomic) IBOutlet UIView *v_ScheduleBg;
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

//@property (weak, nonatomic) IBOutlet UILabel *lb_ToDayPillsFix;

@property (nonatomic, assign) BOOL isFWUpdating;            //FW업데이트중인지
@property (nonatomic, assign) BOOL isExcuteFWUpdateMode;    //FW업데이트를 실행 했었는지

@property (nonatomic, strong) DFUServiceController *dfuController;
@property (nonatomic, strong) FWUpdateViewController *vc_FWUpdate;
//@property (nonatomic, assign) BOOL isCanSeparation;

@property (weak, nonatomic) IBOutlet UIButton *btn_MainMedi;
@property (weak, nonatomic) IBOutlet UIButton *btn_MainDevice;
@property (weak, nonatomic) IBOutlet UITableView *tbv_MediRecord;
@property (weak, nonatomic) IBOutlet UITableView *tbv_DeviceRecord;
@property (weak, nonatomic) IBOutlet UITableView *tbv_MediSchedule;
@property (weak, nonatomic) IBOutlet UILabel *lb_BottleInCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_BarLeading;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_MediRecordHeight;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_DeviceRecordHeight;

@property (strong, nonatomic) NSMutableArray *arM_MediRecordList;
@property (strong, nonatomic) NSMutableArray *arM_DeviceRecordList;

@property (strong, nonatomic) NSMutableArray *arM_BottleAtt;
@property (strong, nonatomic) NSMutableArray *arm_Alarm;

@property (weak, nonatomic) IBOutlet UICollectionView *cv_Device;
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceStatus;
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceStatusSub;
@property (nonatomic, assign) NSInteger oldBodyCnt;
@property (nonatomic, assign) BOOL isSeparatShow;
@property (nonatomic, assign) BOOL fwCheck;
@property (nonatomic, assign) BOOL isCoverOpen;
@property (nonatomic, assign) BOOL isBodyOpen;
@property (weak, nonatomic) IBOutlet UIStackView *stv_Test;
@property (weak, nonatomic) IBOutlet UIView *v_ListBorder;
@property (weak, nonatomic) IBOutlet UIView *v_DeviceBorder;
@end

@implementation HomeMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.v_ListBorder.layer.cornerRadius = 8;
    self.v_ListBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.v_ListBorder.layer.borderWidth = 1;
    
    self.v_DeviceBorder.layer.cornerRadius = 8;
    self.v_DeviceBorder.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.v_DeviceBorder.layer.borderWidth = 1;

#if DEBUG
    self.stv_Test.hidden = false;
#endif
    
    self.fwCheck = true;
    self.oldBodyCnt = -1;
    
    self.stv_MainMedi.hidden = false;
    self.stv_MainDevice.hidden = true;
    
    _arM_MediRecordList = [NSMutableArray array];
    _arM_DeviceRecordList = [NSMutableArray array];
    _arM_BottleAtt = [NSMutableArray array];
    
//    self.isCanSeparation = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect) name:@"DisConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediSetUpFinish:) name:@"MediSetUpFinish" object:nil];

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

//    _lb_MedicationFix.text = NSLocalizedString(@"Your Med", nil);
//    [_lb_MedicationYnFix setTitle:NSLocalizedString(@"Med Status", nil) forState:0];
//    [_btn_DrugSeeFix setTitle:NSLocalizedString(@"Drug info", nil) forState:0];
//    [_btn_RemainingTimeFix setTitle:NSLocalizedString(@"Next Med Time", nil) forState:0];
//    _lb_DrugScheduleFix.text = NSLocalizedString(@"Med Tracer", nil);
//    _lb_DeviceNameFix.text = NSLocalizedString(@"Sensor Device", nil);
//
//    [_btn_ConnectStatusFix setTitle:NSLocalizedString(@"Pairing", nil) forState:0];
//    [_btn_BatteryFix setTitle:NSLocalizedString(@"Battery", nil) forState:0];
////    [_btn_DrugCountFix setTitle:NSLocalizedString(@"Pills Taken", nil) forState:0];
//    [_btn_ConnectYnFix setTitle:NSLocalizedString(@"Device connect", nil) forState:0];
//
//    _lb_ToDayPillsFix.text = NSLocalizedString(@"Pills Taken Today", nil);


    
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

    [self goShowMedi:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if( _centralManager.state == CBManagerStatePoweredOn ) {
        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
        [_centralManager scanForPeripheralsWithServices:_services options:options];
    }
    
//    [self showWarningPopUp];
    
    NSLog(@"NewFWVersion : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"]);
    NSLog(@"FWVersion : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"]);
    if( IS_CONNECTED && self.fwCheck == true ) {
        NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
        NSString *str_MyFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"];
        if( [str_NewFWVersion integerValue] > [str_MyFWVersion integerValue] ) {
            self.fwCheck = false;
            FrimwareCheckPopupViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FrimwareCheckPopupViewController"];
            [vc setFirmwareUpdate:^{
                [self fwUpdate];
                //            [self.navigationController popToRootViewControllerAnimated:true];
                //            if( self.updateFw ) {
                //                self.updateFw();
                //            }
            }];
            [self presentViewController:vc animated:true completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Util topRound:_v_ScheduleBg];
    [Util topRound:_v_DeviceBg];

    UpdateStatus updateStatus = [Util checkReqUpdate:self];
    if( updateStatus == Require ) {
        return;
    }
    
    [self.tbv_MediSchedule reloadData];
    
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
    [self updateMedicationList];
    [self updateStatus];
}

- (void)onMediSetUpFinish:(NSNotification *)noti {
    NSString *mac = [[NSUserDefaults standardUserDefaults] stringForKey:@"mac"];
    if( _currentDevice != nil && mac.length > 0 ) {
        BOOL isNew = [noti.object[@"isNew"] boolValue];
        [self authDevive:self->_currentDevice withMacAddr:mac isNew:isNew];
    }
    [self.tbv_MediSchedule reloadData];
}

- (void)authDevive:(ScanPeripheral *)device withMacAddr:(NSString *)macAddr isNew:(BOOL)isNew {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) { return; }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( email.length > 0 ) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [format stringFromDate:[NSDate date]];
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:email forKey:@"mem_email"];
        [dicM_Params setObject:dateString forKey:@"pairing_datetime"];
        [dicM_Params setObject:device.peripheral.name forKey:@"device_id"];
        [dicM_Params setObject:macAddr forKey:@"mac_address"];
        [dicM_Params setObject:[Util convertSerialNo] forKey:@"serial_num"];
        [dicM_Params setObject:@"" forKey:@"fw_num"];

        if( [MDMediSetUpData sharedData].dayTakeCount != nil ) {
            [dicM_Params setObject:[MDMediSetUpData sharedData].dayTakeCount forKey:@"device_medication_per_day"];  //하루 복용 횟수
        }
        if( [MDMediSetUpData sharedData].totalCount != nil ) {
            [dicM_Params setObject:[MDMediSetUpData sharedData].totalCount forKey:@"bottle_pill_count"];    //약통의 알약 갯수
        }
        if( [MDMediSetUpData sharedData].take1Count != nil ) {
            [dicM_Params setObject:[MDMediSetUpData sharedData].take1Count forKey:@"each_dose"];    //1회 복용시 먹는 양
        }
        if( [MDMediSetUpData sharedData].isEveryDay != nil ) {
            [dicM_Params setObject:[[MDMediSetUpData sharedData].isEveryDay isEqualToString:NSLocalizedString(@"Yes", nil)] ? @"Y" : @"N" forKey:@"medication_regularly"];  //매일 복용 하는지
        }

        [dicM_Params setObject:[Util getDateString:[NSDate date] withTimeZone:nil] forKey:@"datetime"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"auth/device" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
                [self.view makeToastCenter:NSLocalizedString(@"An error occurred during device registration", nil)];
                return;
            }

//            [[MDMediSetUpData sharedData] reset];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"C" forKey:@"pair"];
            [[NSUserDefaults standardUserDefaults] setObject:macAddr forKey:@"mac"];
            [[NSUserDefaults standardUserDefaults] setObject:[device.peripheral.identifier UUIDString] forKey:@"ble_uuid"];
            [[NSUserDefaults standardUserDefaults] setObject:device.peripheral.name forKey:@"name"];

//            //새로운 약통일 경우 약통 카운트 초기화를 위해 오버 카운트로 등록해 줌
//            NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
//            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
//            NSString *key = [NSString stringWithFormat:@"total_%@_%@", email, deviceName];
//            NSString *key2 = [NSString stringWithFormat:@"nowCount_%@_%@", email, deviceName];
//            NSInteger nNowCnt = [[[NSUserDefaults standardUserDefaults] objectForKey:key2] integerValue];
//            [[NSUserDefaults standardUserDefaults] setObject:@(nNowCnt) forKey:key];
//            [[NSUserDefaults standardUserDefaults] synchronize];

//            if( isNew ) {
//                if( self.centralManager != nil && self.currentDevice != nil ) {
//                    if (self.hud == nil) {
//                        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                    }
//                    self.hud.label.text = NSLocalizedString(@"Setting the time...", nil);
//                    [self.hud showAnimated:true];
//
//                    DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:self.currentDevice withManager:self.centralManager];
//                    [deviceManager setTime];
//                    [deviceManager setTimeSyncCompleteBlock:^(BOOL isSuccess) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.hud hideAnimated:true];
//                            self.hud = nil;
//
//                            [[NSUserDefaults standardUserDefaults] setObject:macAddr forKey:@"mac"];
//                            [[NSUserDefaults standardUserDefaults] setObject:[device.peripheral.identifier UUIDString] forKey:@"ble_uuid"];
//                            [[NSUserDefaults standardUserDefaults] setObject:device.peripheral.name forKey:@"name"];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//                        });
//                    }];
//                }
//            }
        }];
    }
}

//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
//    return true;
//}

- (void)applicationDidEnterForeground:(NSNotification *)notification {
    [self updateData];
}

- (void)updateData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.M.d"];
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
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *key = [NSString stringWithFormat:@"total_%@_%@", email, deviceName];
    NSInteger overCnt = [[[NSUserDefaults standardUserDefaults] objectForKey:key] integerValue];
    if( count - overCnt <= 0 ) {
        [_btn_TotalPills setTitle:[NSString stringWithFormat:@"0%@", NSLocalizedString(@"", nil)] forState:UIControlStateNormal];
    } else {
        [_btn_TotalPills setTitle:[NSString stringWithFormat:@"%ld%@", count - overCnt, NSLocalizedString(@"", nil)] forState:UIControlStateNormal];
    }
    
    
    
    //약통안에 들어 있는 약의 갯수
    NSInteger nPillBottleCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PillInBottleCount"] integerValue];
    if( nPillBottleCount < count - overCnt ) {
        _lb_BottleInCount.text = [NSString stringWithFormat:@"%@ 0", NSLocalizedString(@"Pills in Bottle", nil)];
    } else {
        _lb_BottleInCount.text = [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Pills in Bottle", nil), nPillBottleCount - (count - overCnt)];
    }
}

- (void)updateMedicationList {
    [self.items removeAllObjects];
    [self.arM_BottleAtt removeAllObjects];
    [self.arM_MediRecordList removeAllObjects];
    [self.arM_DeviceRecordList removeAllObjects];
    
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( deviceName.length > 0 && email.length > 0 ) {
//    if( IS_CONNECTED ) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSString *dateString = [format stringFromDate:[NSDate date]];

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:email forKey:@"mem_email"];
//        [dicM_Params setObject:dateString forKey:@"pairing_datetime"];
        [dicM_Params setObject:deviceName forKey:@"device_id"];

        [dicM_Params setObject:[Device getModelName] forKey:@"phone_model"];
        [dicM_Params setObject:@"apple" forKey:@"phone_brand"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/select/caregiverinfo" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
//                [Util showAlert:NSLocalizedString(@"Invalid ID or password", nil) withVc:self];
                return;
            }
            
            if( msgCode == NO_INFORMATION ) {
                //해당정보 없을 시
                [self.cv_List reloadData];
                return;
            }
            
//            NSDictionary *dic_FWInfo = resulte[@"firmware_update_info"];
            id tmp = resulte[@"firmware_update_info"];
            if( [tmp isKindOfClass:[NSDictionary class]] ) {
                NSDictionary *dic_FWInfo = resulte[@"firmware_update_info"];
                NSString *str_NewFWVersion = dic_FWInfo[@"firmware_version"];
                NSLog(@"firmware_version : %@", str_NewFWVersion);
                if( str_NewFWVersion.length > 0 ) {
                    //펌웨어 최신 버전 저장
                    [[NSUserDefaults standardUserDefaults] setObject:str_NewFWVersion forKey:@"NewFWVersion"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
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
                if( [str_Caregiver isKindOfClass:[NSNull class]] == false ) {
                    if( ([str_Caregiver isEqualToString:@"<null>"] == false) && ([str_Caregiver isEqualToString:@""] == false) ) {
                        [self sendPush:str_Caregiver];
                    }
                }
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
                            msg = NSLocalizedString(@"Pill taken", nil);
                        } else if( [type isEqualToString:@"timeset1"] ) {
                            continue;
//                            if( ar_Alarm.count == 3 ) {
//                                NSDictionary *dic = ar_Alarm[0];
//                                if( [dic boolForKey:@"on"] != true ) {
//                                    continue;
//                                }
//                                NSString *ampm = @"AM";
//                                if( [dic[@"hour"] integerValue] >= 12 ) {
//                                    ampm = @"PM";
//                                }
//                                msg = [NSString stringWithFormat:@"%@ %@%ld:%@ %@",
//                                       NSLocalizedString(@"Med alarm time", nil),
//                                       ampm,
//                                       [dic[@"hour"] integerValue] > 12 ? [dic[@"hour"] integerValue] - 12 : [dic[@"hour"] integerValue],
//                                       dic[@"min"],
//                                       NSLocalizedString(@"set up", nil)
//                                ];
//                            }
                        } else if( [type isEqualToString:@"timeset2"] ) {
                            continue;
//                            if( ar_Alarm.count == 3 ) {
//                                NSDictionary *dic = ar_Alarm[1];
//                                if( [dic boolForKey:@"on"] != true ) {
//                                    continue;
//                                }
//                                NSString *ampm = @"AM";
//                                if( [dic[@"hour"] integerValue] >= 12 ) {
//                                    ampm = @"PM";
//                                }
//                                msg = [NSString stringWithFormat:@"%@ %@%ld:%@ %@",
//                                       NSLocalizedString(@"Med alarm time", nil),
//                                       ampm,
//                                       [dic[@"hour"] integerValue] > 12 ? [dic[@"hour"] integerValue] - 12 : [dic[@"hour"] integerValue],
//                                       dic[@"min"],
//                                       NSLocalizedString(@"set up", nil)
//                                ];
//                            }
                        } else if( [type isEqualToString:@"timeset3"] ) {
                            continue;
//                            if( ar_Alarm.count == 3 ) {
//                                NSDictionary *dic = ar_Alarm[2];
//                                if( [dic boolForKey:@"on"] != true ) {
//                                    continue;
//                                }
//                                NSString *ampm = @"AM";
//                                if( [dic[@"hour"] integerValue] >= 12 ) {
//                                    ampm = @"PM";
//                                }
//                                msg = [NSString stringWithFormat:@"%@ %@%ld:%@ %@",
//                                       NSLocalizedString(@"Med alarm time", nil),
//                                       ampm,
//                                       [dic[@"hour"] integerValue] > 12 ? [dic[@"hour"] integerValue] - 12 : [dic[@"hour"] integerValue],
//                                       dic[@"min"],
//                                       NSLocalizedString(@"set up", nil)
//                                ];
//                            }
                        } else if( [type isEqualToString:@"timeset4"] ) {
                            continue;
                        } else if( [type isEqualToString:@"dose"] ) {
                            msg = NSLocalizedString(@"Pill taken", nil);
                            lastDate = date;
                            todayCnt++;
                            
                            BOOL isDuplicate = false;
                            for( NDMedication *obj in self.items ) {
                                if( obj.time == [date timeIntervalSince1970] ) {
                                    isDuplicate = true;
                                    break;
                                }
                            }
                            
                            if( isDuplicate == false ) {
                                //                            if( code != UNKNOW ) {
                                NDMedication *item = [[NDMedication alloc] initWithTime:[date timeIntervalSince1970] withType:code withMsg:msg];
                                [self.items addObject:item];
                                //                            }
                            } else {
                                NSLog(@"중복");
                            }
                        } else if( [type isEqualToString:@"survey"] ) {
                            msg = NSLocalizedString(@"Completed the survey", nil);
                        } else if( [type isEqualToString:@"confirm"] ) {
                            msg = NSLocalizedString(@"Checked the alarm", nil);
                        } else if( [type isEqualToString:@"snooze"] ) {
                            msg = NSLocalizedString(@"Postponed the alarm", nil);
                        } else if( [type isEqualToString:@"body_open"] ) {
                            [self.arM_BottleAtt addObject:@{@"type":@"open", @"time":sub[0]}];
                            continue;
                        } else if( [type isEqualToString:@"body_close"] ) {
                            [self.arM_BottleAtt addObject:@{@"type":@"close", @"time":sub[0]}];
                            continue;
                        }
                        self.str_ToDayMedication = resulte[@"today_medication"];
                    }
                }
            }

            if( [self.str_ToDayMedication isEqualToString:@"Y"] ) {
                NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
                NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
                NSString *key = [NSString stringWithFormat:@"today_%@_%@", email, deviceName];
                NSDictionary *dic_TodayOver = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                NSString *str_Today = [dateFormatter stringFromDate:[NSDate date]];
                NSInteger nTodayOverCnt = [dic_TodayOver[str_Today] integerValue];
                if( nTodayOverCnt > 0 ) {
                    if( todayCnt > nTodayOverCnt ) {
                        [self.btn_ToDayPills setTitle:[NSString stringWithFormat:@"%ld", todayCnt - nTodayOverCnt] forState:0];
                    } else {
                        [self.btn_ToDayPills setTitle:@"0" forState:0];
                    }
                } else {
                    [self.btn_ToDayPills setTitle:[NSString stringWithFormat:@"%ld", todayCnt] forState:0];
                }
                
                
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
                } else {
                    self.lb_RemainDay.text = @"-";
                    self.lb_RemainDayFix.text = @"-";
                }
            } else {
                self.lb_RemainDayFix.hidden = true;
                self.lb_RemainDay.text = @"-";
            }

            //나의 복약 정보 날짜
            self.lb_StandardTime.text = [NSString stringWithFormat:@"%@ 기준", [format stringFromDate:[NSDate date]]];

            [self.cv_List reloadData];
            [self.cv_Device reloadData];
            
            
            //            self.arM_MediRecordList = resulte[@"medi_record"];
            self.arM_MediRecordList = [NSMutableArray array];// resulte[@"bottle_record"];
            for( NSDictionary *dic in resulte[@"medi_record"] ) {
                NSString *dateString = dic[@"reg_datetime"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//                NSDate *now = [NSDate date];
                NSDate *now = [NSDate dateWithTimeInterval:60.0 sinceDate:[NSDate date]];
                NSDate *date = [dateFormatter dateFromString:dateString];
                NSComparisonResult result = [now compare:date];
                if( result == NSOrderedAscending) {
                    NSLog(@"타임오버 : %@", dateString);
                    NSLog(@"현재시간 : %@", now);
                    continue;
                }
                
                BOOL isDuplicate = false;
                for( NSDictionary *obj in self.arM_MediRecordList ) {
                    if( [obj[@"reg_datetime"] isEqualToString:dateString] ) {
                        isDuplicate = true;
                        break;
                    }
                }
                
                if( isDuplicate == false ) {
                    [self.arM_MediRecordList addObject:dic];
                }
            }
            
//            self.lc_MediRecordHeight.constant = 56 + (self.arM_MediRecordList.count * 44) + 130;
            [self.tbv_MediRecord reloadData];
            [self.view layoutIfNeeded];

            
//            self.arM_DeviceRecordList = resulte[@"bottle_record"];
//            NSMutableSet *keys = [NSMutableSet new];
            self.arM_DeviceRecordList = [NSMutableArray array];// resulte[@"bottle_record"];
            NSArray *ar_Temp = resulte[@"bottle_record"];
            for( NSArray *ar in ar_Temp ) {
                if( ar.count == 2 ) {
                    NSString *dateString = ar[0];
                    NSString *msg = ar[1];
                    if( [msg isEqualToString:@"Bottle attached"] || [msg isEqualToString:@"Bottle detached"] ) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//                        NSDate *now = [NSDate date];
                        NSDate *now = [NSDate dateWithTimeInterval:10.0 sinceDate:[NSDate date]];
                        NSDate *date = [dateFormatter dateFromString:dateString];
                        NSComparisonResult result = [now compare:date];
                        if( result == NSOrderedAscending) {
                            continue;
                        }
                        
                        BOOL isDuplicate = false;
                        
                        for( NSDictionary *obj in self.arM_DeviceRecordList ) {
                            if( [obj[@"date"] isEqualToString:dateString] ) {
                                isDuplicate = true;
                                break;
                            }
                        }
                        
                        if( isDuplicate == false ) {
                            NSDictionary *dic = @{@"date": dateString, @"msg": msg};
                            [self.arM_DeviceRecordList addObject:dic];
                        }
                    }
                }
            }
            
            
            
            
//            for( NSDictionary *dic in ar_Temp ) {
//                NSString *dateString = dic[@"reg_datetime_body"];
//                if( [keys containsObject:dateString] ) {
//                    continue;
//                }
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//                NSDate *now = [NSDate date];
//                NSDate *date = [dateFormatter dateFromString:dateString];
//                NSComparisonResult result = [now compare:date];
//                if( result == NSOrderedAscending) {
//                    continue;
//                }
//
//                BOOL isDuplicate = false;
//                for( NSDictionary *obj in self.arM_DeviceRecordList ) {
//                    if( [obj[@"reg_datetime_body"] isEqualToString:dateString] ) {
//                        isDuplicate = true;
//                        break;
//                    }
//                }
//
//                if( isDuplicate == false ) {
//                    [keys addObject:dateString];
//                    [self.arM_DeviceRecordList addObject:dic];
//                }
//            }


//            self.lc_DeviceRecordHeight.constant = 56 + (self.arM_DeviceRecordList.count * 44) + 130;
            [self.tbv_DeviceRecord reloadData];
            [self.view layoutIfNeeded];

            
//            if( self.items.count > 0 ) {
////                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tbv_List numberOfRowsInSection:0] - 1) inSection:0];
////                [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
//                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//                [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
//            }
        }];
    } else {
        [self.cv_List reloadData];
        [self.cv_Device reloadData];
        [self.tbv_DeviceRecord reloadData];
        [self.tbv_MediRecord reloadData];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.lb_MedicationStatus.text = @"-";
            self.lb_MedicationTime.text = @"";
            self.lb_RemainDay.text = @"-";
            self.lb_RemainDayFix.text = @"";
            self.lb_DeviceStatus.text = @"-";
            self.lb_DeviceStatusSub.text = @"";
        });

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

- (IBAction)goShowMedi:(id)sender {
    self.lc_BarLeading.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];

    [self updateMedicationList];
    
    self.btn_MainMedi.selected = true;
    self.btn_MainDevice.selected = false;

//    self.btn_MainMedi.backgroundColor = [UIColor linkColor];
    [self.btn_MainMedi setTitleColor:[UIColor linkColor] forState:0];
    
//    self.btn_MainDevice.backgroundColor = [UIColor whiteColor];
    [self.btn_MainDevice setTitleColor:[UIColor lightGrayColor] forState:0];

    self.stv_MainMedi.hidden = false;
    self.stv_MainDevice.hidden = true;
    
//    self.lc_MediRecordHeight.constant = 56 + (self.arM_MediRecordList.count * 44) + 130;
    [self.tbv_MediRecord reloadData];
    [self.view layoutIfNeeded];
}

- (IBAction)goShowDevice:(id)sender {
    self.lc_BarLeading.constant = self.view.bounds.size.width / 2;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];

    [self updateMedicationList];
    
    self.btn_MainMedi.selected = false;
    self.btn_MainDevice.selected = true;
    
//    self.btn_MainDevice.backgroundColor = [UIColor linkColor];
    [self.btn_MainDevice setTitleColor:[UIColor linkColor] forState:0];
    
//    self.btn_MainMedi.backgroundColor = [UIColor whiteColor];
    [self.btn_MainMedi setTitleColor:[UIColor lightGrayColor] forState:0];
    
    self.stv_MainMedi.hidden = true;
    self.stv_MainDevice.hidden = false;
    
//    self.lc_DeviceRecordHeight.constant = 56 + (self.arM_DeviceRecordList.count * 44) + 130;
    [self.tbv_DeviceRecord reloadData];
    [self.view layoutIfNeeded];
}

- (IBAction)goMediSetup:(id)sender {
    [[MDMediSetUpData sharedData] reset];
    
    UINavigationController *navi = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    MediSetUpViewController *vc = (MediSetUpViewController *)navi.viewControllers.firstObject;
    vc.step = STEP1;
    [vc setMediSetUpFinishBlock:^{
        
    }];
    [self presentViewController:navi animated:true completion:nil];
}

- (void)fwUpdate {
    __weak typeof(self) weakSelf = self;
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
}

- (IBAction)goDeviceInfo:(id)sender {
    if( IS_CONNECTED == false ) {
        return;
    }
    
#ifdef DEBUG //펌웨어 업데이트 테스트 코드
    [[NSUserDefaults standardUserDefaults] setObject:@"0000" forKey:@"FWVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0104" forKey:@"NewFWVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif

    __weak typeof(self) weakSelf = self;
    DeviceInfoViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DeviceInfoViewController"];
    [vc setUpdateFw:^{
        [weakSelf fwUpdate];
    }];
    [self.navigationController pushViewController:vc animated:true];
    return;
    
    
    
    
//#ifdef DEBUG //펌웨어 업데이트 테스트 코드
//    [[NSUserDefaults standardUserDefaults] setObject:@"0401" forKey:@"FWVersion"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"0614" forKey:@"NewFWVersion"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//#endif
//
//
//
//
//    __weak typeof(self) weakSelf = self;
//
//    FrimwareCheckPopupViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FrimwareCheckPopupViewController"];
//    [vc setFirmwareUpdate:^{
//        __block FWConnectingPopUpViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FWConnectingPopUpViewController"];
//        [weakSelf presentViewController:vc animated:true completion:nil];
//        [weakSelf setUARTMode:^(BOOL isSuccess) {
//            [vc dismissViewControllerAnimated:true completion:nil];
//
//#ifdef DEBUG //펌웨어 업데이트 테스트 코드
//            [weakSelf startFWUpdate];
//#else
//            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//            NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//            if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] == false ) {
//                //파일이 없는 경우 다운로드
//                FWDownloadPopUpViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FWDownloadPopUpViewController"];
//                [weakSelf presentViewController:vc animated:true completion:nil];
//                [Util firmWareDownload:str_NewFWVersion withCompletion:^(BOOL isSuccess) {
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [vc dismissViewControllerAnimated:true completion:^{
//                            [weakSelf startFWUpdate];
//                        }];
//                    });
//                }];
//            } else {
//                [weakSelf startFWUpdate];
//            }
//#endif
//        }];
//
//        //            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//        //            NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//        //            if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] == false ) {
//        //                //파일이 없는 경우 다운로드
//        //                [Util firmWareDownload:str_NewFWVersion];
//        //            }
//        //
//        //            [self setUARTMode];
//    }];
//    [self presentViewController:vc animated:true completion:nil];
}

- (IBAction)goTest:(id)sender {
    [[MDMediSetUpData sharedData] reset];
    
    UINavigationController *navi = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    MediSetUpViewController *vc = (MediSetUpViewController *)navi.viewControllers.firstObject;
//    MediSetUpViewController *vc = (MediSetUpViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
    vc.step = STEP1;
    [vc setMediSetUpFinishBlock:^{
        
    }];
    [self presentViewController:navi animated:true completion:nil];
    
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
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"0104" withExtension:@"zip" subdirectory:@""];
            DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
            NSLog(@"%@", firmware);
#else
            NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
            //이건 다운받아서 로컬에 저장한 경우
            NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", str_NewFWVersion]];
//            NSString *filePath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip", str_NewFWVersion]];
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

//- (IBAction)goTest2:(id)sender {
////    ResetPopUpViewController * vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"ResetPopUpViewController"];
////    [self presentViewController:vc animated:true completion:nil];
////    [vc setResetDoneBlock:^{
////        NSString *settingsUrl= @"App-Prefs:root=Bluetooth";
////        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
////                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl] options:@{} completionHandler:^(BOOL success) {
////
////                }];
////        }
////    }];
////    return;
//
//#if DEBUG
//    UIViewController *topController = [Util keyWindow].rootViewController;
//    while (topController.presentedViewController) {
//        topController = topController.presentedViewController;
//    }
//
//    if( [topController isKindOfClass:[SeparatViewController class]] == false ) {
//        NSLog(@"뚜껑 열렸다 닫힘");
//        __weak SeparatViewController *vc_Separat = (SeparatViewController *)[[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"SeparatViewController"];
//        [vc_Separat setSendMsgBlock:^(NSInteger idx, NSInteger cnt) {
//            [vc_Separat dismissViewControllerAnimated:true completion:^{
//                [self sendReport:idx cnt:cnt];
//                [self.view makeToast:NSLocalizedString(@"Thanks for your report.", nil)];
//            }];
//        }];
//        [vc_Separat setShowSetUpBlock:^{
//            [vc_Separat dismissViewControllerAnimated:true completion:^{
//                UINavigationController *navi = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
//                navi.modalPresentationStyle = UIModalPresentationFullScreen;
//                MediSetUpViewController *vc = (MediSetUpViewController *)navi.viewControllers.firstObject;
//                vc.step = STEP1;
//                [self presentViewController:navi animated:true completion:nil];
//            }];
//        }];
//        [self presentViewController:vc_Separat animated:true completion:nil];
//    }
//#endif
//}

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
//    if( IS_CONNECTED ) {
//
//    } else {
//        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchDeviceViewController"];
//        [self.navigationController pushViewController:vc animated:true];
//    }
}

- (IBAction)goConnect:(id)sender {
    if( IS_CONNECTED ) {
        
    } else {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PairingGuide1"];
        [self.navigationController pushViewController:vc animated:true];

//        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchDeviceViewController"];
//        [self.navigationController pushViewController:vc animated:true];
    }
}

- (void)sendTiltData:(NSData *)manufData idx:(NSInteger)idx {
    if( IS_CONNECTED == false ) { return; }
    
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
    
    NSString *str_CoverDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime_cover)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    NSLog(@"str_CoverDate : %@", str_CoverDate);

//    NSString *str_StatusInfo = [NSString stringWithFormat:@"%@,%@,%@", @(md_tilt->info_identifier[0]),@(md_tilt->info_identifier[1]),@(md_tilt->info_identifier[2])];
    
    NSInteger infoCount = [@(md_tilt->info_count) integerValue];
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
            infoCount -= 1;
            break;
        case 2:
            str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md_tilt->epochtime3)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            str_StatusInfo = [NSString stringWithFormat:@"%@", @(md_tilt->info_identifier[2])];
            infoCount -= 2;
            [self updateMedicationList];
            break;
    }
    
    if( infoCount <= 0 ) {
        //이전 데이터가 없는 경우 스킵
        [self updateMedicationList];
        return;
    }
//    NSLog(@"%@", str_StatusInfo);
//    NSArray *ar_StatusInfo = @[@(md_tilt->info_identifier[0]), @(md_tilt->info_identifier[1]), @(md_tilt->info_identifier[2])];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@(infoCount) forKey:@"information_idx"];   //디바이스 정보 인덱스
//    [dicM_Params setObject:@(self->count) forKey:@"dose_count"];                //토출갯수
    [dicM_Params setObject:str_StatusInfo forKey:@"status_info"];                     //커맨드 값
//    [dicM_Params setObject:@(ir) forKey:@"ir_value"];                           //기울기 값
    [dicM_Params setObject:deviceName forKey:@"device_id"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nBattery] forKey:@"device_battery"];
    [dicM_Params setObject:str_DoseDate forKey:@"datetime"];
    [dicM_Params setObject:str_NowDate forKey:@"datetime_realtime"];
    [dicM_Params setObject:@(md_tilt->body_identifier) forKey:@"body_info"];
    [dicM_Params setObject:str_CoverDate forKey:@"datetime_cover"]; //커버가 열린 시간

    NSLog(@"tilt params : %@", dicM_Params);
    
    if( [str_DoseDate hasPrefix:@"2023"] == false ) {
        NSLog(@"str_DoseDate wrong");
    } else if( [str_NowDate hasPrefix:@"2023"] == false ) {
        NSLog(@"str_NowDate wrong");
    } else if( [str_CoverDate hasPrefix:@"2023"] == false ) {
        NSLog(@"str_BodyDate wrong");
    }
    
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

+ (void)showWarningPopUp {
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastDeviceName"];
    if( deviceName.length <= 0 ) { return; }
    
    ResetPopUpViewController * vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"ResetPopUpViewController"];
    UIViewController *topController = [Util keyWindow].rootViewController;
    [topController presentViewController:vc animated:true completion:nil];
    [vc setResetDoneBlock:^{
        NSString *settingsUrl= @"App-Prefs:root=Bluetooth";
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl] options:@{} completionHandler:^(BOOL success) {
                    
                }];
        }
    }];
//    NSString *msg = [NSString stringWithFormat:@"%@\n%@ -> %@ⓘ -> %@\n%@",
//                     NSLocalizedString(@"Pairing failed.", nil),
//                     NSLocalizedString(@"Settings -> Bluetooth", nil),
//                     deviceName,
//                     NSLocalizedString(@"Forget This Device", nil),
//                     NSLocalizedString(@"Do you want to go to Settings?", nil)];
//
//    [UIAlertController showAlertInViewController:self
//                                       withTitle:@""
//                                         message:msg
//                               cancelButtonTitle:NSLocalizedString(@"No", nil)
//                          destructiveButtonTitle:nil
//                               otherButtonTitles:@[NSLocalizedString(@"Yes", nil)]
//                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
//        if( buttonIndex == 2 ) {
//            NSString *settingsUrl= @"App-Prefs:root=Bluetooth";
//            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl] options:@{} completionHandler:^(BOOL success) {
//
//                    }];
//            }
//        }
//    }];
}

- (void)showSeparat {
    UIViewController *topController = [Util keyWindow].rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    if( [topController isKindOfClass:[SeparatViewController class]] == false ) {
        NSLog(@"뚜껑 열렸다 닫힘");
        __weak SeparatViewController *vc_Separat = (SeparatViewController *)[[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"SeparatViewController"];
        [vc_Separat setSendMsgBlock:^(NSInteger idx, NSInteger cnt) {
            [vc_Separat dismissViewControllerAnimated:true completion:^{
                [self sendReport:idx cnt:cnt];
                [self.view makeToast:NSLocalizedString(@"Thanks for your report.", nil)];
            }];
        }];
        [vc_Separat setShowSetUpBlock:^{
            [vc_Separat dismissViewControllerAnimated:true completion:^{
                UINavigationController *navi = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
                navi.modalPresentationStyle = UIModalPresentationFullScreen;
                MediSetUpViewController *vc = (MediSetUpViewController *)navi.viewControllers.firstObject;
                vc.step = STEP1;
                [self presentViewController:navi animated:true completion:nil];
            }];
        }];
        [self presentViewController:vc_Separat animated:true completion:nil];
    }
}
    
- (void)sendStatus:(NSString *)type withData:(dispenser_manuf_data_t *)md {
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSInteger doseCount = [@(md->count) integerValue];
    NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
    NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) {
        str_SerialNo = @"";
    }
    
    NSString *str_DoseDate = @"";
    if( [type isEqualToString:@"cover"] ) {
        str_DoseDate = [Util getDateString:[NSDate date] withTimeZone:nil];
    } else if( [type isEqualToString:@"body"] ) {
        str_DoseDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime_body)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    
    NSInteger nBodyCount = [@(md->body_count) integerValue];
    if( nBodyCount >= 32768 ) {
        nBodyCount -= 32768;
    }
    NSInteger nCoverCount = [@(md->cover_count) integerValue];
    if( nCoverCount >= 32768 ) {
        nCoverCount -= 32768;
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", doseCount] forKey:@"dose_count"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nBattery] forKey:@"device_battery"];
    [dicM_Params setObject:str_DoseDate forKey:@"datetime"];                  //토출시간
    [dicM_Params setObject:@"" forKey:@"datetime_realtime"];         //현재시간
    [dicM_Params setObject:@(nCoverCount) forKey:@"dispenser_top"];     //242
    [dicM_Params setObject:@(nBodyCount) forKey:@"dispenser_bottom"];   //139
    [dicM_Params setObject:deviceName forKey:@"device_id"];
    [dicM_Params setObject:macAddr forKey:@"device_mac_address"];
    [dicM_Params setObject:@"N" forKey:@"mapping_status"];                  //처방내역 연동여부
    [dicM_Params setObject:@"" forKey:@"mapping_pill_name"];                //처방 약품 이름
    [dicM_Params setObject:str_SerialNo forKey:@"serial_num"];    //시리얼 넘버
    [dicM_Params setObject:@"" forKey:@"datetime_body"];         //바디가가 열린 시간
    
    //230215 추가 된 파라미터
    [dicM_Params setObject:@(self.isCoverOpen) forKey:@"cover_status"];      //디바이스 뚜껑 상태 (0 or 1)
    [dicM_Params setObject:@(self.isBodyOpen) forKey:@"body_status"];       //디바이스 몸통 상태 (0 or 1)
    [dicM_Params setObject:type forKey:@"request_type"];      //요청 타입 (cover / body / medication)

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/dose" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        
        NSLog(@"%d", msgCode);
        NSLog(@"%@", resulte);
        [self updateMedicationList];
    }];
}

- (void)setPairStatus:(BOOL)status {
    isPairing = status;
}

+ (BOOL)getPairStatus {
    return isPairing;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if( central.state == CBManagerStatePoweredOn ) {
        NSLog(@"centralManagerDidUpdateState");
        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
        [_centralManager scanForPeripheralsWithServices:_services options:options];
    }
}

//1

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    __weak typeof(self) weakSelf = self;

//    NSLog(@"RSSI : %@", peripheral.name);
    
//    NSLog(@"IS_CONNECTED : %d", IS_CONNECTED);
    
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
            md = (dispenser_manuf_data_t *)[Util decrypt:manufData];
//            md_tilt = (dispenser_tilt_data_t_v2 *)[Util decrypt:[manufData mutableCopy]];
        }

        
        if (md->company_identifier != (0x4d<<8 | 0x4f)) { return; }
        
//        NSLog(@"%@", [NSString stringWithFormat:@"%02x", (unsigned int) md->device_last_name]);
        
        if( md->pairing == 0x01 ) {
            isPairing = true;
        } else {
            isPairing = false;
        }
        

        if( IS_CONNECTED == false ) {
            [self.btn_TotalPills setTitle:@"-" forState:UIControlStateNormal];
            [self.btn_ToDayPills setTitle:@"-" forState:UIControlStateNormal];
            return;
        }
        
        if( md->device_last_name == 0xff && md->pairing == 0xff && md->epochtime_body == 0xffffffff ) {
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

        NSString *str_BodyDate_test = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime_body)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSLog(@"md->epochtime_body : %@", str_BodyDate_test);
        //1665753943
        NSString *currentLastMacAddr = [NSString stringWithFormat:@"%02x", (unsigned int) md->device_last_name];
        NSArray *ar_MacAddr = [macAddr componentsSeparatedByString:@":"];

        if( ar_MacAddr.count > 0 && [currentLastMacAddr isEqualToString:[ar_MacAddr lastObject]] ) {
            [[NSUserDefaults standardUserDefaults] setObject:peripheral.name forKey:@"LastDeviceName"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            if( md->pairing == 0x01 ) {
//                NSLog(@"연결됨");
            } else if( md->pairing == 0x00 ) {
//                NSLog(@"연결끊김");
                if( IS_CONNECTED ) {
                    [Util deleteData];
                    [self disconnect];
                    [HomeMainViewController showWarningPopUp];
                }
            }
        }
        
        NSInteger nBodyCount = [@(md->body_count) integerValue];
        if( nBodyCount >= 32768 ) {
            nBodyCount -= 32768;
        }
        NSInteger nCoverCount = [@(md->cover_count) integerValue];
        if( nCoverCount >= 32768 ) {
            nCoverCount -= 32768;
        }
//        NSLog(@"@(md->cover_count) : %ld", nCoverCount);
        NSLog(@"@(md->body_count) : %ld", nBodyCount);
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
                NSLog(@"기울기 감지");
                if( self->tiltCnt < md_tilt->info_count ) { //43766 < 43550
                    NSLog(@"기울기 데이터 전송 5초전");
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

            BOOL isInitDevice = [[NSUserDefaults standardUserDefaults] boolForKey:@"initDevice"];
            if( isInitDevice == true ) {
                NSLog(@"디바이스 초기화 // md->count : %@", @(md->count));
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"initDevice"];
                
                NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
                NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
                NSString *key = [NSString stringWithFormat:@"total_%@_%@", email, deviceName];
//                NSString *key2 = [NSString stringWithFormat:@"nowCount_%@_%@", email, deviceName];
//                NSInteger nNowCnt = [[[NSUserDefaults standardUserDefaults] objectForKey:key2] integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:@(md->count) forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            //last synced
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd a h:mm"];
            NSString *now = [format stringFromDate:[NSDate date]];
            self.lb_DeviceStatus.text = NSLocalizedString(@"Last Synced", nil);
            self.lb_DeviceStatusSub.text = now;
            
            NSInteger fwVer = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"] integerValue];
            if( fwVer < 103 ) {
                //구버전 대응
                //몸통이 분리 되었다 다시 끼워졌을때 알람 팝업 띄우기
                //md->body_count가 홀수는 체결, 짝수는 분리
                //올드카운트와 현재 body_count가 다르고 홀수인 경우 팝업 노출
                if( self.oldBodyCnt <= 0 ) {
                    self.oldBodyCnt = nBodyCount;
                }
                
                if( [currentLastMacAddr isEqualToString:[ar_MacAddr lastObject]] && nBodyCount % 2 == 1 && self.oldBodyCnt != nBodyCount ) {
                    
                    self.oldBodyCnt = nBodyCount;

                    UIViewController *topController = [Util keyWindow].rootViewController;
                    while (topController.presentedViewController) {
                        topController = topController.presentedViewController;
                    }

                    if( [topController isKindOfClass:[SeparatViewController class]] == false ) {
                        NSLog(@"뚜껑 열렸다 닫힘");
                        __weak SeparatViewController *vc_Separat = (SeparatViewController *)[[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"SeparatViewController"];
                        [vc_Separat setSendMsgBlock:^(NSInteger idx, NSInteger cnt) {
                            [vc_Separat dismissViewControllerAnimated:true completion:^{
                                [self sendReport:idx cnt:cnt];
                                [self.view makeToast:NSLocalizedString(@"Thanks for your report.", nil)];
                            }];
                        }];
                        [vc_Separat setShowSetUpBlock:^{
                            [vc_Separat dismissViewControllerAnimated:true completion:^{
                                UINavigationController *navi = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
                                navi.modalPresentationStyle = UIModalPresentationFullScreen;
                                MediSetUpViewController *vc = (MediSetUpViewController *)navi.viewControllers.firstObject;
                                vc.step = STEP1;
                                [self presentViewController:navi animated:true completion:nil];
                            }];
                        }];
                        [self presentViewController:vc_Separat animated:true completion:nil];
                    }
                }
                
                if( [currentLastMacAddr isEqualToString:[ar_MacAddr lastObject]] ) {
                    self.oldBodyCnt = nBodyCount;
                }
            } else {
                if( [currentLastMacAddr isEqualToString:[ar_MacAddr lastObject]] ) {
                    //몸통이 분리 되었다 다시 끼워졌을때 알람 팝업 띄우기
                    //body_count의 첫번째 bit가 0이면 연결, 1이면 분리
//                    NSLog(@"md->body_count >> 15 : %d", md->body_count >> 15);
//                    if( md->body_count == 0xf ) {
//                        NSLog(@"md->body_count == 0xf");
//                    } else {
//                        NSLog(@"md->body_count != 0xf");
//                    }
//                    NSLog(@"md->cover_count >> 15 : %d", md->cover_count >> 15);

                    NSString *bodyKey = [NSString stringWithFormat:@"%@_%@_OldBodyStatus", email, deviceName];
                    NSString *coverKey = [NSString stringWithFormat:@"%@_%@_OldCoverStatus", email, deviceName];
                    NSString *bodyCountKey = [NSString stringWithFormat:@"%@_%@_OldBodyCount", email, deviceName];
                    NSString *oldBodyOpen = [[NSUserDefaults standardUserDefaults] stringForKey:bodyKey];
                    NSString *oldCoverOpen = [[NSUserDefaults standardUserDefaults] stringForKey:coverKey];
                    NSInteger nOldBodyCount = [[[NSUserDefaults standardUserDefaults] stringForKey:bodyCountKey] integerValue];

                    if( md->body_count >> 15 == 0x00 ) {
                        //연결
//                        NSLog(@"바디 연결됨");
                        self.isBodyOpen = true;
                        if( self.isSeparatShow == true ) {
                            self.isSeparatShow = false;
                            [self showSeparat];
                        }

                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:bodyKey];
                        
                        if( [oldBodyOpen isEqualToString:@"0"] ) {
                            NSLog(@"body connect sendStatus");
                            [self sendStatus:@"body" withData: md];
                            return;
                        }
                        
                        if( (nOldBodyCount > 0) && (nBodyCount > nOldBodyCount) ) {
                            //앱을 끈 상태에서 변화가 있을 경우
                            NSLog(@"앱을 껐을때 변화가 있음");
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", nBodyCount] forKey:bodyCountKey];
                            [self sendStatus:@"body" withData: md];
                            return;
                        }

                    } else {
                        //분리
//                        NSLog(@"바디 분리됨");
                        self.isSeparatShow = true;
                        self.isBodyOpen = false;
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:bodyKey];
                        
                        if( [oldBodyOpen isEqualToString:@"1"] ) {
                            NSLog(@"body disconnect sendStatus");
                            [self sendStatus:@"body" withData: md];
                            return;
                        }
                        
                        if( (nOldBodyCount > 0) && (nBodyCount > nOldBodyCount) ) {
                            //앱을 끈 상태에서 변화가 있을 경우
                            NSLog(@"앱을 껐을때 변화가 있음");
                            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", nBodyCount] forKey:bodyCountKey];
                            [self sendStatus:@"body" withData: md];
                            return;
                        }
                    }
                    
                    if( md->cover_count >> 15 == 0x00 ) {
//                        NSLog(@"캡 열림");
                        self.isCoverOpen = true;
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:coverKey];
                        
                        if( [oldCoverOpen isEqualToString:@"0"] ) {
                            NSLog(@"cover connect sendStatus");
                            [self sendStatus:@"cover" withData: md];
                            return;
                        }

                    } else {
//                        NSLog(@"캡 닫힘");
                        self.isCoverOpen = false;
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:coverKey];
                        
                        if( [oldCoverOpen isEqualToString:@"1"] ) {
                            NSLog(@"cover disconnect sendStatus");
                            [self sendStatus:@"cover" withData: md];
                            return;
                        }
                    }
                }
            }
            
            NSString *bodyCountKey = [NSString stringWithFormat:@"%@_%@_OldBodyCount", email, deviceName];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", nBodyCount] forKey:bodyCountKey];

            
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

            NSString *key = [NSString stringWithFormat:@"nowCount_%@_%@", email, deviceName];
            [[NSUserDefaults standardUserDefaults] setObject:@(md->count) forKey:key];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //            [weakSelf.vc_Medication updateInfo:md];
//            [weakSelf.vc_Device updateInfo:md];

//            [self updateInfo:md];
            
            
//            NSLog(@"count : %@", @(md->count));
            
            [self updateCountLabel:[@(md->count) integerValue]];
//            [self.btn_TotalPills setTitle:[NSString stringWithFormat:@"%u%@", md->count, NSLocalizedString(@"", nil)] forState:UIControlStateNormal];

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
                    NSString *str_BodyDate = [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime_body)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

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
                    [dicM_Params setObject:@(nCoverCount) forKey:@"dispenser_top"];     //242
                    [dicM_Params setObject:@(nBodyCount) forKey:@"dispenser_bottom"];   //139
                    [dicM_Params setObject:deviceName forKey:@"device_id"];
                    [dicM_Params setObject:macAddr forKey:@"device_mac_address"];
                    [dicM_Params setObject:@"N" forKey:@"mapping_status"];                  //처방내역 연동여부
                    [dicM_Params setObject:@"" forKey:@"mapping_pill_name"];                //처방 약품 이름
                    [dicM_Params setObject:str_SerialNo forKey:@"serial_num"];    //시리얼 넘버
                    [dicM_Params setObject:str_BodyDate forKey:@"datetime_body"];         //바디가가 열린 시간
                    //SA-07C6
                    
                    //230215 추가 된 파라미터
                    [dicM_Params setObject:@(self.isCoverOpen) forKey:@"cover_status"];      //디바이스 뚜껑 상태 (0 or 1)
                    [dicM_Params setObject:@(self.isBodyOpen) forKey:@"body_status"];       //디바이스 몸통 상태 (0 or 1)
                    [dicM_Params setObject:@"medication" forKey:@"request_type"];      //요청 타입 (cover / body / medication)

                    
                    
                    if( [currentLastMacAddr isEqualToString:[ar_MacAddr lastObject]] == false ) {
                        NSLog(@"잘못된 정보");
                    }
                    
                    if( [str_DoseDate hasPrefix:@"2023"] == false ) {
                        NSLog(@"str_DoseDate wrong");
                    } else if( [str_NowDate hasPrefix:@"2023"] == false ) {
                        NSLog(@"str_NowDate wrong");
                    }
                    
                    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/update/dose" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                        if( error != nil ) {
                            return;
                        }

                        [self.view makeToast:NSLocalizedString(@"One pill dispensed.", nil)];
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
                                NSLog(@"시간 동기화");
                                [self timeSync:^(BOOL isSuccess) {
                                    
                                }];
                            }
                        }

                        NSLog(@"복약시 현재시간([NSDate date]) : %@", [Util getDateString:[NSDate date] withTimeZone:nil]);
                        NSLog(@"복약시 기록된 시간(epochtime1) : %@", [Util getDateString:[NSDate dateWithTimeIntervalSince1970:(md->epochtime1)] withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]);
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
    
    if( self.btn_MainMedi.selected ) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                     ascending:YES];
        NSArray *sortArray = [_items sortedArrayUsingDescriptors:@[sortDescriptor]];
        _items = [NSMutableArray arrayWithArray:sortArray];
        
        if( _cv_List.bounds.size.width < 130 * _items.count ) {
            _cv_List.contentOffset = CGPointMake((130 * _items.count) - self.view.bounds.size.width + 40, 0);
        }
        return _items.count;
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                 ascending:YES];
    NSArray *sortArray = [_arM_BottleAtt sortedArrayUsingDescriptors:@[sortDescriptor]];
    _arM_BottleAtt = [NSMutableArray arrayWithArray:sortArray];
    
    if( _cv_Device.bounds.size.width < 130 * _arM_BottleAtt.count ) {
        _cv_Device.contentOffset = CGPointMake((130 * _arM_BottleAtt.count) - self.view.bounds.size.width + 40, 0);
    }
    return _arM_BottleAtt.count;
}
 
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ListCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCVCell" forIndexPath:indexPath];
    
    if( self.btn_MainMedi.selected ) {
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
        
        if( _items.count < indexPath.row ) {
            cell.lb_Time.text = @"";
            cell.lb_Msg.text = @"";
            return cell;
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
    
    if( self.arM_BottleAtt.count < indexPath.row ) {
        cell.lb_Time.text = @"";
        cell.lb_Msg.text = @"";
        return cell;
    }
    
    NSDictionary *dic = self.arM_BottleAtt[indexPath.row];
    NSString *type = dic[@"type"];
    if( [type isEqualToString:@"open"] ) {
        cell.lb_Msg.text = NSLocalizedString(@"Bottle detached", nil);
    } else {
        cell.lb_Msg.text = NSLocalizedString(@"Bottle attached", nil);
    }
    
    NSString *regTime = dic[@"time"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [format dateFromString:regTime];
    
    NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
    [format2 setDateFormat:@"a h:mm:ss"];
    [format2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateString = [format2 stringFromDate:date];
    cell.lb_Time.text = dateString;

    [cell setFill:true];

    cell.v_LeftDot.hidden = false;
    cell.v_RightDot.hidden = false;
    
    if( indexPath.row == 0 ) {
        cell.v_LeftDot.hidden = true;
    }
    if( indexPath.row >= self.arM_BottleAtt.count - 1 ) {
        cell.v_RightDot.hidden = true;
    }
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(130, 150);
}


#pragma mark - DFUProgressDelegate
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message {
    NSLog(@"%@", message);
    self.isFWUpdating = false;
    self.dfuController = nil;
    
    [self.vc_FWUpdate dismissViewControllerAnimated:true completion:nil];
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

- (void)sendReport:(NSInteger)idx cnt:(NSInteger)cnt {
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:deviceName forKey:@"device_id"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", idx] forKey:@"report_type"];
    [dicM_Params setObject:str_NowDate forKey:@"datetime"];

    if( idx == 1 ) {
        //여러알이 나온 경우 이므로 pills taken from bottle에서 빼기
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", cnt] forKey:@"pill_count"];
        
        NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        NSString *key = [NSString stringWithFormat:@"total_%@_%@", email, deviceName];
        NSInteger overCnt = [[[NSUserDefaults standardUserDefaults] objectForKey:key] integerValue];
        overCnt += cnt;
        
        [[NSUserDefaults standardUserDefaults] setObject:@(overCnt) forKey:key];
        
        
        //오늘 복약
        key = [NSString stringWithFormat:@"today_%@_%@", email, deviceName];
        NSDictionary *dic_TodayOver = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString *str_Today = [dateFormatter stringFromDate:[NSDate date]];
        NSInteger nTodayOverCnt = [dic_TodayOver[str_Today] integerValue];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{str_Today:@(nTodayOverCnt += cnt)} forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/device/attach/report" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        
        [self updateMedicationList];

        NSLog(@"%@", resulte);
        NSLog(@"%@", error);
        NSLog(@"%d", msgCode);
    }];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( self.btn_MainMedi.selected ) {
        if( tableView == self.tbv_MediSchedule ) {
            self.arm_Alarm = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];
            NSInteger cnt = 0;
            for( NSDictionary *dic in self.arm_Alarm ) {
                if( [dic[@"on"] boolValue] == true ) {
                    cnt++;
                }
            }
            return cnt;
        }
        return _arM_MediRecordList.count;
    }

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                 ascending:false];
    NSArray *sortArray = [_arM_DeviceRecordList sortedArrayUsingDescriptors:@[sortDescriptor]];
    _arM_DeviceRecordList = [NSMutableArray arrayWithArray:sortArray];
    return _arM_DeviceRecordList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediRecordCell* cell = (MediRecordCell*)[tableView dequeueReusableCellWithIdentifier:@"MediRecordCell"];
    
    if( self.btn_MainMedi.selected ) {
        if( tableView == self.tbv_MediSchedule ) {
            if( self.arm_Alarm.count < indexPath.row ) {
                cell.lb_Time.text = @"";
                return cell;
            }
            NSDictionary *dic = self.arm_Alarm[indexPath.row];
            if( [dic[@"on"] boolValue] == true ) {
                NSInteger hour = [dic[@"hour"] integerValue];
                NSInteger min = [dic[@"min"] integerValue];
                NSInteger takeCnt = [dic[@"take1Count"] integerValue];
                NSString *ampm = @"AM";
                if( hour >= 12 ) {
                    ampm = @"PM";
                }
                NSInteger h = hour > 12 ? hour - 12 : hour;
                cell.lb_Time.text = [NSString stringWithFormat:@"%ld %@ at %02ld:%02ld %@", takeCnt, takeCnt > 1 ? @"Pills": @"Pill", h, min, ampm];
            }
            return cell;
        }

        if( _arM_MediRecordList.count < indexPath.row ) {
            cell.lb_Time.text = @"";
            cell.lb_Status.text = @"";
            return cell;
        }

        NSDictionary *dic = _arM_MediRecordList[indexPath.row];
        
        cell.v_TopLine.hidden = false;
        cell.v_BottomLine.hidden = false;
        
        if( indexPath.row == 0 ) {
            cell.v_TopLine.hidden = true;
        }
        if( indexPath.row >= _arM_MediRecordList.count - 1 ) {
            cell.v_BottomLine.hidden = true;
        }
        
        NSString *regTime = dic[@"reg_datetime"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSDate *date = [format dateFromString:regTime];
        
        NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
        [format2 setDateFormat:@"a h:mm:ss   yyyy-MM-dd"];
        [format2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString *dateString = [format2 stringFromDate:date];
        cell.lb_Time.text = dateString;
        
        NSString *status = nil;
        if( [dic[@"mem_action"] isEqualToString:@"dose"] ) {
            status = NSLocalizedString(@"Pill taken", nil);
        } else {
            status = dic[@"mem_action"];
        }
        cell.lb_Status.text = status;
        return cell;
    }
    
    if( _arM_DeviceRecordList.count < indexPath.row ) {
        cell.lb_Time.text = @"";
        cell.lb_Status.text = @"";
        return cell;
    }

    NSDictionary *dic = _arM_DeviceRecordList[indexPath.row];
    /*
     date = "2023-02-15 08:26:07 +0000";
     msg = "Bottle detached";
     */
    
    cell.v_TopLine.hidden = false;
    cell.v_BottomLine.hidden = false;
    
    if( indexPath.row == 0 ) {
        cell.v_TopLine.hidden = true;
    }
    if( indexPath.row >= _arM_DeviceRecordList.count - 1 ) {
        cell.v_BottomLine.hidden = true;
    }
    
    NSString *regTime = dic[@"date"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [format dateFromString:regTime];
    
    NSDateFormatter *format2 = [[NSDateFormatter alloc] init];
    [format2 setDateFormat:@"a h:mm:ss   yyyy-MM-dd"];
    [format2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateString = [format2 stringFromDate:date];
    cell.lb_Time.text = dateString;
    
    cell.v_Circle.backgroundColor = [UIColor linkColor];
    cell.v_Circle.layer.borderColor = [UIColor linkColor].CGColor;
    cell.v_Circle.layer.borderWidth = 1;
    
    NSString *msg = dic[@"msg"];
    if( [msg isEqualToString:@"Bottle detached"] ) {
        cell.v_Circle.backgroundColor = [UIColor whiteColor];
        cell.v_Circle.layer.borderColor = [UIColor linkColor].CGColor;
        cell.v_Circle.layer.borderWidth = 1;
    }

    cell.lb_Status.text = msg;
    
    return cell;
}

@end
