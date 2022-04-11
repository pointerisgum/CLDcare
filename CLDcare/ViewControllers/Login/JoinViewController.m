//
//  JoinViewController.m
//  CLDcare
//
//  Created by 김영민 on 2021/10/15.
//

#import "JoinViewController.h"
#import "Join2ViewController.h"

static NSInteger kCertiTime = 600;
static NSInteger kResetTime = 180;

@interface JoinViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UIView *v_EmailBg;
@property (weak, nonatomic) IBOutlet UITextField *tf_Email;
@property (weak, nonatomic) IBOutlet UILabel *lb_EmailDescrip;
@property (weak, nonatomic) IBOutlet UITextField *tf_Pw;
@property (weak, nonatomic) IBOutlet UIStackView *stv_PwBg;
@property (weak, nonatomic) IBOutlet UILabel *lb_PwDescrip;
@property (weak, nonatomic) IBOutlet UITextField *tf_PwConfirm;
@property (weak, nonatomic) IBOutlet UILabel *lb_PwConfirmDescrip;
@property (weak, nonatomic) IBOutlet UIStackView *stv_PwConfirmBg;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_EmailFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_PwFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_PwConfirmFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_SendCert;
@end

@implementation JoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _lb_Title.text = NSLocalizedString(@"Register", nil);
    _lb_EmailFix.text = NSLocalizedString(@"E-mail address", nil);
    _lb_PwFix.text = NSLocalizedString(@"Enter the password", nil);
    _lb_PwConfirmFix.text = NSLocalizedString(@"Re enter the password", nil);

    _tf_Email.placeholder = NSLocalizedString(@"Enter the email", nil);
    _tf_Pw.placeholder = NSLocalizedString(@"8 digits password including upper and lowercase, number, special characters", nil);
    _tf_PwConfirm.placeholder = NSLocalizedString(@"8 digits password including upper and lowercase, number, special characters", nil);
    [_btn_SendCert setTitle:NSLocalizedString(@"Verification", nil) forState:UIControlStateNormal];
    [_btn_Next setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];

    [self disableBtn:_btn_Next];
    
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
    [_tf_Pw removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [_tf_PwConfirm removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
}

- (void)updateNextStatus {
    if( [Util isCheckEmail:_tf_Email.text] && [Util isCheckPw:_tf_Pw.text] && [_tf_Pw.text isEqualToString:_tf_PwConfirm.text] && _tf_Pw.text.length > 0 ) {
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
        [_tf_Pw becomeFirstResponder];
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
        if( _tf_Email.text.length == 0 ) {
            _lb_EmailDescrip.text = @"";
            [self updateViewLine:kDefault withView:_v_EmailBg];
        } else {
            if( [Util isCheckEmail:_tf_Email.text] == false ) {
                _lb_EmailDescrip.text = NSLocalizedString(@"This is not an e-mail format", nil);
                [self updateViewLine:kError withView:_v_EmailBg];
            } else {
                _lb_EmailDescrip.text = @"";
                [self updateViewLine:kEnable withView:_v_EmailBg];
            }
        }
    } else {
        if( _tf_Pw.text.length == 0 ) {
            _lb_PwDescrip.text = @"";
            [self updateViewLine:kDefault withView:_stv_PwBg];
        } else {
            if( [Util isCheckPw:_tf_Pw.text] == false ) {
                _lb_PwDescrip.text = NSLocalizedString(@"Invalid password format", nil);
                [self updateViewLine:kError withView:_stv_PwBg];
            } else {
                _lb_PwDescrip.text = @"";
                [self updateViewLine:kEnable withView:_stv_PwBg];
            }
        }
        
        if( _tf_PwConfirm.text.length == 0 ) {
            _lb_PwConfirmDescrip.text = @"";
            [self updateViewLine:kDefault withView:_stv_PwConfirmBg];
        } else if( [_tf_Pw.text isEqualToString:_tf_PwConfirm.text] == false ) {
            _lb_PwConfirmDescrip.text = NSLocalizedString(@"The passwords don't match", nil);
            [self updateViewLine:kError withView:_stv_PwConfirmBg];
        } else {
            _lb_PwConfirmDescrip.text = @"";
            [self updateViewLine:kEnable withView:_stv_PwConfirmBg];
        }
    }
        
    [self updateNextStatus];
    
    [UIView animateWithDuration:0.15f animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Action
- (IBAction)goPwShowToggle:(UIButton *)sender {
    sender.selected = !sender.selected;
    _tf_Pw.secureTextEntry = !sender.selected;
}

- (IBAction)goPwConfirmShowToggle:(UIButton *)sender {
    sender.selected = !sender.selected;
    _tf_PwConfirm.secureTextEntry = !sender.selected;
}

- (IBAction)goNext:(id)sender {
    Join2ViewController *vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"Join2ViewController"];
    vc.email = _tf_Email.text;
    vc.pw = _tf_Pw.text;
    [self.navigationController pushViewController:vc animated:true];
}

@end
