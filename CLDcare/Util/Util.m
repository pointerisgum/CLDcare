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
#import "PopUpViewController.h"
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
                               otherButtonTitles:@[NSLocalizedString(@"Confirm", nil)]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        completion(@"");
    }];
}

+ (NSString *)getAppStoreVersion {
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([lookup[@"resultCount"] integerValue] == 1)
    {
        NSString* appStoreVersion = lookup[@"results"][0][@"version"];
        NSLog(@"AppStore Version : %@", appStoreVersion);
        return appStoreVersion;
    }
    
    return @"";
}

+ (UpdateStatus)needsUpdate {
    //+ (BOOL)needsUpdate {
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if( [lookup[@"resultCount"] integerValue] == 1 ) {
        NSString* appStoreVersion = lookup[@"results"][0][@"version"];
        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
        NSArray *store = [appStoreVersion componentsSeparatedByString:@"."];
        NSArray *current = [currentVersion componentsSeparatedByString:@"."];
        if( store.count == 3 && current.count == 3 ) {
            if( ([store[0] integerValue] > [current[0] intValue]) || ([store[1] intValue] > [current[1] intValue])) {
                //강제 업데이트
                return Require;
            } else if( [store[2] integerValue] > [current[2] intValue] ) {
                //선택 업데이트
                return Optional;
            }
            /*
             else {
             if (([store[0] integerValue] == [current[0] intValue]) && ([store[1] intValue] > [current[1] intValue]) ) {
             if( [store[2] integerValue] > [current[2] intValue] ) {
             //선택 업데이트
             return Optional;
             }
             }
             }
             */
        }
    }
    //최신 버전
    return Latest;
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hour"
                                               ascending:YES];
    NSArray *sortArray = [arM_Alarms sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [[NSUserDefaults standardUserDefaults] setObject:sortArray forKey:@"Alarms"];
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
        
        //        NSString *str_SerialNo = [NSString stringWithFormat:@"%@%@0203", str_SerialNoAscii, [strM_MacCode capitalizedString]];
        //시리얼 넘버 조합시 0203(펌웨어버전)은 빼고 보대달라고 요청옴 22.10.05 이규관
        NSString *str_SerialNo = [NSString stringWithFormat:@"%@%@", str_SerialNoAscii, [strM_MacCode capitalizedString]];
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
    [[NSUserDefaults standardUserDefaults] setObject:ascii forKey:@"ContryCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(view.bounds.origin.x, view.bounds.origin.y, [Util keyWindow].bounds.size.width, view.bounds.size.height) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    view.layer.mask = maskLayer;
}


+ (UpdateStatus)checkReqUpdate:(UIViewController *)vc {
    UpdateStatus updateStatus = [Util needsUpdate];
    if( updateStatus == Require ) {
        PopUpViewController *vc_PopUp = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
        vc_PopUp.isUpdateMode = true;
        vc_PopUp.updateStatus = Require;
        [vc_PopUp setPopUpDismissBlock:^{
            //            NSString *str_AppStoreLink = [NSString stringWithFormat:@"itms://itunes.apple.com/app/apple-store/id%@?mt=8", APP_STORE_ID];
            NSString *str_AppStoreLink = [NSString stringWithFormat:@"https://itunes.apple.com/kr/app/apple-store/id%@?mt=8", APP_STORE_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str_AppStoreLink] options:@{} completionHandler:nil];
        }];
        [vc presentViewController:vc_PopUp animated:true completion:^{
            
        }];
    }
    
    return updateStatus;
}

+ (void)firmWareDownload:(NSString *)fileName withCompletion:(void (^)(BOOL isSuccess))completion {
    NSLog(@"펌웨어 다운로드 시작");
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_async(queue, ^{
        NSString *contryCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"ContryCode"];
        NSString *stringURL = [NSString stringWithFormat:@"http://15.164.79.24/downloads/firmware/dfu/firmware/version/%@/%@_%@.zip", contryCode, contryCode, fileName];
        
        NSURL  *url = [NSURL URLWithString:stringURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        [[NSUserDefaults standardUserDefaults] setFloat:urlData.length forKey:@"FWSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //        //Find a cache directory. You could consider using documenets dir instead (depends on the data you are fetching)
        //        NSLog(@"Got the data!");
        //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        //        NSString *path = [paths  objectAtIndex:0];
        
        NSString *dataPath = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", fileName]];
        dataPath = [dataPath stringByStandardizingPath];
        [urlData writeToFile:dataPath atomically:YES];
        NSLog(@"펌웨어 다운로드 완료");
        
        completion(true);
    });
}

+ (void)deleteData {
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"oldName"];
    
    NSString *mac = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
    [[NSUserDefaults standardUserDefaults] setObject:mac forKey:@"oldMac"];

    NSInteger nBattery = [[[NSUserDefaults standardUserDefaults] objectForKey:@"battery"] integerValue];
    [[NSUserDefaults standardUserDefaults] setObject:@(nBattery) forKey:@"oldBattery"];

    NSString *serialNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialNo"];
    [[NSUserDefaults standardUserDefaults] setObject:serialNo forKey:@"oldSerialNo"];

    NSString *serialChar = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialChar"];
    [[NSUserDefaults standardUserDefaults] setObject:serialChar forKey:@"oldSerialChar"];

    
    [[NSUserDefaults standardUserDefaults] setObject:@"D" forKey:@"pair"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mac"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"battery"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"serialNo"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"serialChar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (Byte *)decrypt:(NSData *)manufData {
    //암호화 적용 된 펌웨어의 경우 복호화 처리 기능
    uint8_t xor_val[27] = {
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99 , 0xaa,
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99 , 0xaa,
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
    };
    
    int8_t revert_rotate_val[27] = {
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        -2, -2, -2, -2, -2, -2, -2
    };
    
    Byte *data = (Byte*)[manufData bytes];
    for( int j = 2; j < manufData.length; j++ ) {
        if( revert_rotate_val[j-2] < 0 ) {        // rotate left
            data[j] = (Byte)( (data[j] << (-revert_rotate_val[j-2])) | ( (Byte)(~((Byte)0x80 >> (8-(-revert_rotate_val[j-2])-1) )) & (Byte)(data[j] >> (8-(-revert_rotate_val[j-2]) )) ) );
            data[j] = (Byte)(data[j] ^ xor_val[j-2]);
        } else if( revert_rotate_val[j-2] > 0 ) {   // rotate right
            data[j] = (Byte)(( (~((Byte)0x80 >> (revert_rotate_val[j-2]-1))) & (Byte)(data[j] >> revert_rotate_val[j-2]) ) | (Byte)(data[j] << (8-revert_rotate_val[j-2])) );
            data[j] = (Byte)(data[j] ^ xor_val[j-2]);
        }
    }
    
    return data;
}

@end
