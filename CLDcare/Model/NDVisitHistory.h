//
//  NDVisitHistory.h
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDVisitHistory : NSObject
@property (strong, nonatomic) NSString *mdcrYmd;
@property (strong, nonatomic) NSString *deptCode;
@property (strong, nonatomic) NSString *mddrNm;
@property (strong, nonatomic) NSString *clnDeptNm;
@property (strong, nonatomic) NSString *hcode;
@property (strong, nonatomic) NSString *hnm;
- (id)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
