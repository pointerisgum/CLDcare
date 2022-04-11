//
//  DeviceManager.h
//  Coledy
//
//  Created by 김영민 on 2021/07/15.
//

#import <Foundation/Foundation.h>
#import "ScanPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HistoryCompleteBlock)(NSArray *result);
typedef void (^ResetCountCompleteBlock)(BOOL isSuccess);
typedef void (^SerialNoCompleteBlock)(NSString *serialNo);
typedef void (^TimeSyncCompleteBlock)(BOOL isSuccess);

@interface DeviceManager : NSObject
@property (nonatomic, copy) HistoryCompleteBlock historyCompleteBlock;
@property (nonatomic, copy) ResetCountCompleteBlock resetCountCompleteBlock;
@property (nonatomic, copy) SerialNoCompleteBlock serialNoCompleteBlock;
@property (nonatomic, copy) TimeSyncCompleteBlock timeSyncCompleteBlock;
- (id)initWithDevice:(ScanPeripheral *)device withManager:(CBCentralManager *)manager;
- (void)start:(NSArray *)ar;
- (void)setTime;
- (void)getSerial;
- (void)resetCount;
- (void)setHistoryCompleteBlock:(HistoryCompleteBlock)historyCompleteBlock;
- (void)setResetCountCompleteBlock:(ResetCountCompleteBlock)resetCountCompleteBlock;
- (void)setSerialNoCompleteBlock:(SerialNoCompleteBlock)serialNoCompleteBlock;
- (void)setTimeSyncCompleteBlock:(TimeSyncCompleteBlock)timeSyncCompleteBlock;

@end

NS_ASSUME_NONNULL_END
