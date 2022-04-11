//
//  NDHint.m
//  Coledy
//
//  Created by 김영민 on 2021/09/03.
//

#import "NDHint.h"

@implementation NDHint
- (id)initWithDic:(NSDictionary *)dic {
    if( (self = [super init]) != nil ) {
        self.surveySeq = [dic[@"surveySeq"] integerValue];
        self.questionsNo = [dic[@"questionsNo"] integerValue];
        self.displayOrder = [dic[@"displayOrder"] integerValue];
        self.exampleContentKo = dic[@"exampleContentKo"];
        return self;
    }
    return nil;
}
@end
