//
//  NDDevice.m
//  Coledy
//
//  Created by 김영민 on 2021/08/30.
//

#import "NDDevice.h"

@implementation NDDevice
- (id)initWithDic:(NSDictionary *)dic {
    if( (self = [super init]) != nil ) {
        self.deviceType = dic[@"deviceType"];
        self.deviceModel = dic[@"deviceModel"];
        self.deviceUse = dic[@"deviceUse"];
        self.productNo = dic[@"productNo"];
        return self;
    }
    return nil;
}
@end
