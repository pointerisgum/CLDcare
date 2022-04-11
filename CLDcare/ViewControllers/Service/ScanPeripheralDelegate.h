//
//  ScanPeripheralDelegate.h
//  iProtect
//
//  Created by YongHee Nam on 2017. 8. 30..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScanPeripheralDelegate <NSObject>
@optional
-(void) scanPeripheral:(id)peripheral serviceDiscovered:(BOOL)success;
-(void) scanPeripheral:(id)peripheral characteristicsDiscovered:(BOOL)success;
-(void) scanPeripheral:(id)peripheral didReceiveData:(NSData*)data;

@end
