//
//  ComTimer.h
//  BLEToy
//
//  Created by YongHee Nam on 2017. 1. 15..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface ComTimer : NSObject
@interface ComTimer : NSObject

@property (atomic, assign) double Timeout;
@property (atomic, readonly) double elapse;

+ (instancetype) timer;
+ (instancetype) timerWithTimeout:(double)timeout;

- (instancetype)initWithTimeout:(double)timeout;
- (void)start;
- (BOOL)isTimeout;

@end
