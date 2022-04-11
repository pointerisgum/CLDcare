//
//  NDJoin.m
//  Coledy
//
//  Created by 김영민 on 2021/07/23.
//

#import "NDJoin.h"

static NDJoin *shared = nil;

@implementation NDJoin

+ (void)initialize {
    NSAssert(self == [NDJoin class], @"Singleton is not designed to be subclassed.");
    shared = [NDJoin new];
    shared.certKey = @"";
    shared.authType = @"";
}

+ (NDJoin *)sharedData {
    return shared;
}

@end
