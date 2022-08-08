//
//  ScanPeripheral.m
//  iProtect
//
//  Created by YongHee Nam on 2017. 8. 30..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#import "ScanPeripheral.h"
#import "adv_data.h"
#import "CLDcare-Swift.h"

@interface ScanPeripheral() <CBPeripheralDelegate>
{
    
}


@end

@implementation ScanPeripheral

@synthesize rssi;
@synthesize rx;
@synthesize tx;

+ (ScanPeripheral *)initWithPeripheral:(CBPeripheral *)peripheral
{
    return [[ScanPeripheral alloc] initWithPeripheral:peripheral];
}

- (id) initWithPeripheral:(CBPeripheral*)peripheral
{
    if ((self = [super init]) != nil)
    {
        _peripheral = peripheral;
        
        // set CBPeripherial delegate
        _peripheral.delegate = self;
        
        return self;
    }
    
    return nil;
}

- (BOOL)isEqual:(id)object
{
    ScanPeripheral* other = (ScanPeripheral*) object;
    return self.peripheral == other.peripheral;
}

+ (CBUUID *) uartServiceUUID
{
    return [CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) txCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) rxCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"6e400003-b5a3-f393-e0a9-e50e24dcca9e"];
}

+ (CBUUID *) deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

+ (CBUUID *) hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}



- (void)findService
{
    self.peripheral.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // discover services
        NSArray* services = @[[ScanPeripheral uartServiceUUID]];
        [self.peripheral discoverServices:services];
    });
    
}

- (void)removeService {
    self.peripheral.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // discover services
        NSArray* services = @[];
        [self.peripheral discoverServices:services];
    });
}



#pragma mark - CBPeripheral delegate implementation
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
//{
//    NSLog(@"discovered peripheral service: %@", peripheral.services);
//
//    BOOL success = NO;
//    for (CBService* service in peripheral.services)
//    {
//        // UART service id was found
//        if ([service.UUID isEqual:[self.class uartServiceUUID]])
//        {
//            success = YES;
//
//            NSArray* chars = @[[self.class txCharacteristicUUID], [self.class rxCharacteristicUUID]];
//            [peripheral discoverCharacteristics:chars forService:service];
//            break;
//        }
//    }
//
//    [self.delegate scanPeripheral:self serviceDiscovered:success];
//}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"discovered peripheral service: %@", peripheral.services);
    
    BOOL success = NO;
    for (CBService* service in peripheral.services)
    {
        if( [peripheral.name isEqualToString:@"DfuTarg"] ) {
            NSArray* chars = @[[self.class uartServiceUUID]];
            [peripheral discoverCharacteristics:chars forService:service];
            success = YES;
        } else {
            // UART service id was found
            if ([service.UUID isEqual:[self.class uartServiceUUID]])
            {
                success = YES;
                NSArray* chars = @[[self.class txCharacteristicUUID], [self.class rxCharacteristicUUID]];
                [peripheral discoverCharacteristics:chars forService:service];
                break;
            }
        }
    }
    
    [self.delegate scanPeripheral:self serviceDiscovered:success];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error on discovering characteristics : %@", error);
        return;
    }
    
    for (CBCharacteristic* ch in [service characteristics])
    {
        if ([ch.UUID isEqual:[self.class rxCharacteristicUUID]])
        {
            self.rx = ch;
            
            // set notification for rx characteristics
            [self.peripheral setNotifyValue:YES forCharacteristic:self.rx];
        }
        else if ([ch.UUID isEqual:[self.class txCharacteristicUUID]])
        {
            self.tx = ch;
        }
    }
    
    BOOL success = (self.rx != nil && self.tx != nil);
    NSLog(@"characteristics discovered ... success:%d, delegate:%@", success, self.delegate);
    

    [self.delegate scanPeripheral:self characteristicsDiscovered:success];
}

- (NSUInteger)battery
{
    dispenser_manuf_data_t* md = (dispenser_manuf_data_t*)self.manufData.bytes;
    if( kCryptoMode ) {
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
                    
        Byte *data = (Byte*)[self.manufData bytes];
        for( int j = 2; j < self.manufData.length; j++ ) {
            if( revert_rotate_val[j-2] < 0 ) {        // rotate left
                data[j] = (Byte)( (data[j] << (-revert_rotate_val[j-2])) | ( (Byte)(~((Byte)0x80 >> (8-(-revert_rotate_val[j-2])-1) )) & (Byte)(data[j] >> (8-(-revert_rotate_val[j-2]) )) ) );
                data[j] = (Byte)(data[j] ^ xor_val[j-2]);
            } else if( revert_rotate_val[j-2] > 0 ) {   // rotate right
                data[j] = (Byte)(( (~((Byte)0x80 >> (revert_rotate_val[j-2]-1))) & (Byte)(data[j] >> revert_rotate_val[j-2]) ) | (Byte)(data[j] << (8-revert_rotate_val[j-2])) );
                data[j] = (Byte)(data[j] ^ xor_val[j-2]);
            }
        }
        md = (dispenser_manuf_data_t *)data;
    }
    return md->bat;
}

- (NSString *)macAddr {
//    return [self.peripheral.identifier UUIDString];
    
    dispenser_manuf_data_t* md = (dispenser_manuf_data_t*)self.manufData.bytes;
    
    if( kCryptoMode ) {
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
                    
        Byte *data = (Byte*)[self.manufData bytes];
        for( int j = 2; j < self.manufData.length; j++ ) {
            if( revert_rotate_val[j-2] < 0 ) {        // rotate left
                data[j] = (Byte)( (data[j] << (-revert_rotate_val[j-2])) | ( (Byte)(~((Byte)0x80 >> (8-(-revert_rotate_val[j-2])-1) )) & (Byte)(data[j] >> (8-(-revert_rotate_val[j-2]) )) ) );
                data[j] = (Byte)(data[j] ^ xor_val[j-2]);
            } else if( revert_rotate_val[j-2] > 0 ) {   // rotate right
                data[j] = (Byte)(( (~((Byte)0x80 >> (revert_rotate_val[j-2]-1))) & (Byte)(data[j] >> revert_rotate_val[j-2]) ) | (Byte)(data[j] << (8-revert_rotate_val[j-2])) );
                data[j] = (Byte)(data[j] ^ xor_val[j-2]);
            }
        }
        md = (dispenser_manuf_data_t *)data;
    }
    
    NSInteger macAddrLength = sizeof(md->addr) - 1;
    NSMutableString *macAddr = [NSMutableString stringWithCapacity:macAddrLength];
    for (NSInteger i = macAddrLength; i >= 0; i--) {
        [macAddr appendString:[NSString stringWithFormat:@"%02x", (unsigned int) md->addr[i]]];
        if( i > 0 ) {
            [macAddr appendString:@":"];
        }
    }
    return macAddr;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error on receiving notification for characteristics %@, %@", characteristic, error);
        return;
    }
    
    if (characteristic == self.rx)
    {
        [self.delegate scanPeripheral:self didReceiveData:characteristic.value];
    }
}

- (void) writeData:(NSData*) data
{
    if ((self.tx.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
    {
        [self.peripheral writeValue:data forCharacteristic:self.tx type:CBCharacteristicWriteWithoutResponse];
    }
    else if ((self.tx.properties & CBCharacteristicPropertyWrite) != 0)
    {
        [self.peripheral writeValue:data forCharacteristic:self.tx type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        NSLog(@"No write property on TX characteristics");
    }
}

- (void) writeString:(NSString*) str
{
    NSData* data = [NSData dataWithBytes:str.UTF8String length:str.length];
    [self writeData:data];
}

- (void)writeBuffer:(const void*)buffer withLength:(NSUInteger) len {
    if (len > NUS_MAX_DATA_LEN) {
        NSLog(@"NUS max data length exceed");
        return;
    }

    NSData* data = [NSData dataWithBytes:buffer length:len];
    NSLog(@"org data : %@", data);
    
    if( kCryptoMode ) {
        data = [AES256Util encryptWithData:data];
        NSLog(@"enc data : %@", data);
    }
    
    [self writeData:data];
    
//    NSData *dec = [AES256Util decryptWithData:enc];
//    NSLog(@"dec data : %@", dec);

}



@end
