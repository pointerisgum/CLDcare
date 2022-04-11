//
//  NDMedication.h
//  Coledy
//
//  Created by 김영민 on 2021/07/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TIMESET1,   //아침 알람
    TIMESET2,   //점심 알람
    TIMESET3,   //저녁 알람
    DOSE,       //약을 복용했습니다
    SURVEY,     //설문을 완료했습니다
    CONFIRM,    //알람을 확인했습니다
    SNOOZE,     //알람을 미루었습니다
    UNKNOW,
} MedicationStatusCode;

@interface NDMedication : NSObject
@property (assign, nonatomic) NSTimeInterval time;
@property (assign, nonatomic) MedicationStatusCode code;
@property (strong, nonatomic) NSString *msg;
- (id)initWithTime:(NSTimeInterval)time withType:(MedicationStatusCode)code withMsg:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
