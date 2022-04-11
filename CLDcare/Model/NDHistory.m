//
//  NDHistory.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "NDHistory.h"
#import "ble_packet.h"

@implementation NDHistory

- (id)initWithData:(NSData *)data withIdx:(NSInteger)idx {
    if( (self = [super init]) != nil ) {
        ble_res_data_t* res = (ble_res_data_t*)data.bytes;
        self.year = res->ttime[0]+2000;
        self.month = res->ttime[1];
        self.day = res->ttime[2];
        self.hour = res->ttime[3];
        self.minute = res->ttime[4];
        self.second = res->ttime[5];
        self.nIdx = idx;
        return self;
    }
    return nil;
}

@end
