//
//  MDMediSetUpData.m
//  CLDcare
//
//  Created by 김영민 on 2022/11/28.
//

#import "MDMediSetUpData.h"

static MDMediSetUpData *shared = nil;

@implementation MDMediSetUpData

+ (void)initialize {
    NSAssert(self == [MDMediSetUpData class], @"Singleton is not designed to be subclassed.");
    shared = [MDMediSetUpData new];
}

+ (MDMediSetUpData *)sharedData {
    return shared;
}

- (void)reset {
    _isNew = nil;
    _totalCount = nil;
    _isEveryDay = nil;
    _dayTakeCount = nil;
    _take1Count = nil;
    [_alarms removeAllObjects];
    _alarms = nil;
}

@end
