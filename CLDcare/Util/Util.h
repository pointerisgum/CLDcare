//
//  Util.h
//  FoodView
//
//  Created by Kim Young-Min on 13. 3. 13..
//  Copyright (c) 2013년 bencrow. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+ (BOOL)needsUpdate;
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
+ (void)topRound:(UIView *)view;
@end
