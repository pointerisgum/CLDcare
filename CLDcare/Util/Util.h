//
//  Util.h
//  FoodView
//
//  Created by Kim Young-Min on 13. 3. 13..
//  Copyright (c) 2013년 bencrow. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Latest,     //최신버전
    Optional,   //선택 업데이트
    Require,    //강제 업데이트
} UpdateStatus;


@interface Util : NSObject

+ (Util *)sharedData;
+ (BOOL)isCheckEmail:(NSString *)str;
+ (BOOL)isCheckPw:(NSString *)str;
+ (BOOL)isCheckBirth:(NSString *)str;
+ (UIWindow *)keyWindow;
+ (BOOL)isOffLine;
+ (NSString *)getNetworkSatatus;
+ (void)showAlert:(NSString *)aMsg withVc:(UIViewController *)vc;
+ (void)showAlertWindow:(NSString *)aMsg;
+ (void)showAlertServerError;
+ (BOOL)canNextStep:(UIViewController *)vc;
+ (void)showConfirmAlret:(UIViewController *)vc withMsg:(NSString *)msg completion:(void(^)(id result))completion;
+ (UpdateStatus)needsUpdate;
+ (BOOL)isNetworkCheckAlert;
+ (NSString *)contentTypeForImageData:(NSData *)data;
+ (NSString* )sha256:(NSString *)text;
+ (void)makeToastWindow:(NSString *)msg;
+ (void)updateAlarm;
+ (void)saveAlarm:(NSMutableArray *)arM_Alarms;
+ (void)skipTodayAlarm;
+ (NSString *)convertHexToAscii:(NSString *)hex;
+ (NSString *)convertSerialNo;
+ (NSString *)getDateString:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone;
+ (NSString *)makeKey:(NSString *)key;
+ (void)topRound:(UIView *)view;


+ (NSString *)getAppStoreVersion;
+ (UpdateStatus)checkReqUpdate:(UIViewController *)vc;
+ (void)firmWareDownload:(NSString *)fileName withCompletion:(void (^)(BOOL isSuccess))completion;

+ (void)deleteData;
+ (Byte *)decrypt:(NSData *)manufData;

@end
