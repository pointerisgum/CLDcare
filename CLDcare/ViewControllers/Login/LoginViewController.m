//
//  LoginViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import "LoginViewController.h"
#import "InphrLoginViewController.h"
#import "ClausePopUpViewController.h"
#import "Join2ViewController.h"
#import "ClauseViewController.h"
@import FirebaseAuth;
@import AuthenticationServices;
@import Firebase;
@import GoogleSignIn;
@import CommonCrypto;

@interface LoginViewController () <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UITextField *tf_Email;
@property (weak, nonatomic) IBOutlet UITextField *tf_Pw;
@property (weak, nonatomic) IBOutlet UIButton *btn_Login;
@property (weak, nonatomic) IBOutlet UIButton *btn_Join;
@property (weak, nonatomic) IBOutlet UIButton *btn_Google;
@property (weak, nonatomic) IBOutlet UIStackView *stv_Apple;
@property (nonatomic, strong) NSString *currentNonce;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _btn_Google.layer.borderWidth = 1;
    _btn_Google.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    
    ASAuthorizationAppleIDButton *btn_Apple = [ASAuthorizationAppleIDButton new];
    [btn_Apple addTarget:self action:@selector(goAppleLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_stv_Apple addArrangedSubview:btn_Apple];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _tf_Email.placeholder = NSLocalizedString(@"E-mail address", nil);
    _tf_Pw.placeholder = NSLocalizedString(@"Password", nil);
    [_btn_Login setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
    [_btn_Join setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];

    NSString *str_Email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( str_Email.length > 0 ) {
        _tf_Email.text = str_Email;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
#ifdef DEBUG
    _tf_Email.text = @"pointerisgum@gmail.com";
    _tf_Pw.text = @"!!1010Kk";
#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    _sv_Main.contentInset = UIEdgeInsetsMake(_sv_Main.contentInset.top, _sv_Main.contentInset.left, keyboardBounds.size.height, _sv_Main.contentInset.right);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _sv_Main.contentInset = UIEdgeInsetsZero;
}

- (void)login:(NSMutableDictionary *)params {
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"auth/login" param:params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            [Util showAlert:NSLocalizedString(@"Invalid ID or Password", nil) withVc:self];
            return;
        }
        NSLog(@"%@", resulte);
        /*
         "access_token" = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2Mjg2NTEyNTksIm1lbV91aWQiOiIyNjkifQ.9TXXOts8ebIv6BlWwSyKSNCqd1nNR81CUqwB59MMQyc";
         "inphr_access_token" = "mMv41LFKKOkoxLEwwkpCGdmg57w65JSuSVYNZwMIPCIE9JjEIS0AnMesYtdk1ZIocTQ2k5eu260qDi2vxwuitA==";
         "mem_email" = "pointerisgum@gmail.com";
         "mem_first_name" = "\Uc601\Ubbfc";
         "mem_last_name" = "\Uae40";
         "mem_nickname" = "\Ud68c\Uc6d0";
         "mem_uid" = 269;
         "refresh_token" = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2NjAxMDA4NTksIm1lbV91aWQiOiIyNjkifQ.jttkUYCQCigpCu0gdGCoFDm9QOINofksmd8VxD6KJIU";
         */
        NSString *accToken = resulte[@"access_token"];
//        NSString *inphrToken = resulte[@"inphr_access_token"];
        NSString *uId = resulte[@"mem_uid"];
        NSString *refToken = resulte[@"refresh_token"];
        if( accToken == nil || uId == nil ) {
            [Util showAlert:NSLocalizedString(@"Invalid ID or password", nil) withVc:self];
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:accToken != nil ? accToken : @"" forKey:@"AccToken"];
//        [[NSUserDefaults standardUserDefaults] setObject:inphrToken != nil ? inphrToken : @"" forKey:@"InphrToken"];
        [[NSUserDefaults standardUserDefaults] setObject:uId != nil ? uId : @"" forKey:@"UId"];
        [[NSUserDefaults standardUserDefaults] setObject:refToken != nil ? refToken : @"" forKey:@"RefToken"];
        
        NSString *loginType = params[@"mem_login_type"];
        if( [loginType isEqualToString:@"E"] ) {
            [[NSUserDefaults standardUserDefaults] setObject:self.tf_Email.text forKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:self.tf_Pw.text forKey:@"UserPw"];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:params[@"mem_email"] forKey:@"UserEmail"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:params[@"mem_login_type"] forKey:@"LoginType"];
        
        NSString *firstName = resulte[@"mem_first_name"];
        NSString *lastName = resulte[@"mem_last_name"];
        [[NSUserDefaults standardUserDefaults] setObject:firstName != nil ? firstName : @"" forKey:@"mem_first_name"];
        [[NSUserDefaults standardUserDefaults] setObject:lastName != nil ? lastName : @"" forKey:@"mem_last_name"];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SCENE_DELEGATE showMainView];
    }];
}

- (NSString *)randomNonce:(NSInteger)length {
    NSAssert(length > 0, @"Expected nonce to have positive length");
    NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
    NSMutableString *result = [NSMutableString string];
    NSInteger remainingLength = length;
    
    while (remainingLength > 0) {
        NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
        for (NSInteger i = 0; i < 16; i++) {
            uint8_t random = 0;
            int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
            NSAssert(errorCode == errSecSuccess, @"Unable to generate nonce: OSStatus %i", errorCode);
            
            [randoms addObject:@(random)];
        }
        
        for (NSNumber *random in randoms) {
            if (remainingLength == 0) {
                break;
            }
            
            if (random.unsignedIntValue < characterSet.length) {
                unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
                [result appendFormat:@"%C", character];
                remainingLength--;
            }
        }
    }
    
    return [result copy];
}

- (NSString *)stringBySha256HashingString:(NSString *)input {
    const char *string = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, (CC_LONG)strlen(string), result);
    
    NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hashed appendFormat:@"%02x", result[i]];
    }
    return hashed;
}
    

- (IBAction)goLogin:(id)sender {
    /*
     //apple = A
     //google = G
     @"mem_login_type" = "G"
     @"mem_token" = "파이어베이스에서 받은 토큰 전달" (소설 로긴시 mem_password는 안보냄)
     */
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    [dicM_Params setObject:_tf_Email.text forKey:@"mem_email"];
    [dicM_Params setObject:[Util sha256:_tf_Pw.text] forKey:@"mem_password"];
    [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];
    
    [self login:dicM_Params];
}

//- (IBAction)goJoin:(id)sender {
//#ifdef DEBUG
//    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"JoinStep2ViewController"];
//    [self.navigationController pushViewController:vc animated:true];
//#else
//    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClauseViewController"];
//    [self.navigationController pushViewController:vc animated:true];
//#endif
//}

- (IBAction)goFindId:(id)sender {
    
}

- (IBAction)goFindPw:(id)sender {

}

- (IBAction)goInphrLogin:(id)sender {
//    InphrLoginViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"InphrLoginViewController"];
//    [vc setCompletionBlock:^(BOOL isShowClause) {
//        if( isShowClause ) {
//            UINavigationController *navi = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClauseNavi"];
//            ClausePopUpViewController *vc = navi.viewControllers.firstObject;
//            [vc setClauseComplete:^{
//                [SCENE_DELEGATE showMainView];
//            }];
//            [self presentViewController:navi animated:true completion:nil];
//        } else {
//            [SCENE_DELEGATE showMainView];
//        }
//    }];
//    [self presentViewController:vc animated:true completion:^{
//        
//    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == _tf_Email ) {
        [_tf_Pw becomeFirstResponder];
    } else {
        [self goLogin:nil];
    }
    return true;
}


- (IBAction)goGoogleLogin:(id)sender {
    GIDConfiguration *config = [[GIDConfiguration alloc] initWithClientID:[FIRApp defaultApp].options.clientID];
    
    __weak __auto_type weakSelf = self;
    [GIDSignIn.sharedInstance signInWithConfiguration:config presentingViewController:self callback:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
        __auto_type strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        if (error == nil) {
            GIDAuthentication *authentication = user.authentication;
            FIRAuthCredential *credential =
            [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                             accessToken:authentication.accessToken];
            [[FIRAuth auth] signInWithCredential:credential
                                      completion:^(FIRAuthDataResult * _Nullable authResult,
                                                   NSError * _Nullable error) {
                if( authResult.user.emailVerified == true ) {
                    if( authResult.user.uid.length > 0 ) {
                        //1.이미 가입 된 유저인지 체크
                        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                        [dicM_Params setObject:@"G" forKey:@"mem_login_type"];
                        [dicM_Params setObject:authResult.user.email forKey:@"mem_email"];
                        [dicM_Params setObject:authResult.user.uid forKey:@"mem_token"];
                        [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/check" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                            if( error != nil ) {
                                return;
                            }
                            
                            NSInteger nResult = [resulte[@"result"] integerValue];
                            if( nResult == 0 ) {
                                //1_1.가입 된 회원의 경우 로그인 처리
                                NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
                                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                                [dicM_Params setObject:authResult.user.email forKey:@"mem_email"];
                                [dicM_Params setObject:authResult.user.uid forKey:@"mem_token"];
                                [dicM_Params setObject:@"G" forKey:@"mem_login_type"];
                                [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];
                                [self login:dicM_Params];
                            } else {
                                
                                //1_2.가입되지 않은 유저는 구글로부터 받은 정보를 바탕으로 회원가입 진행
                                ClauseViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClauseViewController"];
                                vc.email = authResult.user.email;
                                vc.isGoogle = true;
                                vc.UID = authResult.user.uid;
                                [self.navigationController pushViewController:vc animated:true];
                            }
                        }];
                    }
                }
            }];
        } else {
            NSLog(@"%@", error);
            [Util showAlert:NSLocalizedString(@"An error has occurred.", nil) withVc:self];
        }
    }];
}

- (IBAction)goAppleLogin:(id)sender {
    NSString *nonce = [self randomNonce:32];
    self.currentNonce = nonce;
    ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
    ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    request.nonce = [self stringBySha256HashingString:nonce];
    
    ASAuthorizationController *authorizationController =
    [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    authorizationController.delegate = self;
    authorizationController.presentationContextProvider = self;
    [authorizationController performRequests];
}


#pragma mark - ASAuthorizationControllerDelegate
- (void)authorizationController:(ASAuthorizationController *)controller
   didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *rawNonce = self.currentNonce;
        NSAssert(rawNonce != nil, @"Invalid state: A login callback was received, but no login request was sent.");
        
        if (appleIDCredential.identityToken == nil) {
            NSLog(@"Unable to fetch identity token.");
            return;
        }
        
        NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken
                                                  encoding:NSUTF8StringEncoding];
        if (idToken == nil) {
            NSLog(@"Unable to serialize id token from data: %@", appleIDCredential.identityToken);
        }
        
        // Initialize a Firebase credential.
        FIROAuthCredential *credential = [FIROAuthProvider credentialWithProviderID:@"apple.com"
                                                                            IDToken:idToken
                                                                           rawNonce:rawNonce];
        
        // Sign in with Firebase.
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRAuthDataResult * _Nullable authResult,
                                               NSError * _Nullable error) {
            if (error != nil) {
                [Util showAlert:NSLocalizedString(@"Sign in with Apple errored.", nil) withVc:self];
                return;
            }
            // Sign-in succeeded!
            if( authResult.user.emailVerified == true ) {
                if( authResult.user.uid.length > 0 ) {
                    //1.이미 가입 된 유저인지 체크
                    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                    [dicM_Params setObject:@"A" forKey:@"mem_login_type"];
                    [dicM_Params setObject:authResult.user.email forKey:@"mem_email"];
                    [dicM_Params setObject:authResult.user.uid forKey:@"mem_token"];
                    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/check" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                        if( error != nil ) {
                            return;
                        }
                        
                        NSInteger nResult = [resulte[@"result"] integerValue];
                        if( nResult == 0 ) {
                            //1_1.가입 된 회원의 경우 로그인 처리
                            NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
                            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                            [dicM_Params setObject:authResult.user.email forKey:@"mem_email"];
                            [dicM_Params setObject:authResult.user.uid forKey:@"mem_token"];
                            [dicM_Params setObject:@"A" forKey:@"mem_login_type"];
                            [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];
                            [self login:dicM_Params];
                        } else {
                            
                            //1_2.가입되지 않은 유저는 구글로부터 받은 정보를 바탕으로 회원가입 진행
                            ClauseViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClauseViewController"];
                            vc.email = authResult.user.email;
                            vc.isApple = true;
                            vc.UID = authResult.user.uid;
                            [self.navigationController pushViewController:vc animated:true];
                        }
                    }];
                }
            }
        }];
    }
}
//uid: MKUNB8LU5teWyOeW2PbBX15SR1v1
- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    NSLog(@"Sign in with Apple errored: %@", error);
}

@end
