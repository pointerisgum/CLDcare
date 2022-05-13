//
//  PrescripDetailViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import "PrescripDetailViewController.h"
#import "SearchDeviceViewController.h"
#import "PopUpViewController.h"
#import "PopUpDeviceDetailViewController.h"

@interface PrescripDetailViewController ()
@property (weak, nonatomic) IBOutlet UIStackView *stv_Detail;
@property (weak, nonatomic) IBOutlet UIView *v_Detail;
@property (weak, nonatomic) IBOutlet UIImageView *iv_Arrow;
@property (weak, nonatomic) IBOutlet UIView *v_DetailBtnBg;
@property (weak, nonatomic) IBOutlet UIView *v_ConnectBg;
@property (weak, nonatomic) IBOutlet UILabel *lb_ConnectStatus;
@property (weak, nonatomic) IBOutlet UIView *v_ConnectStatusBg;
@property (weak, nonatomic) IBOutlet UILabel *lb_ConnectStatusBottom;

//상단
@property (weak, nonatomic) IBOutlet UILabel *lb_HospitalName;
@property (weak, nonatomic) IBOutlet UILabel *lb_PrescripDate;

//하단 위
@property (weak, nonatomic) IBOutlet UILabel *lb_MedicineName;
@property (weak, nonatomic) IBOutlet UILabel *lb_TotalDay;
@property (weak, nonatomic) IBOutlet UILabel *lb_EatCnt;    //1일 3회
@property (weak, nonatomic) IBOutlet UILabel *lb_OneEatEa;     //1회 복용 수량


//하단 아래
@property (weak, nonatomic) IBOutlet UILabel *lb_OneEatEaBottom;
@property (weak, nonatomic) IBOutlet UILabel *lb_EatCntBottom;
@property (weak, nonatomic) IBOutlet UILabel *lb_TotalDayBottom;
@property (weak, nonatomic) IBOutlet UILabel *lb_EatWay;
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceName;
@property (weak, nonatomic) IBOutlet UIButton *btn_Connect;


@end

@implementation PrescripDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _v_Detail.hidden = true;

    _stv_Detail.layer.cornerRadius = 8;
    _stv_Detail.layer.borderColor = [UIColor colorWithHexString:@"E8E8E8"].CGColor;
    _stv_Detail.layer.borderWidth = 1;
    
    _v_DetailBtnBg.layer.cornerRadius = 2;
    _v_DetailBtnBg.layer.borderColor = [UIColor colorWithHexString:@"E8E8E8"].CGColor;
    _v_DetailBtnBg.layer.borderWidth = 1;

    [self updateUI];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"DeviceConnectSegue"] ) {
        SearchDeviceViewController *vc = (SearchDeviceViewController *)segue.destinationViewController;
        vc.isPrescrip = true;
        [vc setCompletionBlock:^(ScanPeripheral * _Nonnull device) {
            [self disConnectDevice:^{
                [self updateItem:^{
                    [self connectDevice:device withBlock:^{
                        [self updateItem:^{
                            
                        }];
                    }];
                }];
            }];

//            if( self.item.device != nil ) {
//                [self disConnectDevice:^{
//                    [self updateItem:^{
//                        [self connectDevice:device];
//                    }];
//                }];
//            } else {
//                [self updateItem:^{
//                    [self connectDevice:device];
//                }];
//            }
        }];
    }
}

- (void)updateItem:(void(^)(void))completion {
    if( self.params ) {
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"prescription/request" param:self.params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
                return;
            }
            
            [[NDPrescrip sharedData].prescripHistory removeAllObjects];

            NSArray *ar = resulte;
            if( ar.count > 0 ) {
                NSDictionary *dic = ar.firstObject;
                [[NDPrescrip sharedData] setItem:dic];
                for( NDPrescripHistory *subItem in [NDPrescrip sharedData].prescripHistory ) {
                    if( subItem.subSeqNo == self.item.subSeqNo ) {
                        self.item = subItem;
                        [self updateUI];
                        completion();
                        break;
                    }
                }
            }
        }];
    }
}
- (void)updateUI {
    //1회 투약량
    
    _lb_HospitalName.text = [NDPrescrip sharedData].visitHistory.hnm;
    _lb_PrescripDate.text = [NDPrescrip sharedData].visitHistory.mdcrYmd;
    
    //약품명
    _lb_MedicineName.text = _item.diseNm;
    
    //총 O일
    _lb_TotalDay.text = [NSString stringWithFormat:@"총 %@일", _item.ddcn];
    
    //1일 3회
    _lb_EatCnt.text = [NSString stringWithFormat:@"1일 %@회", _item.ntm];
    
    //1회 투약량(2정)
    NSString *str_OneTimeQty = [NSString stringWithFormat:@"%@%@", _item.oneTimeQty, _item.icunCd];
    _lb_OneEatEa.text = str_OneTimeQty;
    _lb_OneEatEaBottom.text = str_OneTimeQty;
    
    //1일 투여 횟수
    _lb_EatCntBottom.text = [NSString stringWithFormat:@"%@회", _item.ntm];
    
    //총 투약 일수
    _lb_TotalDayBottom.text = [NSString stringWithFormat:@"%@일", _item.ddcn];
    
    //복용법
    _lb_EatWay.text = _item.tkmdInftDrusCtn;

    [_btn_Connect removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];

    if( _item.device == nil ) {
        //연동 안됨
        _v_ConnectStatusBg.backgroundColor = [UIColor colorWithHexString:@"ebecef"];
        _lb_ConnectStatus.text = @"기기연결 OFF";
        _lb_DeviceName.text = @"-";
        _v_DetailBtnBg.hidden = true;
        _lb_ConnectStatusBottom.text = @"연결하기";
        [_btn_Connect addTarget:self action:@selector(onConnect) forControlEvents:UIControlEventTouchUpInside];
    } else {
        //연동 됨
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        NSString *str_Key = [NSString stringWithFormat:@"%@_Device", email];
        NSDictionary *dic_DeviceInfo = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];

        _v_ConnectStatusBg.backgroundColor = [UIColor colorWithHexString:@"2D9BA9"];
        _lb_ConnectStatus.text = @"기기연결 ON";
        _lb_DeviceName.text = dic_DeviceInfo[@"device_id"];
        _v_DetailBtnBg.hidden = false;
        _lb_ConnectStatusBottom.text = @"연결해제";
        [_btn_Connect addTarget:self action:@selector(onDisConnect) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)connectDevice:(ScanPeripheral *)device withBlock:(void(^)(void))completion {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) {
        [self.view makeToast:@"시리얼 번호를 얻어오지 못했습니다.\n약통을 다시 연결해 주세요."];
        completion();
        return;
    }

    NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
//    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *ble_uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"ble_uuid"];
    if( ble_uuid.length <= 0 || [[device.peripheral.identifier UUIDString] isEqualToString:ble_uuid] == false || macAddr.length <= 0 ) {
//    if( macAddr.length <= 0 || [[self getMacAddr:device.peripheral.name] isEqualToString:macAddr] == false ) {
//    if( macAddr.length <= 0 || [[device.peripheral.identifier UUIDString] isEqualToString:macAddr] == false ) {
        [self.view makeToast:@"It's not a connected device.\nPlease connect the device first."];
        completion();
        return;
    }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@"insert" forKey:@"mapping_action"];
    [dicM_Params setObject:_item.diseNm forKey:@"pill_name"];
//    [dicM_Params setObject:device.macAddr forKey:@"mac_address"];
    [dicM_Params setObject:macAddr forKey:@"mac_address"];
//    [dicM_Params setObject:[device.peripheral.identifier UUIDString] forKey:@"mac_address"];
    [dicM_Params setObject:str_SerialNo forKey:@"serial_num"];
    [dicM_Params setObject:device.peripheral.name forKey:@"device_id"];
    [dicM_Params setObject:@([NDPrescrip sharedData].seqNo) forKey:@"seq_no"];
    [dicM_Params setObject:@(_item.subSeqNo) forKey:@"sub_seq_no"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"prescription/mapping/device" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            completion();
            return;
        }
        
        NSLog(@"%@", resulte);

        if( msgCode == SUCCESS ) {
            NSString *str_Key = [NSString stringWithFormat:@"%@_Device", email];
            [[NSUserDefaults standardUserDefaults] setObject:@{@"mac_address":macAddr,//device.macAddr,
//            [[NSUserDefaults standardUserDefaults] setObject:@{@"mac_address":[device.peripheral.identifier UUIDString],//device.macAddr,
                                                               @"device_id":device.peripheral.name,
                                                               @"serial_num":str_SerialNo,
                                                               @"pill_name":self.item.diseNm,
                                                               @"params":dicM_Params
                                                             } forKey:str_Key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        completion();
    }];
}

- (void)disConnectDevice:(void(^)(void))completion {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    
    NSString *str_Key = [NSString stringWithFormat:@"%@_Device", email];
    NSDictionary *dic_Device = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( dic_Device == nil ) {
        NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
        NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        NSString *serialNo = [Util convertSerialNo];
        if( self.item.diseNm.length > 0 && macAddr.length > 0 && deviceName.length > 0 && serialNo.length > 0 ) {
            dic_Device = @{@"mac_address":macAddr,
                           @"device_id":deviceName,
                           @"serial_num":serialNo,
                           @"pill_name":self.item.diseNm};
            [[NSUserDefaults standardUserDefaults] setObject:dic_Device forKey:str_Key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            completion();
            return;
        }
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@"delete" forKey:@"mapping_action"];
    [dicM_Params setObject:_item.diseNm forKey:@"pill_name"];
    [dicM_Params setObject:dic_Device[@"mac_address"] forKey:@"mac_address"];
    [dicM_Params setObject:dic_Device[@"serial_num"] forKey:@"serial_num"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"prescription/mapping/device" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            completion();
            return;
        }
        
        NSLog(@"%@", resulte);
        
        if( msgCode == SUCCESS ) {
            completion();
        }
    }];
}

- (IBAction)goDetailToggle:(id)sender {
    _v_Detail.hidden = !_v_Detail.hidden;
    
    [UIView animateWithDuration:0.15 animations:^{
        if( self.v_Detail.hidden ) {
            self.iv_Arrow.transform = CGAffineTransformIdentity;
        } else {
            self.iv_Arrow.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }];
}

- (IBAction)goShowDetailInfo:(id)sender {
    PopUpDeviceDetailViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpDeviceDetailViewController"];
    vc.device = _item.device;
    [self presentViewController:vc animated:true completion:^{
        
    }];
}

- (void)onConnect {
    [self performSegueWithIdentifier:@"DeviceConnectSegue" sender:nil];
}

- (void)onDisConnect {
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"연결해제 하시겠습니까?"
                                         message:@""
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        if( action.style == UIAlertActionStyleDefault ) {
            [self disConnectDevice:^{
                [self updateItem:^{
                }];
            }];
        }
    }];
}

@end
