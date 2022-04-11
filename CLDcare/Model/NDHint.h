//
//  NDHint.h
//  Coledy
//
//  Created by 김영민 on 2021/09/03.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDHint : NSObject
@property (assign, nonatomic) NSInteger surveySeq;
@property (assign, nonatomic) NSInteger questionsNo;
@property (assign, nonatomic) NSInteger displayOrder;
@property (strong, nonatomic) NSString *exampleContentKo;
- (id)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
