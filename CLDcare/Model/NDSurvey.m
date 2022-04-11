//
//  NDSurvey.m
//  Coledy
//
//  Created by 김영민 on 2021/09/03.
//

#import "NDSurvey.h"

@implementation NDSurvey
- (id)initWithDic:(NSDictionary *)dic withSeq:(NSInteger)seq {
    if( (self = [super init]) != nil ) {
        self.nSeq = seq;
        self.title = dic[@"main_question_title"];
        self.codeId = dic[@"code_id"];
        self.subTitle = dic[@"sub_question_title"];
        self.nextIdx = [dic[@"next_question_idx"] integerValue];
        self.answerCnt = [dic[@"answer_cnt"] integerValue];
        id hint = dic[@"hint"];
        if( [hint isKindOfClass:[NSString class]] ) {
            self.hint = dic[@"hint"];
        } else if( [hint isKindOfClass:[NSArray class]] ) {
            NSArray *ar = dic[@"hint"];
            if( ar.count > 0 ) {
                self.hints = [NSMutableArray array];
                for( NSDictionary *subDic in ar ) {
                    NDHint *hint = [[NDHint alloc] initWithDic:subDic];
                    [self.hints addObject:hint];
                }
            }
        }
        if( [dic[@"now_answer"] isKindOfClass:[NSNull class]] ) {
            self.nowAnswer = -1;
        } else {
            self.nowAnswer = [dic[@"now_answer"] integerValue];
        }
        
        return self;
    }
    return nil;
}
@end
