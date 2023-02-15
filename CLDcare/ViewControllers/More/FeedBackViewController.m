//
//  FeedBackViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/09/13.
//

#import "FeedBackViewController.h"
#import "SurveryAccView.h"
#import <MBProgressHUD.h>
#import "UITextView+Placeholder.h"

@interface FeedBackViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UIView *v_TfBg;
@property (weak, nonatomic) IBOutlet UIView *v_TvBg;
@property (weak, nonatomic) IBOutlet UITextField *tf_Title;
@property (weak, nonatomic) IBOutlet UITextView *tv_Contents;
@property (weak, nonatomic) IBOutlet SurveryAccView *surveryAccView;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubjectFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_MessageFix;
@property (strong, nonatomic) MBProgressHUD* hud;
@end

@implementation FeedBackViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if( _isReport ) {
        _lb_Title.text = NSLocalizedString(@"Write a report", nil);
    } else {
        _lb_Title.text = NSLocalizedString(@"Send feedback", nil);
    }
    
    _lb_SubjectFix.text = NSLocalizedString(@"Subject", nil);
    _lb_MessageFix.text = NSLocalizedString(@"Message", nil);
    _tf_Title.placeholder = NSLocalizedString(@"Enter subject", nil);
    _tv_Contents.placeholder = NSLocalizedString(@"Enter your message", nil);

    [self setBorder:_v_TfBg withRadius:4];
    [self setBorder:_v_TvBg withRadius:4];
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIView *)inputAccessoryView {
    SurveryAccView *accView = [[[NSBundle mainBundle] loadNibNamed:@"SurveryAccView" owner:self options:nil] firstObject];
    [accView.btn_Cancel addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [accView.btn_Confirm addTarget:self action:@selector(onConfirm:) forControlEvents:UIControlEventTouchUpInside];
    return accView;
}

- (void)setBorder:(UIView *)view withRadius:(CGFloat)radius {
    view.clipsToBounds = true;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;
    view.layer.cornerRadius = radius;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    _sv_Main.contentInset = UIEdgeInsetsMake(_sv_Main.contentInset.top, _sv_Main.contentInset.left, keyboardBounds.size.height, _sv_Main.contentInset.right);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _sv_Main.contentInset = UIEdgeInsetsZero;
}


- (void)onCancel:(id)sender {
    if( _tf_Title.text.length > 0 || _tv_Contents.text.length > 0 ) {
        [UIAlertController showAlertInViewController:self
                                           withTitle:NSLocalizedString(@"If you cancel, the contents you are creating will disappear.\nWould you like to cancel?", nil)
                                             message:@""
                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[NSLocalizedString(@"confirm", nil)]
                                            tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
            if( action.style == UIAlertActionStyleDefault ) {
                [self.navigationController popViewControllerAnimated:true];
            }
        }];
    } else {
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void)onConfirm:(UIButton *)sender {
    if( _tf_Title.text.length <= 0 ) {
        [self.view makeToastCenter:NSLocalizedString(@"Enter subject", nil)];
        return;
    }

    if( _tv_Contents.text.length <= 0 ) {
        [self.view makeToastCenter:NSLocalizedString(@"Enter your message", nil)];
        return;
    }

    if (self.hud == nil) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [self.hud showAnimated:true];

    sender.userInteractionEnabled = false;
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:_tf_Title.text forKey:@"title"];
    [dicM_Params setObject:_tv_Contents.text forKey:@"content"];
    [dicM_Params setObject:str_NowDate forKey:@"datetime"];
    
    if( _isReport ) {
        [dicM_Params setObject:@"medication" forKey:@"type"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/contact" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        
        sender.userInteractionEnabled = true;
        [self.hud hideAnimated:true];

        if( error != nil ) {
            return;
        }
        NSLog(@"%@", resulte);
        
        if( msgCode == SUCCESS ) {
            if( self.isReport == false ) {
                [UIAlertController showAlertInViewController:self
                                                   withTitle:NSLocalizedString(@"Thank you for your feedback.", nil)
                                                     message:@""
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@[NSLocalizedString(@"confirm", nil)]
                                                    tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                    if( action.style == UIAlertActionStyleDefault ) {
                        [self.navigationController popViewControllerAnimated:true];
                    }
                }];
            } else {
                [self.navigationController popViewControllerAnimated:true];
            }
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == _tf_Title ) {
        [_tv_Contents becomeFirstResponder];
    }
    return true;
}

@end
