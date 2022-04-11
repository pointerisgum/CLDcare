//
//  NDHistory.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDHistory : NSObject
@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) NSInteger month;
@property (assign, nonatomic) NSInteger day;
@property (assign, nonatomic) NSInteger hour;
@property (assign, nonatomic) NSInteger minute;
@property (assign, nonatomic) NSInteger second;
@property (assign, nonatomic) NSInteger nIdx;
- (id)initWithData:(NSData *)data withIdx:(NSInteger)idx;
@end

NS_ASSUME_NONNULL_END
