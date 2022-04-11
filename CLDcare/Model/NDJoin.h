//
//  NDJoin.h
//  Coledy
//
//  Created by 김영민 on 2021/07/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDJoin : NSObject
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *pw;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *birth;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *authType;
@property (strong, nonatomic) NSString *certKey;
+ (NDJoin *)sharedData;
@end

NS_ASSUME_NONNULL_END
