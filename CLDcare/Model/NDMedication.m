//
//  NDMedication.m
//  Coledy
//
//  Created by 김영민 on 2021/07/15.
//

#import "NDMedication.h"

@implementation NDMedication

- (id)initWithTime:(NSTimeInterval)time withType:(MedicationStatusCode)code withMsg:(NSString *)msg {
    if( (self = [super init]) != nil ) {
        self.time = time;
        self.code = code;
        self.msg = msg;
        return self;
    }
    return nil;
}

@end
