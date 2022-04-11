//
//  SurveyPopUpViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import "SurveyPopUpViewController.h"
#import "NDSurvey.h"
#import "SurveyNumberViewController.h"
#import "SurveyCheckViewController.h"
#import "SurveyRadioViewController.h"

@interface SurveyPopUpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Name;
@property (weak, nonatomic) IBOutlet UILabel *lb_Medicine;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents;
@property (weak, nonatomic) IBOutlet UILabel *lb_Date;
@end

@implementation SurveyPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:@"mem_first_name"];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:@"mem_last_name"];
    _lb_Name.text = [NSString stringWithFormat:@"%@%@", firstName, lastName];
    _lb_Medicine.text = _medicine;
    _lb_Contents.text = _contents;
    _lb_Date.text = _date;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rePlayNoti:)
                                                 name:@"RePlayNoti"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [SCENE_DELEGATE setSurveyCheckComplete:^(NSDictionary * dic) {
        self.nSeq = [dic[@"survey_seq"] integerValue];
        self.medicine = dic[@"survey_title"];
        self.contents = dic[@"survey_content"];
        self.date = dic[@"survey_datetime"];
    }];
}

- (void)rePlayNoti:(NSNotification *)noti {
    NDSurvey *item = (NDSurvey *)noti.object;
    if( [item.codeId isEqualToString:@"number"] ) {
        SurveyNumberViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyNumberViewController"];
        vc.item = item;
        vc.order = 1;
        [self.navigationController pushViewController:vc animated:true];
    } else if( [item.codeId isEqualToString:@"check"] ) {
        SurveyCheckViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyCheckViewController"];
        vc.item = item;
        vc.order = 1;
        [self.navigationController pushViewController:vc animated:true];
    } else if( [item.codeId isEqualToString:@"radio"] ) {
        SurveyRadioViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyRadioViewController"];
        vc.item = item;
        vc.order = 1;
        [self.navigationController pushViewController:vc animated:true];
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

- (IBAction)goSkip:(id)sender {
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"설문을 건너뛰시겠습니까?"
                                         message:@""
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        if( action.style == UIAlertActionStyleDefault ) {
            
            [self dismissViewControllerAnimated:true completion:nil];
            
            NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:email forKey:@"mem_email"];
            [dicM_Params setObject:@(self.nSeq) forKey:@"survey_seq"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/skip" param:dicM_Params withMethod:@"PUT" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
                if( error != nil ) {
                    return;
                }
                NSLog(@"%@", resulte);
                
                if( msgCode == SUCCESS ) {

                }
            }];
        }
    }];
}

- (IBAction)goStart:(id)sender {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@(_nSeq) forKey:@"survey_seq"];
    [dicM_Params setObject:@"none" forKey:@"answer_value"];
    [dicM_Params setObject:@"create" forKey:@"request_type"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/answer" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        NSLog(@"%@", resulte);
        
        if( msgCode == SUCCESS ) {
            NDSurvey *item = [[NDSurvey alloc] initWithDic:resulte withSeq:self.nSeq];
            if( [item.codeId isEqualToString:@"number"] ) {
                SurveyNumberViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyNumberViewController"];
                vc.item = item;
                vc.order = 1;
                [self.navigationController pushViewController:vc animated:true];
            } else if( [item.codeId isEqualToString:@"check"] ) {
                SurveyCheckViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyCheckViewController"];
                vc.item = item;
                vc.order = 1;
                [self.navigationController pushViewController:vc animated:true];
            } else if( [item.codeId isEqualToString:@"radio"] ) {
                SurveyRadioViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyRadioViewController"];
                vc.item = item;
                vc.order = 1;
                [self.navigationController pushViewController:vc animated:true];
            }
        }
    }];
}

@end
