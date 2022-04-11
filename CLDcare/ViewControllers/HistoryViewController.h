//
//  HistoryViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <UIKit/UIKit.h>
#import "ScanPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HistoryBlock)(NSArray *result);

@interface HistoryViewController : UIViewController
@property (nonatomic, copy) HistoryBlock historyBlock;
@property (nonatomic, weak) ScanPeripheral* device;
@property (nonatomic, weak) CBCentralManager* centralManager;
- (void)setHistoryBlock:(HistoryBlock)historyBlock;
@end

NS_ASSUME_NONNULL_END
