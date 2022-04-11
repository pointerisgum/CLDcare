//
//  NDPrescrip.m
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import "NDPrescrip.h"

static NDPrescrip *shared = nil;

@implementation NDPrescrip

+ (void)initialize {
    NSAssert(self == [NDPrescrip class], @"Singleton is not designed to be subclassed.");
    shared = [NDPrescrip new];
    shared.prescripHistory = [NSMutableArray array];
}

+ (NDPrescrip *)sharedData {
    return shared;
}

- (void)setItem:(NSDictionary *)dic {
    self.visitHistory = [[NDVisitHistory alloc] initWithDic:dic[@"visitHistoryVo"]];

    self.prescripHistory = [NSMutableArray array];
    NSDictionary *dic_Prescrip = dic[@"prescriptionHistoryVo"];
    self.seqNo = [dic_Prescrip[@"seqNo"] integerValue];
    NSArray *ar_Detail = dic_Prescrip[@"detail"];
    for( NSDictionary *dic_Detail in ar_Detail ) {
        [self.prescripHistory addObject:[[NDPrescripHistory alloc] initWithDic:dic_Detail]];
    }
}

@end
