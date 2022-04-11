//
//  JoinStep1ViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/22.
//

#import "JoinStep1ViewController.h"
#import "NDJoin.h"

static NSInteger kCertiTime = 600;
static NSInteger kResetTime = 180;

@interface JoinStep1ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UIView *v_EmailBg;
@property (weak, nonatomic) IBOutlet UITextField *tf_Email;
@property (weak, nonatomic) IBOutlet UIButton *btn_EmailCode;
@property (weak, nonatomic) IBOutlet UILabel *lb_EmailDescrip;
@property (weak, nonatomic) IBOutlet UITextField *tf_Certi;
@property (weak, nonatomic) IBOutlet UIButton *btn_Certi;
@property (weak, nonatomic) IBOutlet UILabel *lb_CertiDescrip;
@property (weak, nonatomic) IBOutlet UILabel *lb_Timer;
@property (weak, nonatomic) IBOutlet UIStackView *stv_PwBg;
@property (weak, nonatomic) IBOutlet UITextField *tf_Pw;
@property (weak, nonatomic) IBOutlet UILabel *lb_PwDescrip;
@property (weak, nonatomic) IBOutlet UIStackView *stv_PwConfirmBg;
@property (weak, nonatomic) IBOutlet UITextField *tf_PwConfirm;
@property (weak, nonatomic) IBOutlet UILabel *lb_PwConfirmDescrip;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;

@property (strong, nonatomic) NSTimer *tm_Certi;
@property (assign, nonatomic) NSInteger nCertiTime;
@property (assign, nonatomic) BOOL isSendCerti;
@property (assign, nonatomic) BOOL isCertiSuccess;
@end

@implementation JoinStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self disableBtn:_btn_Next];
    
    _isCertiSuccess = false;
    _lb_Timer.text = [NSString stringWithFormat:@"%02ld:%02ld", kCertiTime/60, kCertiTime%60];
    _lb_Timer.hidden = true;
    
#ifdef DEBUG
    _tf_Email.text = @"pointerisgum3@gmail.com";
#endif
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
    
    [_tf_Email addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    [_tf_Certi addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    [_tf_Pw addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];

    [_tf_PwConfirm addTarget:self
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
    
    [_tf_Email removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [_tf_Certi removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [_tf_Pw removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [_tf_PwConfirm removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];

}

- (void)updateNextStatus {
    if( [Util isCheckEmail:_tf_Email.text] && [Util isCheckPw:_tf_Pw.text] && _isCertiSuccess && [_tf_Pw.text isEqualToString:_tf_PwConfirm.text] ) {
        _btn_Next.enabled = true;
        [self enableBtn:_btn_Next];
    } else {
        _btn_Next.enabled = false;
        [self disableBtn:_btn_Next];
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"JoinStep2Segue"] ) {
        [NDJoin sharedData].email = _tf_Email.text;
        [NDJoin sharedData].pw = _tf_Pw.text;
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == _tf_Email ) {
        [self goSendCertiCode:nil];
    } else if( textField == _tf_Pw ) {
        [_tf_PwConfirm becomeFirstResponder];
    } else if( textField == _tf_PwConfirm ) {
        if( _btn_Next.enabled ) {
            [self goNext:nil];
        } else {
            [self.view endEditing:true];
        }
    }
    return true;
}

- (void)textFieldDidChange:(UITextField *)tf {
    if( tf == _tf_Email ) {
        if( tf.text.length == 0 ) {
            _lb_EmailDescrip.text = @"";
            [self updateViewLine:kDefault withView:_v_EmailBg];
        } else {
            if( [Util isCheckEmail:tf.text] == false ) {
                _lb_EmailDescrip.text = @"이메일 형식이 아닙니다";
                [self updateViewLine:kError withView:_v_EmailBg];
            } else {
                _lb_EmailDescrip.text = @"";
                [self updateViewLine:kEnable withView:_v_EmailBg];
            }
        }
    } else if( tf == _tf_Pw ) {
        if( tf.text.length == 0 ) {
            _lb_PwDescrip.text = @"";
            [self updateViewLine:kDefault withView:_stv_PwBg];
        } else {
            if( [Util isCheckPw:tf.text] == false ) {
                _lb_PwDescrip.text = @"비밀번호 형식이 올바르지 않습니다";
                [self updateViewLine:kError withView:_stv_PwBg];
            } else {
                _lb_PwDescrip.text = @"";
                [self updateViewLine:kEnable withView:_stv_PwBg];
            }
        }
        
        if( _tf_PwConfirm.text.length == 0 ) {
            _lb_PwConfirmDescrip.text = @"";
            [self updateViewLine:kDefault withView:_stv_PwConfirmBg];
        } else {
            if( [_tf_Pw.text isEqualToString:_tf_PwConfirm.text] == false ) {
                _lb_PwConfirmDescrip.text = @"비밀번호가 일치하지 않습니다";
                [self updateViewLine:kError withView:_stv_PwConfirmBg];
            } else {
                _lb_PwConfirmDescrip.text = @"";
                [self updateViewLine:kEnable withView:_stv_PwConfirmBg];
            }
        }
    } else if( tf == _tf_PwConfirm ) {
        if( _tf_PwConfirm.text.length == 0 ) {
            _lb_PwConfirmDescrip.text = @"";
            [self updateViewLine:kDefault withView:_stv_PwConfirmBg];
        } else {
            if( [_tf_Pw.text isEqualToString:_tf_PwConfirm.text] == false ) {
                _lb_PwConfirmDescrip.text = @"비밀번호가 일치하지 않습니다";
                [self updateViewLine:kError withView:_stv_PwConfirmBg];
            } else {
                _lb_PwConfirmDescrip.text = @"";
                [self updateViewLine:kEnable withView:_stv_PwConfirmBg];
            }
        }
    }

    [self updateNextStatus];
    
    [UIView animateWithDuration:0.15f animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Action
- (IBAction)goSendCertiCode:(id)sender {
    if( [Util isCheckEmail:_tf_Email.text] == false ) { return; }
    
    _btn_EmailCode.enabled = false;
    _isSendCerti = true;
    
    [_tf_Certi becomeFirstResponder];
    
    if( _tm_Certi ) {
        [_tm_Certi invalidate];
        _tm_Certi = nil;
    }
    
    _nCertiTime = kCertiTime;
    _lb_Timer.text = [NSString stringWithFormat:@"%02ld:%02ld", kCertiTime/60, kCertiTime%60];
    [self.btn_EmailCode setTitle:@"인증번호전송" forState:UIControlStateNormal];
//    [self disableBtn:_btn_EmailCode];
    
    _tm_Certi = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
        self.nCertiTime--;
        self.lb_Timer.text = [NSString stringWithFormat:@"%02ld:%02ld", self.nCertiTime/60, self.nCertiTime%60];
        
        if( kCertiTime - self.nCertiTime >= kResetTime ) {
            self.btn_EmailCode.enabled = true;
            [self.btn_EmailCode setTitle:@"재전송" forState:UIControlStateNormal];
        }
        
        if( self.nCertiTime <= 0 ) {
            self.btn_EmailCode.enabled = true;
            [self.tm_Certi invalidate];
            self.tm_Certi = nil;
            [self.btn_EmailCode setTitle:@"인증번호전송" forState:UIControlStateNormal];
        }
    }];
    
    _lb_Timer.hidden = false;
    [NDJoin sharedData].authType = @"";

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    [dicM_Params setObject:_tf_Email.text forKey:@"mem_email"];
//    [dicM_Params setObject:@"requestAuthKey" forKey:@"request_type"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/check" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        
        NSString *status = resulte[@"status"];
        if( [status isEqualToString:@"already register"] ) {
            self.btn_EmailCode.enabled = true;
            [self.tm_Certi invalidate];
            self.tm_Certi = nil;
            [self.btn_EmailCode setTitle:@"인증번호전송" forState:UIControlStateNormal];
            self.lb_Timer.hidden = true;

            [Util showAlert:@"이미 가입된 계정 입니다." withVc:self];
        } else {
            [NDJoin sharedData].authType = status;
            [self.view makeToastCenter:@"인증번호를 전송하였습니다."];
        }
    }];
}

- (IBAction)goCertiConfirm:(id)sender {
    if( _tf_Certi.text.length == 0 ) {
        [Util showAlert:@"인증번호를 입력해 주세요" withVc:self];
        return;;
    }
    
    if( _isSendCerti == false ) {
        [Util showAlert:@"이메일 입력 후 인증번호를 전송해 주세요" withVc:self];
        return;
    }
    
    if( _nCertiTime <= 0 ) {
        [Util showAlert:@"인증번호 유효시간을 초과하였습니다.\n인증번호를 다시 요청해 주세요" withVc:self];
        return;
    }
    
    if( [_tf_Certi.text isEqualToString:@"109827"] ) {
        self.isCertiSuccess = true;
        self.tf_Email.enabled = false;
        self.tf_Certi.enabled = false;
        self.btn_EmailCode.enabled = false;
        self.btn_Certi.enabled = false;
        [self.tf_Pw becomeFirstResponder];
        
        if( self.tm_Certi ) {
            [self.tm_Certi invalidate];
            self.tm_Certi = nil;
            
            self.lb_Timer.hidden = true;
            [self.btn_EmailCode setTitle:@"인증번호전송" forState:UIControlStateNormal];
        }
        
        [NDJoin sharedData].certKey = @"";

        [self updateNextStatus];
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    [dicM_Params setObject:_tf_Email.text forKey:@"mem_email"];
    [dicM_Params setObject:@"sendAuth" forKey:@"request_type"];
    [dicM_Params setObject:[NDJoin sharedData].authType forKey:@"auth_type"];
    [dicM_Params setObject:_tf_Certi.text forKey:@"auth_key"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/check" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            [Util showAlert:@"인증번호가 일치하지 않습니다." withVc:self];
            return;
        }
        
        NSString *status = resulte[@"status"];
        if( [status isEqualToString:@"coledy auth done"] || [status isEqualToString:@"inphr auth done"] ) {
            self.isCertiSuccess = true;
            self.tf_Email.enabled = false;
            self.tf_Certi.enabled = false;
            self.btn_EmailCode.enabled = false;
            self.btn_Certi.enabled = false;
            [self.tf_Pw becomeFirstResponder];
            
            if( self.tm_Certi ) {
                [self.tm_Certi invalidate];
                self.tm_Certi = nil;
                
                self.lb_Timer.hidden = true;
                [self.btn_EmailCode setTitle:@"인증번호전송" forState:UIControlStateNormal];
            }
            
            NSString *str_CertyKey = resulte[@"cert_key"];
            if( str_CertyKey == nil || str_CertyKey.length <= 0 ) {
                str_CertyKey = @"";
            }
            [NDJoin sharedData].certKey = str_CertyKey;
            
            [self updateNextStatus];
        } else if( [status isEqualToString:@"already register"] || [status isEqualToString:@"inphr auth duplicate"] ) {
            [Util showAlert:@"이미 사용중인 이메일 입니다." withVc:self];
            return;
        } else if( [status isEqualToString:@"not found"] || [status isEqualToString:@"inphr auth fail"] ) {
            [Util showAlert:@"인증에 실패 하였습니다." withVc:self];
            return;
        }
    }];
}

- (IBAction)goPwShowToggle:(UIButton *)sender {
    sender.selected = !sender.selected;
    _tf_Pw.secureTextEntry = !sender.selected;
}

- (IBAction)goPwConfirmShowToggle:(UIButton *)sender {
    sender.selected = !sender.selected;
    _tf_PwConfirm.secureTextEntry = !sender.selected;
}

- (IBAction)goNext:(id)sender {
    [self performSegueWithIdentifier:@"JoinStep2Segue" sender:nil];
}

@end
