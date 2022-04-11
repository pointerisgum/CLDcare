//
//  SurveyViewController.m
//  CLDcare
//
//  Created by 김영민 on 2021/12/29.
//

#import "SurveyViewController.h"

@interface SurveyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitleFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_1;   //어지러움
@property (weak, nonatomic) IBOutlet UIButton *btn_2;   //미식거림
@property (weak, nonatomic) IBOutlet UIButton *btn_3;   //손발부음
@property (weak, nonatomic) IBOutlet UIButton *btn_4;   //구토
@property (weak, nonatomic) IBOutlet UIButton *btn_5;   //호흡곤란
@property (weak, nonatomic) IBOutlet UIButton *btn_Cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@end

@implementation SurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_TitleFix.text = NSLocalizedString(@"Survey", nil);
    _lb_SubTitleFix.text = NSLocalizedString(@"Please check the symptoms you\nhave, after taking medication", nil);
    [_btn_1 setTitle:NSLocalizedString(@"dizziness", nil) forState:0];
    [_btn_2 setTitle:NSLocalizedString(@"stomach upset", nil) forState:0];
    [_btn_3 setTitle:NSLocalizedString(@"swelling of hands and feet", nil) forState:0];
    [_btn_4 setTitle:NSLocalizedString(@"vomit", nil) forState:0];
    [_btn_5 setTitle:NSLocalizedString(@"shortness of breath", nil) forState:0];
    [_btn_Cancel setTitle:NSLocalizedString(@"Previous", nil) forState:0];
    [_btn_Next setTitle:NSLocalizedString(@"Next", nil) forState:0];

    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *pill = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_UserPill", email]]; //현재약품
    if( pill.length <= 0 ) {
        [self.view makeToastCenter:@"Setting -> 추가정보 설정\n에서 약품을 선택해 주세요"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)goToggle:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)goNext:(id)sender {
    if( _btn_1.selected == false &&
       _btn_2.selected == false &&
       _btn_3.selected == false &&
       _btn_4.selected == false &&
       _btn_5.selected == false ) {
        [self.view makeToastCenter:@"증상을 최소 1개 이상 선택해 주세요"];
        return;
    }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *pill = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_UserPill", email]]; //현재약품
    if( email.length <= 0 || pill.length <= 0 ) { return; }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    NSString *str_NowDate = [Util getDateString:[NSDate date] withTimeZone:nil];
    [dicM_Params setObject:str_NowDate forKey:@"regist_time"];
    [dicM_Params setObject:pill forKey:@"pill_name"];
    
    NSMutableDictionary *dicM_SubParams = [NSMutableDictionary dictionary];
    [dicM_SubParams setObject:_btn_1.selected ? @"Y" : @"N" forKey:@"effect_whirl"];
    [dicM_SubParams setObject:_btn_2.selected ? @"Y" : @"N" forKey:@"effect_disgusted"];
    [dicM_SubParams setObject:_btn_3.selected ? @"Y" : @"N" forKey:@"effect_swollen"];
    [dicM_SubParams setObject:_btn_4.selected ? @"Y" : @"N" forKey:@"effect_vormit"];
    [dicM_SubParams setObject:_btn_5.selected ? @"Y" : @"N" forKey:@"effect_dyspnea"];

    [dicM_Params setObject:dicM_SubParams forKey:@"medication_effect"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/survey/effect" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode code) {
        if( error != nil ) {
            return;
        }
        
        if( code == SUCCESS ) {
            [self.navigationController popViewControllerAnimated:true];
        }
    }];
}

@end
