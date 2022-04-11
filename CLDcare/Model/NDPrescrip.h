//
//  NDPrescrip.h
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import <Foundation/Foundation.h>
#import "NDPrescripHistory.h"
#import "NDVisitHistory.h"

NS_ASSUME_NONNULL_BEGIN

@interface NDPrescrip : NSObject
@property (strong, nonatomic, nullable) NSMutableArray<NDPrescripHistory *> *prescripHistory;
@property (strong, nonatomic) NDVisitHistory *visitHistory;
@property (assign, nonatomic) NSInteger seqNo;
+ (NDPrescrip *)sharedData;
- (void)setItem:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
