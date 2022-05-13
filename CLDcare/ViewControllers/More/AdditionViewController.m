//
//  AdditionViewController.m
//  CLDcare
//
//  Created by 김영민 on 2021/12/28.
//

#import "AdditionViewController.h"

@interface AdditionViewController ()
@property (nonatomic, assign) NSInteger selectedPhoneUse;
@property (nonatomic, strong) NSString *selectedMedicine;
@property (weak, nonatomic) IBOutlet UIScrollView *sv_Main;
@property (weak, nonatomic) IBOutlet UIButton *btn_30M;
@property (weak, nonatomic) IBOutlet UIButton *btn_1H;
@property (weak, nonatomic) IBOutlet UIButton *btn_2HD;
@property (weak, nonatomic) IBOutlet UIButton *btn_2HU;
@property (weak, nonatomic) IBOutlet UIButton *btn_Medicine1;
@property (weak, nonatomic) IBOutlet UIButton *btn_Medicine2;
@property (weak, nonatomic) IBOutlet UITextField *tf_MedicineType;
@property (weak, nonatomic) IBOutlet UITextField *tf_MedicineCnt;
@property (weak, nonatomic) IBOutlet UIButton *btn_Close;
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_PhoneUseTime;
@property (weak, nonatomic) IBOutlet UILabel *lb_Discrip1;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@property (weak, nonatomic) IBOutlet UILabel *lb_ChooseMedicationFix;

@end

@implementation AdditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_TitleFix.text = NSLocalizedString(@"Additional user information", nil);
    _lb_SubTitleFix.text = NSLocalizedString(@"Please fill out following", nil);
    _lb_PhoneUseTime.text = NSLocalizedString(@"Daily mobile phone usage", nil);
    [_btn_30M setTitle:NSLocalizedString(@"Within 30 minutes", nil) forState:0];
    [_btn_1H setTitle:NSLocalizedString(@"Within 1 hour", nil) forState:0];
    [_btn_2HD setTitle:NSLocalizedString(@"Within 2 hours", nil) forState:0];
    [_btn_2HU setTitle:NSLocalizedString(@"More than 2 hours", nil) forState:0];
    _lb_Discrip1.text = NSLocalizedString(@"Daily medication", nil);
    _tf_MedicineType.placeholder = NSLocalizedString(@"Number of med you take", nil);
    _tf_MedicineCnt.placeholder = NSLocalizedString(@"Number of pills (Daily)", nil);
    [_btn_Next setTitle:NSLocalizedString(@"Complete", nil) forState:0];
    _lb_ChooseMedicationFix.text = NSLocalizedString(@"Select medication", nil);
    [_btn_Medicine1 setTitle:NSLocalizedString(@"A medication", nil) forState:0];
    [_btn_Medicine2 setTitle:NSLocalizedString(@"B medication", nil) forState:0];
    
    _selectedPhoneUse = -1;
    _btn_Close.hidden = _isHideClose;
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

- (BOOL)inputCheck {
    if( _selectedPhoneUse > -1 &&
       _selectedMedicine.length > 0 &&
       _tf_MedicineType.text.length > 0 && _tf_MedicineCnt.text.length > 0 ) {
        return true;
    } else {
        [self.view makeToastCenter:@"작성란을 확인해 주세요"];
        return false;
    }
}


#pragma mark - Action
- (IBAction)goPhoneUseToggle:(UIButton *)sender {
    _btn_30M.selected = false;
    _btn_1H.selected = false;
    _btn_2HD.selected = false;
    _btn_2HU.selected = false;
    
    sender.selected = true;
    _selectedPhoneUse = sender.tag;
}

- (IBAction)goMedicineToggle:(UIButton *)sender {
    _btn_Medicine1.selected = false;
    _btn_Medicine2.selected = false;
    
    sender.selected = true;
    _selectedMedicine = sender.titleLabel.text;
    NSLog(@"%@", sender.titleLabel.text);
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


- (IBAction)goNext:(id)sender {
    if( [self inputCheck] ) {
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        
        if( email.length <= 0 ) { return; }

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:email forKey:@"mem_email"];
        [dicM_Params setObject:@(_selectedPhoneUse) forKey:@"mem_phone_time"];
        [dicM_Params setObject:_tf_MedicineType.text forKey:@"mem_drug_type"];
        [dicM_Params setObject:_tf_MedicineCnt.text forKey:@"mem_dose_count"];
        [dicM_Params setObject:_selectedMedicine forKey:@"mem_select_pill"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/additionalinfo/edit" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode code) {
            if( error != nil ) {
                return;
            }
            
            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:self.selectedMedicine forKey:[NSString stringWithFormat:@"%@_UserPill", email]];
            [[NSUserDefaults standardUserDefaults] synchronize];

            if( code == SUCCESS ) {
                [self dismissViewControllerAnimated:true completion:nil];
//                [Util showConfirmAlret:self withMsg:@"추가정보가 정상적으로 반영 되었습니다" completion:^(id result) {
//                    [self dismissViewControllerAnimated:true completion:nil];
//                }];
            }
        }];
    }
}

@end
