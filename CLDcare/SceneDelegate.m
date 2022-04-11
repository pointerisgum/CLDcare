//
//  SceneDelegate.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "SceneDelegate.h"
@import UserNotifications;

@interface SceneDelegate ()
@property (assign, nonatomic) BOOL isTodayDose;
@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

- (void)showMainView {
    [UIView animateWithDuration:0.3f animations:^{
        BOOL isAni = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:false];
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
        [UIView setAnimationsEnabled:isAni];
    }];
}

- (void)showLoginView {
    [UIView animateWithDuration:0.3f animations:^{
        BOOL isAni = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:false];
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavi"];
        [UIView setAnimationsEnabled:isAni];
    }];
}

- (void)createSurvey {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *macAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
    NSString *siralNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialNo"];
    
    if( email.length <= 0 || macAddr.length <= 0 || siralNo.length <= 0 ) { return; }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:macAddr forKey:@"mac_address"];
    [dicM_Params setObject:[Util convertSerialNo] forKey:@"serial_num"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/create" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        NSLog(@"%@", resulte);
        
        if( msgCode == SUCCESS ) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd"];
            NSString *str_ToDay = [format stringFromDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_Survey", str_ToDay]];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self surveyCheck];
        }
    }];
}

- (void)surveyCheck {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/remain" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        NSLog(@"%@", resulte);
        
        if( msgCode == SUCCESS ) {
            NSInteger nSurveySeq = [resulte[@"survey_seq"] integerValue];
            if( nSurveySeq > 0 ) {
                if( self.surveyCheckComplete ) {
                    self.surveyCheckComplete(resulte);
                }
            }
        }
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
        willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
   // Update the app interface directly.
 
    // Play a sound.
   completionHandler(UNNotificationPresentationOptionSound);
}

- (void)setTodayDose {
    _isTodayDose = true;
}

- (BOOL)getTodayDose {
    return _isTodayDose;
}

@end
