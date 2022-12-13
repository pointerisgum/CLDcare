//
//  MDMediSetUpData.h
//  CLDcare
//
//  Created by 김영민 on 2022/11/28.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface MDMediSetUpData : NSObject
@property (nonatomic, strong, nullable) NSString *isNew;              //새로운 기기의 연결인지
@property (nonatomic, strong, nullable) NSString *totalCount;         //약통에 들어있는 약의 총 갯수
@property (nonatomic, strong, nullable) NSString *isEveryDay;         //매일 복용하는지
@property (nonatomic, strong, nullable) NSString *dayTakeCount;       //하루 복용 횟수
@property (nonatomic, strong, nullable) NSString *take1Count;         //한번에 먹는 양
@property (nonatomic, strong, nullable) NSMutableDictionary *alarms;  //알람시간
+ (MDMediSetUpData *)sharedData;
- (void)reset;
@end

NS_ASSUME_NONNULL_END


