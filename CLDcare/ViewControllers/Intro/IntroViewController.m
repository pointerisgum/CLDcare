//
//  IntroViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import "IntroViewController.h"
#import "AESCrypt.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *str_EncPw = [AESCrypt encrypt:@"!!1212Ym" password:PW_AES_KEY];
//    [[NSUserDefaults standardUserDefaults] setObject:str_EncPw forKey:PW_AES_KEY];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
    NSString *str_UserEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *str_Pw = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPw"];
    NSString *str_LoginType = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginType"];
    
    BOOL isSNSMode = false;
    if( str_LoginType.length > 0 && [str_LoginType isEqualToString:@"E"] == false ) {
        isSNSMode = true;
    }
    if( isSNSMode || (str_UserEmail.length > 0 && str_Pw.length > 0 && str_LoginType.length > 0) ) {
        //오토 로그인
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        if( isSNSMode ) {
            NSString *snsToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"snsToken"];
            if( snsToken == nil || snsToken.length <= 0 ) {
                [SCENE_DELEGATE showLoginView];
                return;
            }
            [dicM_Params setObject:snsToken forKey:@"mem_token"];
        } else {
            [dicM_Params setObject:[Util sha256:str_Pw] forKey:@"mem_password"];
        }

        [dicM_Params setObject:str_LoginType forKey:@"mem_login_type"];
        [dicM_Params setObject:str_UserEmail forKey:@"mem_email"];
        [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"auth/login" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
                [SCENE_DELEGATE showLoginView];
                return;
            }
            
            NSString *accToken = resulte[@"access_token"];
//            NSString *inphrToken = resulte[@"inphr_token"];
            NSString *uId = resulte[@"mem_uid"];
            NSString *refToken = resulte[@"refresh_token"];
            [[NSUserDefaults standardUserDefaults] setObject:accToken != nil ? accToken : @"" forKey:@"AccToken"];
//            [[NSUserDefaults standardUserDefaults] setObject:inphrToken != nil ? inphrToken : @"" forKey:@"InphrToken"];
            [[NSUserDefaults standardUserDefaults] setObject:uId != nil ? uId : @"" forKey:@"UId"];
            [[NSUserDefaults standardUserDefaults] setObject:refToken != nil ? refToken : @"" forKey:@"RefToken"];
            
            NSString *firstName = resulte[@"mem_first_name"];
            NSString *lastName = resulte[@"mem_last_name"];
            [[NSUserDefaults standardUserDefaults] setObject:firstName != nil ? firstName : @"" forKey:@"mem_first_name"];
            [[NSUserDefaults standardUserDefaults] setObject:lastName != nil ? lastName : @"" forKey:@"mem_last_name"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [SCENE_DELEGATE showMainView];
        }];
    } else {
        //로그인 화면으로 이동
        [SCENE_DELEGATE showLoginView];
//        [SCENE_DELEGATE showMainView];
    }
    

//    NSString *str_UserPw = [AESCrypt decrypt:str_DecPw password:PW_AES_KEY];
//    NSLog(@"%@", str_UserPw);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
