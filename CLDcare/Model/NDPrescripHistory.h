//
//  NDPrescripHistory.h
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import <Foundation/Foundation.h>
#import "NDDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface NDPrescripHistory : NSObject
@property (assign, nonatomic) NSInteger subSeqNo;
@property (strong, nonatomic) NSString *diseNm;
@property (strong, nonatomic) NSString *ediCode;
@property (strong, nonatomic) NSString *oneTimeQty;
@property (strong, nonatomic) NSString *ddcn;
@property (strong, nonatomic) NSString *ntm;
@property (strong, nonatomic) NSString *tkmdInftDrusCtn;
@property (strong, nonatomic) NSString *icunCd;
@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *endDate;
@property (assign, nonatomic) NSInteger countSearchDays;
@property (assign, nonatomic) NSInteger countSuccessDays;
@property (assign, nonatomic) NSInteger countUnderDays;
@property (assign, nonatomic) NSInteger countOverDays;
@property (assign, nonatomic) NSInteger countErrorDays;
@property (assign, nonatomic) NSInteger countNoReportDays;
@property (strong, nonatomic, nullable) NDDevice *device;
- (id)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
