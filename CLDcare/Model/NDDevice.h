//
//  NDDevice.h
//  Coledy
//
//  Created by 김영민 on 2021/08/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDDevice : NSObject
@property (strong, nonatomic) NSString *deviceType;
@property (strong, nonatomic) NSString *deviceModel;
@property (strong, nonatomic) NSString *deviceUse;  //약품명
@property (strong, nonatomic) NSString *productNo;  //시리얼 넘버
- (id)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
