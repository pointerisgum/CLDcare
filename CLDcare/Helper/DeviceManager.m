//
//  DeviceManager.m
//  Coledy
//
//  Created by 김영민 on 2021/07/15.
//

#import "DeviceManager.h"
#import "UIAlertController+Message.h"
#import "ble_packet.h"
#import "ScanPeripheralDelegate.h"
#import <MBProgressHUD.h>
#import "ComTimer.h"
#import "NDHistory.h"

#define def_command_timeout 5

@interface DeviceManager () <ScanPeripheralDelegate> {
    dispatch_block_t  connectBlock;
    ComTimer*         commandTimer;
    uint8_t           send_cmd;
    uint32_t          history_count;
    NSInteger         history_index;
    NSInteger         historyArrayIndx;
}
//@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) ScanPeripheral* device;
@property (strong, nonatomic) CBCentralManager* centralManager;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) MBProgressHUD* hud;
@property (strong, nonatomic) NSArray *ar_List;
@end

@implementation DeviceManager

- (id)initWithDevice:(ScanPeripheral *)device withManager:(CBCentralManager *)manager {
    if( (self = [super init]) != nil ) {
        _device = device;
        _centralManager = manager;
        _device.delegate = self;
        
        commandTimer = [ComTimer timerWithTimeout:def_command_timeout];
        
        return self;
    }
    return nil;
}

- (void)start:(NSArray *)ar {
    __weak typeof(self) weakSelf = self;
    
    self.ar_List = ar;
    
    history_count = 0;
    historyArrayIndx = 0;

    NSInteger nStartIdx = [[ar firstObject] integerValue];
    history_index = nStartIdx;
    
    connectBlock = ^() {
        [weakSelf sendPacket:ncmd_count data:NULL length:0];
    };
    
    //    [self showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
    [_centralManager connectPeripheral:_device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

- (void)updateConnect {
    __weak typeof(self) weakSelf = self;
    
    connectBlock = ^() {
        weakSelf.firmwareUARTCompleteBlock(true);
    };
    
    //    [self showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
    [_centralManager connectPeripheral:_device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

- (void)setTime {
    __weak typeof(self) weakSelf = self;
    
    connectBlock = ^() {
        NSDate* date = [NSDate date];
//        NSDate* take_date = [date dateByAddingTimeInterval:120];
        NSDateComponents *cur_components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond| NSCalendarUnitWeekday fromDate:date];
        NSDateComponents *take_components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
        ble_date_time_t dt;
        dt.year = cur_components.year;
        dt.month = cur_components.month;
        dt.day = cur_components.day;
        dt.hour = cur_components.hour;
        dt.min = cur_components.minute;
        dt.sec = cur_components.second;
        dt.weekdays = cur_components.weekday;
        dt.take_hour = take_components.hour;
        dt.take_min = take_components.minute;
        [weakSelf sendPacket:ncmd_take_time data:&dt length:sizeof(dt)];
        //0, 8, 11
    };
    
    //    [self showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
    [_centralManager connectPeripheral:_device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

- (void)firmWareUART {
    __weak typeof(self) weakSelf = self;

    connectBlock = ^() {
        NSLog(@"sendPacket:ncmd_firmware_uart");
        ble_cmd_data_t cd;
        cd.cmd[0] = 42;
        cd.cmd[1] = 42;
        [weakSelf sendPacket:ncmd_firmware_uart data:&cd length:sizeof(cd)];
    };
    
    //    [self showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
    [_centralManager connectPeripheral:_device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

- (void)getSerial {
    __weak typeof(self) weakSelf = self;

    connectBlock = ^() {
        
//        ble_serial_data_t *sd;
        [weakSelf sendPacket:ncmd_serial_data data:NULL length:0];
    };
    
    //    [self showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
    [_centralManager connectPeripheral:_device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

- (void)resetCount {
    __weak typeof(self) weakSelf = self;
    
    connectBlock = ^() {
        NSDate* date = [NSDate date];
        NSDateComponents *cur_components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond| NSCalendarUnitWeekday fromDate:date];
        
        ble_date_time_t dt;
        dt.year = cur_components.year;
        dt.month = cur_components.month;
        dt.day = cur_components.day;
        dt.hour = cur_components.hour;
        dt.min = cur_components.minute;
        dt.sec = cur_components.second;
        dt.weekdays = cur_components.weekday;
        [weakSelf sendPacket:ncmd_reset data:&dt length:sizeof(dt)];
    };
    
    //    [self showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
    [_centralManager connectPeripheral:_device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

- (void)dealloc {
    
    //    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
    _device.delegate = nil;
    //    }
}

- (void)sendPacket:(uint8_t)cmd data:(void*)data length:(NSUInteger)length {
    NSUInteger len = length + ble_nus_header_length;
    
    if( cmd == ncmd_firmware_uart ) {
        [_device writeBuffer:data withLength:len];
        [self finishFirmwareUART];
    } else {
        uint8_t buf[len];
        ble_nus_data_t* base = (ble_nus_data_t*)buf;
        base->cmd = cmd;
        base->header = ble_nus_prefix;

        if (length != 0) {
            memcpy((uint8_t*)buf + ble_nus_header_length, data, length);
        }
        [_device writeBuffer:buf withLength:len];
        
        send_cmd = cmd;
        [commandTimer start];
    }
}

#pragma mark - ScanPeripheral delegate
- (void)scanPeripheral:(id)peripheral serviceDiscovered:(BOOL)success {
    NSLog(@"service : %d", success);
    //    [self setHUDTitle:@"Discovering services"];
    //    [self setHUDProgress:0.4f];
}

- (void)scanPeripheral:(id)peripheral characteristicsDiscovered:(BOOL)success {
    NSLog(@"characteristics : %d", success);
    
    [self runConnectBlock];
}

- (void)runConnectBlock {
    //    [self setHUDTitle:@"Send command"];
    //    [self setHUDProgress:0.8f];
    
    connectBlock();
    connectBlock = nil;
    
    //[UIAlertController mesageBoxWithTitle:@"Setting has been successfully transferred!" message:nil style:MBS_OK handler:nil];
}

- (void) requestHistoryData {
    ble_req_data_t req;
    req.index = history_index;
    [self sendPacket:ncmd_get_data data:&req length:sizeof(req)];
}

- (void)finishHistory {
    //    [self performSegueWithIdentifier:@"historySegue" sender:self];
    _device.delegate = nil;
    
    if( _historyCompleteBlock ) {
        NSMutableArray *arM = [NSMutableArray arrayWithCapacity:_items.count];
        for( NSInteger i = 0; i < _items.count; i++ ) {
            NSDictionary *dic = _items[i];
            NDHistory *history = [[NDHistory alloc] initWithData:dic[@"item"] withIdx:[dic[@"index"] integerValue]];
            [arM addObject:history];
        }
        _historyCompleteBlock(arM);
    }
}

- (void)finishSerial:(NSString *)serialNo serialChar:(NSString *)serialChar mac:(NSString *)mac {
    _device.delegate = nil;
    if( _serialNoCompleteBlock ) {
        _serialNoCompleteBlock(serialNo, serialChar, mac);
    }
}

- (void)finishReset:(BOOL)isSuccess {
    _device.delegate = nil;
    if( _resetCountCompleteBlock ) {
        _resetCountCompleteBlock(isSuccess);
    }
}

- (void)finishTimeSync:(BOOL)isSuccess {
    _device.delegate = nil;
    if( _timeSyncCompleteBlock ) {
        _timeSyncCompleteBlock(true);
    }
}

- (void)finishFirmwareUART {
    NSLog(@"finishFirmwareUART");
    _device.delegate = nil;
    if( _firmwareUARTCompleteBlock ) {
        _firmwareUARTCompleteBlock(true);
    }
}

- (void)scanPeripheral:(id)peripheral didReceiveData:(NSData *)data
{
//    NSLog(@"Did receive data\n");
    
    ble_nus_data_t* rcv = (ble_nus_data_t*)data.bytes;
    if(data.length < ble_nus_header_length)
    {
        NSLog(@"data length error");
        return;
    }
    
    BOOL success = NO, fail = NO;
    
    if (send_cmd == rcv->cmd)
    {
        switch (send_cmd)
        {
            case ncmd_take_time:
                NSLog(@"ncmd_take_time");
                success = YES;
                [self finishTimeSync:true];
                break;
            case ncmd_reset:
                success = YES;
                [self finishReset:true];
                break;
            case ncmd_count : {
                ble_res_count_t* res = (ble_res_count_t*)rcv->buffer;
                history_count = res->stored_count;
                if( history_index >= history_count ) {
                    [_centralManager cancelPeripheralConnection:self.device.peripheral];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self finishHistory];
                    });
                    return;
                }
                //                    history_index = 13;
                _items = [NSMutableArray array];
                
                //                    [self setHUDProgress:0.5f];
                [self requestHistoryData];
            }
                break;
            case ncmd_get_data: {
                ble_res_data_t* res = (ble_res_data_t*)rcv->buffer;
                NSLog(@"(v:%d) %d-%d-%d %d:%d:%d",
                      res->valid, res->ttime[0], res->ttime[1], res->ttime[2], res->ttime[3],
                      res->ttime[4], res->ttime[5]);
                
                NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
                if (res->valid) {
                    [dicM setObject:[NSData dataWithBytes:res length:sizeof(ble_res_data_t)] forKey:@"item"];
                }
                
                if( [self.ar_List containsObject:@(history_index)] ) {
                    [dicM setObject:@(history_index) forKey:@"index"];
                    [_items addObject:dicM];
                }
                
                history_index++;
                
                if( history_index >= history_count || res->valid == 0 ) {
                    [_centralManager cancelPeripheralConnection:self.device.peripheral];
                    
                    //                        [self setHUDProgress:1.0f];
                    //                        [self hideHUD];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self finishHistory];
                    });
                } else {
                    [self requestHistoryData];
                }
            }
                break;
            case ncmd_serial_data: {
                ble_serial_data_t* res = (ble_serial_data_t*)rcv->buffer;
                NSString *serialNo = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
                                      res->serial[0],
                                      res->serial[1],
                                      res->serial[2],
                                      res->serial[3],
                                      res->serial[4],
                                      res->serial[5],
                                      res->serial[6],
                                      res->serial[7],
                                      res->serial[8],
                                      res->serial[9],
                                      res->serial[10]];
                
                NSString *fwVersion = [NSString stringWithFormat:@"%02x%02x",
                                      res->serial[17],
                                      res->serial[18]];

                NSLog(@"get version : %@", fwVersion);
                [[NSUserDefaults standardUserDefaults] setObject:fwVersion forKey:@"FWVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //                NSLog(@"%s", res->serial);
                
                NSMutableString *serialNoChar = [NSMutableString string];
                for( NSInteger i = 0; i <= 10; i++ ) {
                    [serialNoChar appendString:[NSString stringWithFormat:@"%c", res->serial[i]]];
                }
                NSLog(@"get serialNoChar : %@", serialNoChar);
                
                NSMutableString *mac = [NSMutableString string];
                for( NSInteger i = 11; i <= 16; i++ ) {
                    [mac appendString:[NSString stringWithFormat:@"%02x", (unsigned int) res->serial[i]]];
                    if( i != 16 ) {
                        [mac appendString:@":"];
                    }
                }
                NSLog(@"get mac addr : %@", mac);
                [self finishSerial:serialNo serialChar:serialNoChar mac:mac];
            }
                break;
//            case ncmd_firmware_uart: {
//                NSLog(@"%s", rcv->buffer);
//                NSLog(@"receivePacket:ncmd_firmware_uart");
//                success = YES;
//                [self finishFirmwareUART];
//            }
//                break;
        }
    }
    
    if (success) {
        // disconnect
        [_centralManager cancelPeripheralConnection:self.device.peripheral];
        //        [self setHUDProgress:1.0f];
        //        [self hideHUD];
        
        //        [UIAlertController mesageBoxWithTitle:@"Setting has been successfully saved" message:nil style:MBS_OK handler:nil viewController:self];
    }

    if (fail) {
        //        [self finishReset:false];
        // disconnect
        [_centralManager cancelPeripheralConnection:self.device.peripheral];
        //        [UIAlertController mesageBoxWithTitle:@"Sorry, Request failed!" message:nil style:MBS_OK handler:nil viewController:self];
    }
}

- (NSString *)stringFromHexString:(NSString *)hexString {
    if (([hexString length] % 2) != 0)
        return nil;

    NSMutableString *string = [NSMutableString string];

    for (NSInteger i = 0; i < [hexString length]; i += 2) {

        NSString *hex = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSInteger decimalValue = 0;
        sscanf([hex UTF8String], "%lx", &decimalValue);
        [string appendFormat:@"%ld", (long)decimalValue];
        NSLog(@"string--%@",string);
    }
    hexString=string;

    NSLog(@"string ---%@",hexString);
    return string;
}

//#pragma mark - HUD management
//- (void) showHUD:(NSString*) title mode:(MBProgressHUDMode)mode
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.hud == nil)
//        {
//            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        }
//        self.hud.mode = mode;
//        self.hud.label.text = title;
//    });
//}
//
//- (void) setHUDTitle:(NSString*) title
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.hud.label.text = title;
//    });
//
//}
//
//- (void) setHUDProgress:(float) progress
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.hud.progress = progress;
//    });
//}
//
//- (void) hideHUD
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.hud != nil)
//            [self.hud hideAnimated:YES];
//        self.hud = nil;
//    });
//}

@end
