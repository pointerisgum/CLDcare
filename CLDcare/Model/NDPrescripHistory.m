//
//  NDPrescripList.m
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import "NDPrescripHistory.h"

@implementation NDPrescripHistory

- (id)initWithDic:(NSDictionary *)dic {
    if( (self = [super init]) != nil ) {
        self.subSeqNo = [dic[@"subSeqNo"] integerValue];
        self.diseNm = dic[@"diseNm"];
        self.ediCode = dic[@"ediCode"];
        self.oneTimeQty = dic[@"oneTimeQty"];
        self.ddcn = dic[@"ddcn"];
        self.ntm = dic[@"ntm"];
        self.tkmdInftDrusCtn = dic[@"tkmdInftDrusCtn"];
        self.icunCd = dic[@"icunCd"];
        self.startDate = dic[@"startDate"];
        self.endDate = dic[@"endDate"];
        self.countSearchDays = [dic[@"countSearchDays"] integerValue];
        self.countSuccessDays = [dic[@"countSuccessDays"] integerValue];
        self.countUnderDays = [dic[@"countUnderDays"] integerValue];
        self.countOverDays = [dic[@"countOverDays"] integerValue];
        self.countErrorDays = [dic[@"countErrorDays"] integerValue];
        self.countNoReportDays = [dic[@"countNoReportDays"] integerValue];
        NSDictionary *dic_Device = dic[@"device"];
        if( dic_Device ) {
            self.device = [[NDDevice alloc] initWithDic:dic_Device];
        }
        return self;
    }
    return nil;
}

@end
