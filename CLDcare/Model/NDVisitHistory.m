//
//  NDVisitHistory.m
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import "NDVisitHistory.h"

@implementation NDVisitHistory
- (id)initWithDic:(NSDictionary *)dic {
    if( (self = [super init]) != nil ) {
        self.mdcrYmd = dic[@"mdcrYmd"];
        self.deptCode = dic[@"deptCode"];
        self.mddrNm = dic[@"mddrNm"];
        self.clnDeptNm = dic[@"clnDeptNm"];
        self.hcode = dic[@"hcode"];
        self.hnm = dic[@"hnm"];
        return self;
    }
    return nil;
}
@end
