//
//  AppDelegate.m
//  CLDcare
//
//  Created by 김영민 on 2021/09/29.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
@import UserNotifications;
@import Firebase;
@import GoogleSignIn;

//@import CryptoSwift;
//#import "CryptoSwift-Swift.h"

NSString *const kGCMMessageIDKey = @"gcm.message_id";

@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BOOL Init = ![[NSUserDefaults standardUserDefaults] boolForKey:@"Init"];
    if( Init ) {
//            if( 1 ) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"Init"];

        //알람 초기 등록
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"Alarm"];

        //서베이 토글
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"SurveyAlarm"];
        
        NSMutableArray *arM_Alarms = [NSMutableArray array];
        [arM_Alarms addObject:@{@"hour":@(8), @"min":@(30), @"on":@(false)}];
        [arM_Alarms addObject:@{@"hour":@(13), @"min":@(30), @"on":@(false)}];
        [arM_Alarms addObject:@{@"hour":@(19), @"min":@(30), @"on":@(false)}];
        [Util saveAlarm:arM_Alarms];

        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSString *str_FWUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWUpdateDate"];
    if( str_FWUpdateDate == nil || str_FWUpdateDate.length <= 0 ) {
        //펌웨어 업데이트 일자
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString *now = [dateFormatter stringFromDate:[NSDate date]];
        [[NSUserDefaults standardUserDefaults] setValue:now forKey:@"FWUpdateDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
    UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {

    }];
    
    [application registerForRemoteNotifications];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


//MARK: PUSH
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    NSString *fcmToken = [FIRMessaging messaging].FCMToken;
    NSLog(@"FCM registration token: %@", fcmToken);
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:fcmToken forKey:@"PushToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //iOS10 이상
    //앱 실행중에 푸시가 왔을때 또는 앱 백그라운드에서 푸시를 타고 들어왔을때
    
    //    ALERT_ONE(@"@@@@@@@");
    
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    if (userInfo[kGCMMessageIDKey])
    {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    //    completionHandler();
    
    //푸시를 타고 들어왔을때

    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    //포그라운드에서 푸시가 왔을때
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDashBoard" object:nil];
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    if (userInfo[kGCMMessageIDKey])
    {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
//    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    completionHandler(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert);
    //    completionHandler(UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    //푸시를 타고 들어왔을때
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    NSLog(@"%@", userInfo);

    completionHandler();
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}


//MARK: FireBase Push
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    
    
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options API_AVAILABLE(ios(9.0)) {
    NSLog(@"openURL : %@", url);
    return [[GIDSignIn sharedInstance] handleURL:url];
}

@end
