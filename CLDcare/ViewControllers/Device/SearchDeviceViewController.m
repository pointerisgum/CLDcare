//
//  SearchDeviceViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "SearchDeviceViewController.h"
#import "ConnectedDeviceListViewController.h"
#import "adv_data.h"
#import "DeviceCell.h"
#import <MBProgressHUD.h>
#import "DeviceManager.h"
#import "MDMediSetUpData.h"
#import "MediSetUpViewController.h"
@import CoreBluetooth;

@interface SearchDeviceViewController () <CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_ListHeight;
@property (weak, nonatomic) IBOutlet UILabel *lb_Descrip;
@property (strong, nonatomic) MBProgressHUD* hud;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) ScanPeripheral *currentDevice;
//@property (weak, nonatomic) IBOutlet UIButton *btn_SearchDevice;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_ResultFix;
@end

@implementation SearchDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    
    _lb_Title.text = NSLocalizedString(@"Pairing Device", nil);
//    [_btn_SearchDevice setTitle:NSLocalizedString(@"CANCEL", nil) forState:0];
    _lb_ResultFix.text = NSLocalizedString(@"Scanned Device", nil);
    
    [self updateListUI];
    
    dispatch_queue_t centralQueue = dispatch_queue_create("CB_QUEUE", DISPATCH_QUEUE_SERIAL);
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMediSetUpFinish) name:@"MediSetUpFinish" object:nil];
}

- (void)updateListUI {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if( weakSelf.items.count > 0 ) {
            if( weakSelf.items.count > 3 ) {
                weakSelf.lc_ListHeight.constant = 30 + (75 * 3) + 30;
            } else {
                weakSelf.lc_ListHeight.constant = 30 + (75 * weakSelf.items.count);
            }
//            weakSelf.lb_Descrip.textColor = [UIColor colorWithHexString:@"222222"];
//            weakSelf.lb_Descrip.text = [NSString stringWithFormat:@"%ld %@", weakSelf.items.count, NSLocalizedString(@"Scanned Device", nil)];
        } else {
            weakSelf.lc_ListHeight.constant = 0;
//            weakSelf.lb_Descrip.textColor = [UIColor colorWithHexString:@"8b8b8b"];
//            weakSelf.lb_Descrip.text = NSLocalizedString(@"Place sensor device close to\nyour mobile phone with Bluetooth on", nil);
        }
        weakSelf.lb_Descrip.text = NSLocalizedString(@"Place your device close\nto your mobile phone.", nil);
        [weakSelf.tbv_List reloadData];
        
        [UIView animateWithDuration:0.15 animations:^{
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)onMediSetUpFinish {
    NSString *mac = [[NSUserDefaults standardUserDefaults] stringForKey:@"mac"];
    if( _currentDevice != nil && mac.length > 0 ) {
        [self authDevive:self->_currentDevice withMacAddr:mac];
    }
}


- (IBAction)goSearchDevice:(id)sender {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}


#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%ld", central.state);
    if( central.state == CBManagerStatePoweredOn ) {
        [_items removeAllObjects];
        [self updateListUI];
        
        NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
        [_centralManager scanForPeripheralsWithServices:@[[ScanPeripheral uartServiceUUID]] options:options];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSData* manufData = advertisementData[CBAdvertisementDataManufacturerDataKey];
        if( manufData == nil ) { return; }
        
        dispenser_manuf_data_t* md = (dispenser_manuf_data_t*)manufData.bytes;
        
//        if (md->company_identifier != (0x4d<<8 | 0x4f)) { return; }

        if( kCryptoMode ) {
            md = (dispenser_manuf_data_t *)[Util decrypt:manufData];
        }

        if( md->device_last_name != 0xff || md->pairing != 0xff || md->epochtime_cover != 0xffffffff ) {
            return;
        }

        ScanPeripheral* obj =  [ScanPeripheral initWithPeripheral:peripheral];
        obj.manufData = manufData;

        if( ![weakSelf.items containsObject:obj] ) {
            [weakSelf.items addObject:obj];
        } else {
            obj = [weakSelf.items objectAtIndex:[weakSelf.items indexOfObject:obj]];
            obj.manufData = manufData;
        }
        
        obj.rssi = RSSI.intValue;
        obj.scanTime = [NSDate date];
        
        [weakSelf updateListUI];
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connected ...");
    [_currentDevice findService];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnected..");
//    [self scanForPeripherals:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud != nil) {
            [self.hud hideAnimated:YES];
        }
        self.hud = nil;
    });

    if( _centralManager.state != CBManagerStatePoweredOn ) {
        return;
    }
        
    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
    [_centralManager scanForPeripheralsWithServices:@[[ScanPeripheral uartServiceUUID]] options:options];

    NSString *serialNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialNo"];
    if( serialNo == nil || serialNo.length <= 0 ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectSerial:true];
        });
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud != nil) {
            [self.hud hideAnimated:YES];
        }
        self.hud = nil;
    });
}

- (void)centralManager:(CBCentralManager *)central connectionEventDidOccur:(CBConnectionEvent)event forPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)centralManager:(CBCentralManager *)central didUpdateANCSAuthorizationForPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceCell* cell = (DeviceCell*)[tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    cell.btn_Connect.layer.borderColor = MAIN_COLOR.CGColor;

    ScanPeripheral* device = _items[indexPath.row];
    
    if( device.peripheral.name == nil ) { return cell; }
    if( device.macAddr == nil ) { return cell; }
    
    cell.lb_DeviceName.text = device.peripheral.name;
    cell.lb_MacAddr.text = [device.peripheral.identifier UUIDString];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    ScanPeripheral* device = _items[indexPath.row];

    if( device.peripheral.name == nil ) { return; }
    if( device.macAddr == nil ) { return; }

    if( _isPrescrip ) {
        NSString *ble_uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"ble_uuid"];
        if( ble_uuid.length <= 0 || [[device.peripheral.identifier UUIDString] isEqualToString:ble_uuid] == false ) {
            [self.view makeToast:NSLocalizedString(@"It's not a connected device.\nPlease connect the device first.", nil)];
            return;
        }
        
        if( _completionBlock ) {
            _completionBlock(device);
            [self.navigationController popToRootViewControllerAnimated:true];
        }
        return;
    }
    
    if( _centralManager != nil && device != nil ) {
        _currentDevice = device;
        [self connectSerial:true];
    }
}

- (void)connectSerial:(BOOL)isShowMediSetup {
    if (self.hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    self.hud.label.text = NSLocalizedString(@"Pairing your device. Please wait.", nil);;
    [self.hud showAnimated:true];

    DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:_currentDevice withManager:_centralManager];
    [deviceManager getSerial];
    [deviceManager setSerialNoCompleteBlock:^(NSString *serialNo, NSString *serialChar, NSString *mac) {
        NSLog(@"%@", serialNo);
//            serialNo = @"4b:52:43:43:53:41:4e:4e:32:36:56";   //B타입 테스트
//            [[NSUserDefaults standardUserDefaults] setObject:[self getMacAddr:device.peripheral.name] forKey:@"mac"];
        [[NSUserDefaults standardUserDefaults] setObject:mac forKey:@"mac"];
//            [[NSUserDefaults standardUserDefaults] setObject:[device.peripheral.identifier UUIDString] forKey:@"mac"];
        [[NSUserDefaults standardUserDefaults] setObject:serialChar forKey:@"serialChar"];
        [[NSUserDefaults standardUserDefaults] setObject:serialNo forKey:@"serialNo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hideAnimated:true];
            
            if( isShowMediSetup == true ) {
                UINavigationController *navi = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
                navi.modalPresentationStyle = UIModalPresentationFullScreen;
                MediSetUpViewController *vc = (MediSetUpViewController *)navi.viewControllers.firstObject;
            //    MediSetUpViewController *vc = (MediSetUpViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpNavi"];
                vc.step = STEP1;
                [self presentViewController:navi animated:true completion:nil];
            } else {
                [self.navigationController popToRootViewControllerAnimated:true];
            }
        });
    }];
}

- (void)authDevive:(ScanPeripheral *)device withMacAddr:(NSString *)macAddr {
    NSString *str_SerialNo = [Util convertSerialNo];
    if( str_SerialNo == nil ) { return; }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( email.length > 0 ) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString *dateString = [format stringFromDate:[NSDate date]];

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:email forKey:@"mem_email"];
        [dicM_Params setObject:dateString forKey:@"pairing_datetime"];
        [dicM_Params setObject:device.peripheral.name forKey:@"device_id"];
        [dicM_Params setObject:macAddr forKey:@"mac_address"];
//        [dicM_Params setObject:[self getMacAddr:device.peripheral.name] forKey:@"mac_address"];
//        [dicM_Params setObject:[self.currentDevice.peripheral.identifier UUIDString] forKey:@"mac_address"];
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

        
        

        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"auth/device" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
                [self.view makeToastCenter:NSLocalizedString(@"An error occurred during device registration", nil)];
                return;
            }

//            [[MDMediSetUpData sharedData] reset];
            
            NSLog(@"%@", resulte);
            NSLog(@"%u", msgCode);

//            if( msgCode == ALREADY_REGIST ) {
//                [Util makeToastWindow:NSLocalizedString(@"The device is already registered", nil)];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mac"];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"battery"];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"serialNo"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                return;
//            }
            
            if( self.centralManager != nil && self.currentDevice != nil ) {
                if (self.hud == nil) {
                    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                self.hud.label.text = NSLocalizedString(@"Setting the time...", nil);
                [self.hud showAnimated:true];

                DeviceManager *deviceManager = [[DeviceManager alloc] initWithDevice:self.currentDevice withManager:self.centralManager];
                [deviceManager setTime];
                [deviceManager setTimeSyncCompleteBlock:^(BOOL isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud hideAnimated:true];
                        self.hud = nil;
                        
                        [[NSUserDefaults standardUserDefaults] setObject:macAddr forKey:@"mac"];
            //            [[NSUserDefaults standardUserDefaults] setObject:[self.currentDevice.peripheral.identifier UUIDString] forKey:@"mac"];
                        [[NSUserDefaults standardUserDefaults] setObject:[device.peripheral.identifier UUIDString] forKey:@"ble_uuid"];
                        [[NSUserDefaults standardUserDefaults] setObject:device.peripheral.name forKey:@"name"];
                        [[NSUserDefaults standardUserDefaults] setObject:@(device.battery) forKey:@"battery"];
                        [[NSUserDefaults standardUserDefaults] synchronize];

                        [self.navigationController popToRootViewControllerAnimated:true];
                    });
                }];
            }
        }];
    }
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}

@end
