//
//  Join2ViewController.m
//  CLDcare
//
//  Created by 김영민 on 2021/12/28.
//

#import "Join2ViewController.h"
#import "ActionSheetPicker.h"

@interface Join2ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UITextField *tf_FirstName;
@property (weak, nonatomic) IBOutlet UITextField *tf_LastName;
@property (weak, nonatomic) IBOutlet UITextField *tf_BirthDay;
@property (weak, nonatomic) IBOutlet UIButton *btn_Male;
@property (weak, nonatomic) IBOutlet UIButton *btn_FeMale;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_NameFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_BirthFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_SexFix;
@end

@implementation Join2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _lb_Title.text = NSLocalizedString(@"Register", nil);
    _lb_NameFix.text = NSLocalizedString(@"Name", nil);
    _lb_BirthFix.text = NSLocalizedString(@"Date of Birth", nil);
    _lb_SexFix.text = NSLocalizedString(@"Sex", nil);
    _tf_FirstName.placeholder = NSLocalizedString(@"First Name", nil);
    _tf_LastName.placeholder = NSLocalizedString(@"Last Name", nil);
    _tf_BirthDay.placeholder = NSLocalizedString(@"ex) 19910123", nil);
    [_btn_Male setTitle:NSLocalizedString(@"Male", nil) forState:UIControlStateNormal];
    [_btn_FeMale setTitle:NSLocalizedString(@"Female", nil) forState:UIControlStateNormal];
    [_btn_Next setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];

    [self disableBtn:_btn_Next];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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

- (void)updateNextStatus {
//    if( (_btn_Male.selected || _btn_FeMale.selected) && _tf_FirstName.text.length > 0 && _tf_LastName.text.length > 0 && _tf_BirthDay.text.length > 0 ) {
    if( _tf_FirstName.text.length > 0 && _tf_LastName.text.length > 0 && _tf_BirthDay.text.length > 0 ) {
        _btn_Next.enabled = true;
        [self enableBtn:_btn_Next];
    } else {
        _btn_Next.enabled = false;
        [self disableBtn:_btn_Next];
    }
}

- (void)sendCerdCode {
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    if( _isGoogle ) {
//        [dicM_Params setObject:_UID forKey:@"mem_token"];
        [dicM_Params setObject:@"G" forKey:@"mem_login_type"];
        [dicM_Params setObject:_UID forKey:@"mem_password"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
        [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];
    } else if( _isApple ) {
//        [dicM_Params setObject:_UID forKey:@"mem_token"];
        [dicM_Params setObject:@"A" forKey:@"mem_login_type"];
        [dicM_Params setObject:_UID forKey:@"mem_password"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
        [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];
    } else {
        [dicM_Params setObject:[Util sha256:_pw] forKey:@"mem_password"];
        [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    }
    [dicM_Params setObject:_email forKey:@"mem_email"];
    [dicM_Params setObject:@"P" forKey:@"mem_user_type"];
    
    
    NSLog(@"%@", dicM_Params);
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/add" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode code) {
        if( error != nil ) {
            [Util showAlert:NSLocalizedString(@"The subscription information is incorrect.\nPlease try again", nil) withVc:self];
            return;
        }
        NSLog(@"%@", resulte);
        if( [resulte[@"message"] isEqualToString:@"Already registered member"] ) {
            [Util showAlertWindow:NSLocalizedString(@"Already registered member.", nil)];
            return;
        }
        NSString *accToken = resulte[@"access_token"];
        NSString *uId = resulte[@"mem_uid"];
        NSString *refToken = resulte[@"refresh_token"];
        [[NSUserDefaults standardUserDefaults] setObject:accToken != nil ? accToken : @"" forKey:@"AccToken"];
        [[NSUserDefaults standardUserDefaults] setObject:uId != nil ? uId : @"" forKey:@"UId"];
        [[NSUserDefaults standardUserDefaults] setObject:refToken != nil ? refToken : @"" forKey:@"RefToken"];
        [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"UserEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:self.pw forKey:@"UserPw"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if( self.isGoogle ) {
            [[NSUserDefaults standardUserDefaults] setObject:@"G" forKey:@"LoginType"];

            NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:self.email forKey:@"mem_email"];
            [dicM_Params setObject:self.UID forKey:@"mem_token"];
            [dicM_Params setObject:@"G" forKey:@"mem_login_type"];
            [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];
            [self login:dicM_Params];
        } else if( self.isApple ) {
            [[NSUserDefaults standardUserDefaults] setObject:@"A" forKey:@"LoginType"];

            NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:self.email forKey:@"mem_email"];
            [dicM_Params setObject:self.UID forKey:@"mem_token"];
            [dicM_Params setObject:@"A" forKey:@"mem_login_type"];
            [dicM_Params setObject:token != nil ? token : @"" forKey:@"fcm_token"];
            [self login:dicM_Params];
        } else {
            [Util showConfirmAlret:self withMsg:NSLocalizedString(@"I have sent the authentication code.\nPlease check your authentication email and log in.", nil) completion:^(id result) {
                [self.navigationController popToRootViewControllerAnimated:true];
            }];
        }
    }];
}

- (void)login:(NSMutableDictionary *)params {
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"auth/login" param:params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            [Util showAlert:NSLocalizedString(@"Invalid ID or Password", nil) withVc:self];
            return;
        }
        NSLog(@"%@", resulte);

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
        
        NSString *firstName = resulte[@"mem_first_name"];
        NSString *lastName = resulte[@"mem_last_name"];
        [[NSUserDefaults standardUserDefaults] setObject:firstName != nil ? firstName : @"" forKey:@"mem_first_name"];
        [[NSUserDefaults standardUserDefaults] setObject:lastName != nil ? lastName : @"" forKey:@"mem_last_name"];
        [[NSUserDefaults standardUserDefaults] setObject:self.UID != nil ? self.UID : @"" forKey:@"snsToken"];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SCENE_DELEGATE showMainView];
    }];
}

- (void)textFieldDidChange:(UITextField *)tf {
    [self updateNextStatus];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if( textField == _tf_BirthDay ) {
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] self];
        NSDateComponents *comp = [[[NSDateComponents alloc] init] self];
        [comp setYear:1950];
        [comp setMonth:1];
        [comp setDay:1];
        NSDate *defualtDate = [calendar dateFromComponents:comp];
        

        [ActionSheetDatePicker showPickerWithTitle:NSLocalizedString(@"Date of Birth", nil)
                                    datePickerMode:UIDatePickerModeDate
                                      selectedDate:defualtDate
                                         doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
            NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:selectedDate];
            self.tf_BirthDay.text = [NSString stringWithFormat:@"%04ld%02ld%02ld", comp.year, comp.month, comp.day];
            [self updateNextStatus];
        } cancelBlock:^(ActionSheetDatePicker *picker) {
        } origin:textField];
        return false;
    }
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == _tf_FirstName ) {
        [_tf_LastName becomeFirstResponder];
    } else if( textField == _tf_LastName ) {
        [_tf_BirthDay becomeFirstResponder];
    }
    return true;
}


#pragma mark - Action
- (IBAction)goSexToggle:(UIButton *)sender {
    _btn_Male.selected = false;
    _btn_FeMale.selected = false;

    if( _btn_Male == sender ) {
        _btn_Male.selected = true;
        _btn_Male.layer.borderColor = [UIColor linkColor].CGColor;
        [_btn_Male setTitleColor:[UIColor linkColor] forState:UIControlStateNormal];
        _btn_FeMale.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;
        [_btn_FeMale setTitleColor:[UIColor colorWithHexString:@"8B8B8B"] forState:UIControlStateNormal];
    } else {
        _btn_FeMale.selected = true;
        _btn_FeMale.layer.borderColor = [UIColor linkColor].CGColor;
        [_btn_FeMale setTitleColor:[UIColor linkColor] forState:UIControlStateNormal];
        _btn_Male.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;
        [_btn_Male setTitleColor:[UIColor colorWithHexString:@"8B8B8B"] forState:UIControlStateNormal];
    }
    
    [self updateNextStatus];
}

- (IBAction)goNext:(id)sender {
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:_email forKey:@"mem_email"];
//    [dicM_Params setObject:_pw forKey:@"mem_password"];
//    [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    if( _isGoogle ) {
        [dicM_Params setObject:_UID forKey:@"mem_token"];
        [dicM_Params setObject:@"G" forKey:@"mem_login_type"];
    } else if( _isApple ) {
        [dicM_Params setObject:_UID forKey:@"mem_token"];
        [dicM_Params setObject:@"A" forKey:@"mem_login_type"];
    } else {
        [dicM_Params setObject:[Util sha256:_pw] forKey:@"mem_password"];
        [dicM_Params setObject:@"E" forKey:@"mem_login_type"];
    }

    [dicM_Params setObject:@"P" forKey:@"mem_user_type"];
    [dicM_Params setObject:_tf_FirstName.text forKey:@"mem_first_name"];
    [dicM_Params setObject:_tf_LastName.text forKey:@"mem_last_name"];
//    [dicM_Params setObject:_btn_Male.selected ? @"M" : @"F" forKey:@"mem_gender"];
    [dicM_Params setObject:@"" forKey:@"mem_gender"];
    [dicM_Params setObject:_tf_BirthDay.text forKey:@"mem_birthday"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/check" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        
        if( [resulte[@"result"] isKindOfClass:[NSDictionary class]] ) {
            NSInteger nUid = [resulte[@"result"][@"mem_uid"] integerValue];
            if( nUid > 0 ) {
                [Util showAlert:NSLocalizedString(@"This account is already registered", nil) withVc:self];
            } else {
                [self sendCerdCode];
            }
        } else {
            BOOL isOk = [resulte[@"result"] boolValue];
            if( isOk == false ) {
                [Util showAlert:NSLocalizedString(@"This account is already registered", nil) withVc:self];
            } else {
                [self sendCerdCode];
            }
        }
    }];
}

@end
