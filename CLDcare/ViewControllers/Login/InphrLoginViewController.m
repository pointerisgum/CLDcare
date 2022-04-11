//
//  InphrLoginViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import "InphrLoginViewController.h"
#import "ClausePopUpViewController.h"

@interface InphrLoginViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_Bottom;
@property (weak, nonatomic) IBOutlet UITextField *tf_Email;
@property (weak, nonatomic) IBOutlet UITextField *tf_Pw;
@end

@implementation InphrLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef DEBUG
//    _tf_Email.text = @"pilltest1@gmail.com";
//    _tf_Pw.text = @"qwer1234!";
    _tf_Email.text = @"plzallyme";
    _tf_Pw.text = @"!!1010Kk";
#endif
    [_tf_Email becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    
    _lc_Bottom.constant = keyboardBounds.size.height + 10;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

//- (void)keyboardWillHide:(NSNotification *)notification {
//    [UIView animateWithDuration:0.3f animations:^{
//        self.lc_Bottom.constant = 0;
//    }];
//}

- (void)InphrLogin:(NSString *)loginType {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    //I로 보내고 결과가 없으면 약관동의 팝업 띄운 후 다시 T로 로긴 시도 (I는 둘 다 가입 된 상태, T는 inphr만 가입 된 상태)
    [dicM_Params setObject:loginType forKey:@"mem_login_type"];
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    [dicM_Params setObject:_tf_Email.text forKey:@"mem_email"];
    [dicM_Params setObject:_tf_Pw.text forKey:@"mem_password"];
    [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"auth/login" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            [Util showAlert:NSLocalizedString(@"Invalid ID or password", nil) withVc:self];
            return;
        }
        
        NSLog(@"%@", resulte);
        NSString *status = resulte[@"status"];
        NSString *accToken = resulte[@"access_token"];
        NSString *inphrToken = resulte[@"inphr_token"];
        NSString *uId = resulte[@"mem_uid"];
        NSString *refToken = resulte[@"refresh_token"];
        NSString *email = resulte[@"mem_email"];

        //inphr만 가입 된 경우
        //콜디 약관 동의 팝업을 띄운 후 로그인 타입을 T로 해서 다시 로긴 태운다
        if( resulte == nil || accToken == nil || accToken.length <= 0 || [status isEqualToString:@"need to term agreement"] ) {
            ClausePopUpViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"ClausePopUpViewController"];
            [vc setClauseComplete:^{
                [self InphrLogin:@"T"];
            }];
            [self presentViewController:vc animated:true completion:nil];
            return;
        }

        [[NSUserDefaults standardUserDefaults] setObject:accToken != nil ? accToken : @"" forKey:@"AccToken"];
        [[NSUserDefaults standardUserDefaults] setObject:inphrToken != nil ? inphrToken : @"" forKey:@"InphrToken"];
        [[NSUserDefaults standardUserDefaults] setObject:uId != nil ? uId : @"" forKey:@"UId"];
        [[NSUserDefaults standardUserDefaults] setObject:refToken != nil ? refToken : @"" forKey:@"RefToken"];
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"UserEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:self.tf_Email.text forKey:@"InphrEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:self.tf_Pw.text forKey:@"UserPw"];
        [[NSUserDefaults standardUserDefaults] setObject:@"I" forKey:@"LoginType"];
        
        NSString *firstName = resulte[@"mem_first_name"];
        NSString *lastName = resulte[@"mem_last_name"];
        [[NSUserDefaults standardUserDefaults] setObject:firstName != nil ? firstName : @"" forKey:@"mem_first_name"];
        [[NSUserDefaults standardUserDefaults] setObject:lastName != nil ? lastName : @"" forKey:@"mem_last_name"];

        [[NSUserDefaults standardUserDefaults] synchronize];

        [self dismissViewControllerAnimated:true completion:^{
            if( self.completionBlock ) {
                self.completionBlock(false);
            }
        }];
    }];
}

- (IBAction)goLogin:(id)sender {
    if( _tf_Email.text.length <= 0 || _tf_Pw.text.length <= 0 ) { return; }
    
    [self InphrLogin:@"I"];
}

- (IBAction)goFindIdPw:(id)sender {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == _tf_Email ) {
        [_tf_Pw becomeFirstResponder];
    } else {
        [self goLogin:nil];
    }
    return true;
}

@end
