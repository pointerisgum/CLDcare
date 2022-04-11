//
//  SearchDeviceViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <UIKit/UIKit.h>
#import "ScanPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionBlock)(ScanPeripheral *);

@interface SearchDeviceViewController : BaseViewController
@property (assign, nonatomic) BOOL isPrescrip;  //처방에서 디바이스 연동시
@property (nonatomic, copy) CompletionBlock completionBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
@end

NS_ASSUME_NONNULL_END
