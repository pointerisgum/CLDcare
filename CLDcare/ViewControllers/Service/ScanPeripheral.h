//
//  ScanPeripheral.h
//  iProtect
//
//  Created by YongHee Nam on 2017. 8. 30..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ScanPeripheralDelegate.h"

#define NUS_MAX_DATA_LEN 20

@interface ScanPeripheral : NSObject

@property (strong, nonatomic) CBPeripheral* peripheral;
@property (strong, nonatomic) NSDate* scanTime;
@property (strong, nonatomic) NSData* manufData;
@property (assign, nonatomic) int rssi;
@property (strong, nonatomic) id<ScanPeripheralDelegate> delegate;
@property (strong, nonatomic) CBCharacteristic* rx;
@property (strong, nonatomic) CBCharacteristic* tx;

+ (ScanPeripheral*) initWithPeripheral:(CBPeripheral*)peripheral;
- (id)initWithPeripheral:(CBPeripheral*)peripheral;
- (void)findService;
- (void)removeService;
- (void)writeData:(NSData*) data;
- (void)writeString:(NSString*) str;
- (void)writeBuffer:(const void*)buffer withLength:(NSUInteger) len;
- (NSUInteger)battery;
- (NSString *)macAddr;
+ (CBUUID *)uartServiceUUID;
+ (CBUUID *)txCharacteristicUUID;
+ (CBUUID *)rxCharacteristicUUID;

@end
