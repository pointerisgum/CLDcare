//
//  NDSurvey.h
//  Coledy
//
//  Created by 김영민 on 2021/09/03.
//

#import <Foundation/Foundation.h>
#import "NDHint.h"

NS_ASSUME_NONNULL_BEGIN

@interface NDSurvey : NSObject
@property (assign, nonatomic) NSInteger nSeq;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *codeId;
@property (strong, nonatomic) NSString *subTitle;
@property (assign, nonatomic) NSInteger nextIdx;
@property (assign, nonatomic) NSInteger answerCnt;
@property (strong, nonatomic) NSString *hint;
@property (strong, nonatomic) NSMutableArray *hints;
@property (assign, nonatomic) NSInteger nowAnswer;
- (id)initWithDic:(NSDictionary *)dic withSeq:(NSInteger)seq;
@end

NS_ASSUME_NONNULL_END
