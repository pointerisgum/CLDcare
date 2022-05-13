//
//  Util.m
//  FoodView
//
//  Created by Kim Young-Min on 13. 3. 13..
//  Copyright (c) 2013년 bencrow. All rights reserved.
//

#import "Util.h"
#include <sys/xattr.h>
#import <SystemConfiguration/SystemConfiguration.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#import <CommonCrypto/CommonDigest.h>
@import UserNotifications;

static Util *shared = nil;

@implementation Util

+ (void)initialize {
    NSAssert(self == [Util class], @"Singleton is not designed to be subclassed.");
    shared = [Util new];
}

+ (Util *)sharedData {
    return shared;
}

+ (BOOL)isCheckEmail:(NSString *)str {
    //1차로 한글이 있는지 검색
    const char *tmp = [str cStringUsingEncoding:NSUTF8StringEncoding];

    if (str.length != strlen(tmp)) {
        return NO;
    }

    //2차로 이메일 형식인지 검색
    NSString *check = @"([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\\.[0-9a-zA-Z_-]+){1,2}";
    NSRange match = [str rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location) {
        return NO;
    }
    return YES;
}

+ (BOOL)isCheckPw:(NSString *)str {
    NSString *check = @"(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}";
    NSRange match = [str rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location) {
        return NO;
    }
    return YES;
}

+ (BOOL)isCheckBirth:(NSString *)str {

    NSString *check = @"(19[0-9][0-9]|20\\d{2})(0[0-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])$";
    NSRange match = [str rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location) {
        return NO;
    }
    return YES;
}

+ (UIWindow *)keyWindow {
    UIWindow *foundWindow = nil;
    NSArray* windows = [[UIApplication sharedApplication]windows];
    for (UIWindow* window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}

+ (BOOL)isOffLine {
    NSString *str_NetworkStatus = [Util getNetworkSatatus];
    if( str_NetworkStatus == nil || str_NetworkStatus.length <= 0 ) {
        return YES;
    }
    return NO;
}

+ (NSString *)getNetworkSatatus {
    NSString *str_ReturnSatatus = nil;
    
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    
    if (!didRetrieveFlags) {
        printf("Error. Could not recover network reachability flags\n");
        return str_ReturnSatatus;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    BOOL isNetworkStatus = (isReachable && !needsConnection) ? YES : NO;
    
    if(!isNetworkStatus)    return str_ReturnSatatus;
    
    zeroAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    
    CFRelease(defaultRouteReachability);
    
    if( flags & kSCNetworkReachabilityFlagsIsWWAN )
        str_ReturnSatatus = @"3G";
    else
        str_ReturnSatatus = @"Wifi";
    
    return str_ReturnSatatus;
}

+ (void)showAlert:(NSString *)aMsg withVc:(UIViewController *)vc {
    [UIAlertController showAlertInViewController:vc
                                       withTitle:@""
                                         message:aMsg
                               cancelButtonTitle:@"확인"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                        }];

}

+ (void)showAlertWindow:(NSString *)aMsg {
    UIViewController *topController = [Util keyWindow].rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    [UIAlertController showAlertInViewController:topController
                                       withTitle:@""
                                         message:aMsg
                               cancelButtonTitle:@"확인"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                        }];

}

+ (void)showAlertServerError {
    UIViewController *topController = [Util keyWindow].rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    [UIAlertController showAlertInViewController:topController
                                       withTitle:@""
                                         message:@"통신 상태가 원활하지 않거나\n데이터가 잘못되었습니다."
                               cancelButtonTitle:@"확인"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                        }];
}

+ (BOOL)canNextStep:(UIViewController *)vc {
    if( [Util isOffLine] ) {
        [UIAlertController showAlertInViewController:vc
                                           withTitle:@""
                                             message:@"통신 상태가 원활 하지 않습니다.\n네트웍 상태를 확인 하세요."
                                   cancelButtonTitle:@"확인"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                
                                                if (buttonIndex == controller.cancelButtonIndex) {
                                                    NSLog(@"Cancel Tapped");
                                                } else if (buttonIndex == controller.destructiveButtonIndex) {
                                                    NSLog(@"Delete Tapped");
                                                } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                                                    
                                                }
                                            }];
        
        return NO;
    }
    
    return YES;
}

+ (void)showConfirmAlret:(UIViewController *)vc withMsg:(NSString *)msg completion:(void(^)(id result))completion {
    [UIAlertController showAlertInViewController:vc
                                       withTitle:@""
                                         message:msg
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        completion(@"");
    }];
}

+ (BOOL)needsUpdate {
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    if ([lookup[@"resultCount"] integerValue] == 1){
        NSString* appStoreVersion = lookup[@"results"][0][@"version"];
        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
        if (![appStoreVersion isEqualToString:currentVersion]){
            NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isNetworkCheckAlert {
    NSString *str_Status = [Util getNetworkSatatus];
    if( str_Status == nil ) {
//        ALERT(nil, @"네트워크에 접속할 수 없습니다.\n3G 및 Wifi 연결상태를\n확인해주세요.", nil, @"확인", nil);
        return NO;
    }
    return YES;
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpeg";
            break;
        case 0x89:
            return @"png";
            break;
        case 0x47:
            return @"gif";
            break;
        case 0x49:
        case 0x4D:
            return @"tiff";
            break;
        case 0x25:
            return @"pdf";
            break;
        case 0xD0:
            return @"vnd";
            break;
        case 0x46:
            return @"plain";
            break;
            //        case 0x52:
            //            // R as RIFF for WEBP
            //            if ([data length] < 12) {
            //                return nil;
            //            }
            //
            //            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            //            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
            //                return @"image/webp";
            //            }
            //
            //            return nil;
            
        default:
            //            return @"application/octet-stream";
            return @"jpg";
    }
    
    return nil;
}

+ (NSString* )sha256:(NSString *)text {
    const char* utf8chars = [text UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(utf8chars, (CC_LONG)strlen(utf8chars), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (void)makeToastWindow:(NSString *)msg {
    UIScene *scene = [[[[UIApplication sharedApplication] connectedScenes] allObjects] firstObject];
    if([scene.delegate conformsToProtocol:@protocol(UIWindowSceneDelegate)]){
        UIWindow *window = [(id <UIWindowSceneDelegate>)scene.delegate window];
        [window makeToastCenter:msg];
    }
}

+ (void)updateAlarm {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];

    NSArray *ar = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];
    NSMutableArray *arM_Alarms = [NSMutableArray arrayWithArray:ar];

    NSInteger nAlarmCnt = 0;
    for( NSDictionary *dic in arM_Alarms ) {
        BOOL isOn = [dic[@"on"] boolValue];
        if( isOn ) {
            nAlarmCnt++;
        }
    }
    
    NSMutableString *strM_Times = [NSMutableString string];
    for( NSDictionary *dic in arM_Alarms ) {
        NSInteger nHour = [dic[@"hour"] integerValue];
        NSInteger nMin = [dic[@"min"] integerValue];
        NSString *str_Time = [NSString stringWithFormat:@"%02ld:%02ld:00/", nHour, nMin];
        [strM_Times appendString:str_Time];

        BOOL isOn = [dic[@"on"] boolValue];
        if( isOn ) {
            UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
            content.body = [NSString localizedUserNotificationStringForKey:@"약 먹을 시간이예요."
                    arguments:nil];
//            content.sound = [UNNotificationSound defaultSound];
            content.sound = [UNNotificationSound soundNamed:@"tickle.mp3"];
//            content.sound = [UNNotificationSound soundNamed:@"bell2.m4a"];
            content.userInfo = @{@"time":[NSString stringWithFormat:@"%02ld:%02ld", nHour, nMin]};
            content.body = @"약 먹을 시간이예요.";

            
            NSInteger nAddAlarmCnt = 24 / nAlarmCnt;
            NSLog(@"%ld", nAddAlarmCnt);
            for( NSInteger i = 0; i < nAddAlarmCnt; i++ ) {   //64 24 25 26
                NSCalendar *currentCalendar = [NSCalendar currentCalendar];
                NSDate *date = [currentCalendar dateByAddingUnit:NSCalendarUnitDay
                                                                       value:i
                                                                      toDate:[NSDate date]
                                                                     options:NSCalendarMatchNextTime];
                
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];

                NSDateComponents* dateComp = [[NSDateComponents alloc] init];
                dateComp.year = components.year;
                dateComp.month = components.month;
                dateComp.day = components.day;
                dateComp.hour = nHour;
                dateComp.minute = nMin;
                UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
                       triggerWithDateMatchingComponents:dateComp repeats:false];
                
                NSString *str_SkipDay = [[NSUserDefaults standardUserDefaults] objectForKey:@"skipDate"];
                if( str_SkipDay != nil && [str_SkipDay isEqualToString:[NSString stringWithFormat:@"%04ld%02ld%02ld", dateComp.year, dateComp.month, dateComp.day]] ) {
                    continue;
                }
                
                NSString *str_Ident = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld",
                                       dateComp.year, dateComp.month, dateComp.day, dateComp.hour, dateComp.minute];
//                NSLog(@"str_Ident: %@", str_Ident);
                
                UNNotificationRequest* request = [UNNotificationRequest
                       requestWithIdentifier:str_Ident content:content trigger:trigger];
                
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                
                
                
                
                
                //10분위 추가등록
                NSDateComponents* dateComp2 = [[NSDateComponents alloc] init];
                dateComp2.year = components.year;
                dateComp2.month = components.month;
                dateComp2.day = components.day;
                dateComp2.hour = nHour;
                dateComp2.minute = nMin+10;
                UNCalendarNotificationTrigger* trigger2 = [UNCalendarNotificationTrigger
                       triggerWithDateMatchingComponents:dateComp2 repeats:false];

                NSString *str_Ident2 = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld",
                                        dateComp2.year, dateComp2.month, dateComp2.day, dateComp2.hour, dateComp2.minute];
//                NSLog(@"str_Ident: %@", str_Ident);
                
                UNNotificationRequest* request2 = [UNNotificationRequest
                       requestWithIdentifier:str_Ident2 content:content trigger:trigger2];
                
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request2 withCompletionHandler:nil];

            }
        }
    }
    
    NSString *str_TimeParam = nil;
    if( strM_Times.length > 0 ) {
        str_TimeParam = [strM_Times substringToIndex:strM_Times.length - 1];
    }

    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( str_TimeParam.length > 0 && email.length > 0 ) {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:email forKey:@"mem_email"];
        [dicM_Params setObject:str_TimeParam forKey:@"mem_alarm_time"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/alarm/update" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
                return;
            }
        }];
    }
}

+ (void)saveAlarm:(NSMutableArray *)arM_Alarms {
    [[NSUserDefaults standardUserDefaults] setObject:arM_Alarms forKey:@"Alarms"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                                  completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (!error) {
                    [Util updateAlarm];
                }
            }];
        } else {
            [Util updateAlarm];
        }
    }];
}

+ (void)skipTodayAlarm {
    NSMutableArray *arM_RemoveAlarm = [NSMutableArray array];
    NSArray *ar = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];
    NSMutableArray *arM_Alarms = [NSMutableArray arrayWithArray:ar];
    for( NSDictionary *dic in arM_Alarms ) {
        NSInteger nHour = [dic[@"hour"] integerValue];
        NSInteger nMin = [dic[@"min"] integerValue];

        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

        NSDateComponents* dateComp = [[NSDateComponents alloc] init];
        dateComp.year = components.year;
        dateComp.month = components.month;
        dateComp.day = components.day;
        dateComp.hour = nHour;
        dateComp.minute = nMin;

        NSString *str_Ident = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld",
                               dateComp.year, dateComp.month, dateComp.day, dateComp.hour, dateComp.minute];
        [arM_RemoveAlarm addObject:str_Ident];
        
        NSString *str_Ident2 = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld",
                               dateComp.year, dateComp.month, dateComp.day, dateComp.hour, dateComp.minute + 10];
        [arM_RemoveAlarm addObject:str_Ident2];
    }
    
    if( arM_RemoveAlarm.count > 0 ) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removePendingNotificationRequestsWithIdentifiers:arM_RemoveAlarm];
    }
}

+ (NSString *)convertSerialNo {
    NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
    if( macAddr.length <= 0 ) {
        [Util makeToastWindow:NSLocalizedString(@"Please connect me to the device", nil)];
        return nil;
    }
    
    NSString *serialNoRawVal = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialNo"];
    NSArray *ar_SerialNo = [serialNoRawVal componentsSeparatedByString:@":"];
    if( ar_SerialNo.count <= 1 ) { return  nil; }
    
    NSMutableString *contryCodeRawVal = [NSMutableString string];
    for( NSInteger i = 0; i < 2; i++ ) {
        [contryCodeRawVal appendString:ar_SerialNo[i]];
    }
    
//    NSString *contryCode = [Util convertHexToAscii:contryCodeRawVal];
    NSString *str_DeviceType = [Util getDeviceType:contryCodeRawVal];
//    if( [contryCode isEqualToString:@"KR"] || [contryCode isEqualToString:@"US"] ) {
    if( [str_DeviceType isEqualToString:@"B"] ) {
        //B 타입
        NSMutableString *strM_JoinSerialNoRawVal = [NSMutableString string];
        for( NSString *str in ar_SerialNo ) {
            [strM_JoinSerialNoRawVal appendString:str];
        }
        NSString *str_SerialNoAscii = [Util convertHexToAscii:strM_JoinSerialNoRawVal];
        
        NSMutableString *strM_MacCode = [NSMutableString string];
        NSArray *ar_MacAddr = [macAddr componentsSeparatedByString:@":"];
        for( NSString *str in ar_MacAddr ) {
            [strM_MacCode appendString:str];
        }
        
        NSString *str_SerialNo = [NSString stringWithFormat:@"%@%@0203", str_SerialNoAscii, [strM_MacCode capitalizedString]];
        NSLog(@"complete serialNo : %@", str_SerialNo);
        return str_SerialNo;
    } else {
        //A타입
//        macAddr = [macAddr stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        return [NSString stringWithFormat:@"KRCCPYNN26E%@0001", macAddr];
        
        NSArray *ar_MacAddr = [macAddr componentsSeparatedByString:@":"];
        if( ar_MacAddr.count <= 1 ) { return nil; }

        NSString *front = @"";
        NSString *serialChar = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialChar"];
        if( serialChar == nil || serialChar.length <= 0 ) {
//        if( 1 ) {
            front = @"KRCCPYNN26E";
        } else {
            front = serialChar;
        }

#ifdef DEBUG
        //처음 이걸로 연동되어 있어서 해제가 안되기 때문에 얘네는 이걸 사용
        if( [macAddr hasSuffix:@"07:c6"] || [macAddr hasSuffix:@"28:6a"] ) {
            front = @"KRCCPYNN26E";
        }
#endif
        NSString *str_MacCode = [NSString stringWithFormat:@"%@%@", ar_MacAddr[ar_MacAddr.count - 2], ar_MacAddr[ar_MacAddr.count - 1]];
        NSString *str_SerialNo = [NSString stringWithFormat:@"%@%@0001", front, [str_MacCode capitalizedString]];
        NSLog(@"complete serialNo : %@", str_SerialNo);
        return str_SerialNo;
    }
    
    return nil;
}

+ (NSString *)getDeviceType:(NSString *)hex {
    if( [hex isEqualToString:@"4b52"] || [hex isEqualToString:@"4B52"] || [hex isEqualToString:@"5553"] ) {
        return @"B";
    }
    return @"A";
}

+ (NSString *)convertHexToAscii:(NSString *)hex {
    NSMutableString *ascii = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [hex length]){
        NSString * hexChar = [hex substringWithRange: NSMakeRange(i, 2)];
        int value = 0;

        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [ascii appendFormat:@"%c", (char)value];
        i += 2;
    }
    NSLog(@"contryCode : %@", ascii);
    return ascii;
}

+ (NSString *)getDateString:(NSDate *)date withTimeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if( timeZone != nil ) {
        [format setTimeZone:timeZone];
    }
    NSString *dateString = [format stringFromDate:date];
    return dateString;
}

+ (NSString *)makeKey:(NSString *)key {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    return [NSString stringWithFormat:@"%@_%@", email, key];
}

+ (void)topRound:(UIView *)view {
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: view.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.}].CGPath;
    view.layer.mask = maskLayer;
}

@end
