//
//  Device.h
//  CLDcare
//
//  Created by 김영민 on 2023/03/08.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Device : NSObject

// 디바이스 OS 버전 조회
+ (NSString *)getOsVersion;

// 디바이스 모델 조회
+ (NSString *)getModel;

// 디바이스 모델명 조회
+ (NSString *)getModelName;

@end

NS_ASSUME_NONNULL_END
