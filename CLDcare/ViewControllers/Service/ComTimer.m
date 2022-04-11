//
//  ComTimer.m
//  BLEToy
//
//  Created by YongHee Nam on 2017. 1. 15..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#import "ComTimer.h"

#define DEF_TIMEOUT 1           // 1 sec to default timeout

//////////////////////////////////////////////////////////////////////
@interface ComTimer ()
@property (atomic, strong) NSDate* tm;

@end

//////////////////////////////////////////////////////////////////////
@implementation ComTimer

+ (instancetype) timer
{
    return [[ComTimer alloc] init];
}

+ (instancetype) timerWithTimeout:(double) timeout;
{
    return [[ComTimer alloc] initWithTimeout:timeout];
}

- (instancetype)init
{
    return [self initWithTimeout:DEF_TIMEOUT];
}

- (instancetype)initWithTimeout:(double)timeout
{
    self = [super init];
    
    if (self)
    {
        self.Timeout = timeout;
        [self start];
    }
    
    return self;
}

- (void)start
{
    self.tm = [NSDate date];
}

- (BOOL)isTimeout
{
    return [self elapse] > self.Timeout;
}

// elapse in second unit
- (double)elapse
{
    return -self.tm.timeIntervalSinceNow;
}

@end
