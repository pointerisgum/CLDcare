//
//  LoginViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import "LoginViewController.h"
#import "InphrLoginViewController.h"
#import "ClausePopUpViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UITextField *tf_Email;
@property (weak, nonatomic) IBOutlet UITextField *tf_Pw;
@property (weak, nonatomic) IBOutlet UIButton *btn_Login;
@property (weak, nonatomic) IBOutlet UIButton *btn_Join;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (IBAction)goLogin:(id)sender {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    [dicM_Params setObject:_tf_Email.text forKey:@"mem_email"];
    [dicM_Params setObject:[Util sha256:_tf_Pw.text] forKey:@"mem_password"];
    [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"auth/login" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
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
        [[NSUserDefaults standardUserDefaults] setObject:self.tf_Email.text forKey:@"UserEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:self.tf_Pw.text forKey:@"UserPw"];
        [[NSUserDefaults standardUserDefaults] setObject:@"E" forKey:@"LoginType"];
        
        NSString *firstName = resulte[@"mem_first_name"];
        NSString *lastName = resulte[@"mem_last_name"];
        [[NSUserDefaults standardUserDefaults] setObject:firstName != nil ? firstName : @"" forKey:@"mem_first_name"];
        [[NSUserDefaults standardUserDefaults] setObject:lastName != nil ? lastName : @"" forKey:@"mem_last_name"];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SCENE_DELEGATE showMainView];
    }];
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

@end
