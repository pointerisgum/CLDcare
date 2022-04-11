//
//  JoinStep2ViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/22.
//

#import "JoinStep2ViewController.h"
#import "NDJoin.h"

@interface JoinStep2ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UITextField *tf_FirstName;
@property (weak, nonatomic) IBOutlet UITextField *tf_LastName;
@property (weak, nonatomic) IBOutlet UIView *v_BirthBg;
@property (weak, nonatomic) IBOutlet UITextField *tf_Birth;
@property (weak, nonatomic) IBOutlet UILabel *lb_BirthDescrip;
@property (weak, nonatomic) IBOutlet UIButton *btn_Man;
@property (weak, nonatomic) IBOutlet UIButton *btn_Woman;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@end

@implementation JoinStep2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self goGenderToggle:_btn_Man];
    [self disableBtn:_btn_Next];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [_tf_FirstName addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [_tf_LastName addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [_tf_Birth addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [_tf_FirstName removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [_tf_LastName removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [_tf_Birth removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
}

- (void)updateNextStatus {
    if( _tf_FirstName.text.length > 0 && _tf_LastName.text.length > 0 && [Util isCheckBirth:_tf_Birth.text] ) {
        _btn_Next.enabled = true;
        [self enableBtn:_btn_Next];
    } else {
        _btn_Next.enabled = false;
        [self disableBtn:_btn_Next];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"JoinFinishSegue"] ) {
    }
}


#pragma mark - Noti
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    _sv_Main.contentInset = UIEdgeInsetsMake(_sv_Main.contentInset.top, _sv_Main.contentInset.left, keyboardBounds.size.height, _sv_Main.contentInset.right);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _sv_Main.contentInset = UIEdgeInsetsZero;
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)tf {
    if( tf == _tf_Birth ) {
        if( tf.text.length == 0 ) {
            _lb_BirthDescrip.text = @"";
            [self updateViewLine:kDefault withView:_v_BirthBg];
        } else {
            if( [Util isCheckBirth:tf.text] == false ) {
                _lb_BirthDescrip.text = @"생년월일이 잘못되었습니다";
                [self updateViewLine:kError withView:_v_BirthBg];
            } else {
                _lb_BirthDescrip.text = @"";
                [self updateViewLine:kEnable withView:_v_BirthBg];
            }
        }
    }
    
    [self updateNextStatus];
    
    [UIView animateWithDuration:0.15f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == _tf_FirstName ) {
        [_tf_LastName becomeFirstResponder];
    } else if( textField == _tf_LastName ) {
        [_tf_Birth becomeFirstResponder];
    }
    return YES;
}


#pragma mark - Action
- (IBAction)goGenderToggle:(UIButton *)btn {
    btn.selected = true;
    [self enableBtnLayer:btn];
    
    if( btn == _btn_Man ) {
        _btn_Woman.selected = false;
        [self disableBtnLayer:_btn_Woman];
    } else if( btn == _btn_Woman ) {
        _btn_Man.selected = false;
        [self disableBtnLayer:_btn_Man];
    }
}

- (IBAction)goNext:(id)sender {
    
    [NDJoin sharedData].firstName = _tf_FirstName.text;
    [NDJoin sharedData].lastName = _tf_LastName.text;
    [NDJoin sharedData].birth = _tf_Birth.text;
    [NDJoin sharedData].gender = _btn_Man.selected ? @"M" : @"F";

    NSLog(@"%@", [Util sha256:[NDJoin sharedData].pw]);
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    [dicM_Params setObject:[NDJoin sharedData].email forKey:@"mem_email"];
    [dicM_Params setObject:[Util sha256:[NDJoin sharedData].pw] forKey:@"mem_password"];
    [dicM_Params setObject:@"P" forKey:@"mem_user_type"];
    [dicM_Params setObject:[NDJoin sharedData].firstName forKey:@"mem_first_name"];
    [dicM_Params setObject:[NDJoin sharedData].lastName forKey:@"mem_last_name"];
    [dicM_Params setObject:[NDJoin sharedData].gender forKey:@"mem_gender"];
    [dicM_Params setObject:[NDJoin sharedData].birth forKey:@"mem_birthday"];
    [dicM_Params setObject:[NDJoin sharedData].authType forKey:@"auth_type"];
    [dicM_Params setObject:[NDJoin sharedData].certKey forKey:@"cert_key"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/add" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode code) {
        if( error != nil ) {
            [Util showAlert:@"가입 정보가 올바르지 않습니다.\n다시 시도하여 주세요." withVc:self];
            return;
        }
        NSLog(@"%@", resulte);
        NSString *accToken = resulte[@"access_token"];
        NSString *inphrToken = resulte[@"inphr_token"];
        NSString *uId = resulte[@"mem_uid"];
        NSString *refToken = resulte[@"refresh_token"];
        [[NSUserDefaults standardUserDefaults] setObject:accToken != nil ? accToken : @"" forKey:@"AccToken"];
        [[NSUserDefaults standardUserDefaults] setObject:inphrToken != nil ? inphrToken : @"" forKey:@"InphrToken"];
        [[NSUserDefaults standardUserDefaults] setObject:uId != nil ? uId : @"" forKey:@"UId"];
        [[NSUserDefaults standardUserDefaults] setObject:refToken != nil ? refToken : @"" forKey:@"RefToken"];
        [[NSUserDefaults standardUserDefaults] setObject:[NDJoin sharedData].email forKey:@"UserEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:[NDJoin sharedData].pw forKey:@"UserPw"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];

    [self performSegueWithIdentifier:@"JoinFinishSegue" sender:nil];
}

@end
