//
//  WebAPI.h
//  Kizzl
//
//  Created by Kim Young-Min on 13. 6. 3..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SUCCESS,
    FAIL,
    ALREADY_REGIST,
    NO_INFORMATION,
    NO_MATCHING_DATA,
} AFMsgCode;

@interface WebAPI : NSObject
+ (WebAPI *)sharedData;
- (void)imageUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withImages:(NSDictionary *)imageParams withBlock:(void(^)(id resulte, NSError *error))completion;
- (void)fileUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withFileUrl:(NSURL *)url withBlock:(void(^)(id resulte, NSError *error))completion;
- (void)pushAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error, AFMsgCode msgCode))completion;
- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error, AFMsgCode msgCode))completion;
- (NSDictionary *)callSyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod;
@end
