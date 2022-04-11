//
//  SurveyNumberViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import "SurveyNumberViewController.h"
#import "SurveyNumberViewController.h"
#import "SurveyCheckViewController.h"
#import "SurveyRadioViewController.h"
#import "SurveyFinishViewController.h"

@interface SurveyNumberViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitle;
@property (weak, nonatomic) IBOutlet UIView *v_TfBg;
@property (weak, nonatomic) IBOutlet UITextField *tf;

@end

@implementation SurveyNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBorder:_v_TfBg];
    [self setNextEnable:false];
    [_tf becomeFirstResponder];
    
    _lb_Title.text = _item.title;
    _lb_SubTitle.text = _item.subTitle;
    _tf.placeholder = _item.hint;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_tf removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
}

- (void)textFieldDidChange:(UITextField *)tf {
    [self setNextEnable:tf.text.length > 0];
}

- (IBAction)goNext:(id)sender {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@(_item.nSeq) forKey:@"survey_seq"];
    [dicM_Params setObject:@"submit" forKey:@"request_type"];
    
    NSArray *ar = @[@{@"inputOrder":@(_order),
                      @"numberValue":_tf.text}];
    
    NSData* json = [NSJSONSerialization dataWithJSONObject:ar options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];

    NSMutableDictionary *dicM_Values = [NSMutableDictionary dictionary];
    [dicM_Values setObject:jsonString
                    forKey:@"values"];
    [dicM_Values setObject:@"forward" forKey:@"direction"];
    [dicM_Values setObject:@(_item.nSeq) forKey:@"patientSurveySeq"];
    [dicM_Values setObject:@(_item.nextIdx) forKey:@"questionsNo"];

//    NSData* json = [NSJSONSerialization dataWithJSONObject:dicM_Values options:NSJSONWritingPrettyPrinted error:nil];
//    NSString* jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    [dicM_Params setObject:dicM_Values forKey:@"answer_value"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/answer" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        NSLog(@"%@", resulte);

        if( msgCode == SUCCESS ) {
            NSInteger nCode = [resulte[@"response_code"] integerValue];
            if( nCode == 204 ) {
                //설문 종료
                SurveyFinishViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyFinishViewController"];
                vc.nSeq = self.item.nSeq;
                vc.str_Contents = resulte[@"result_content"];
                [self.navigationController pushViewController:vc animated:true];
            } else {
                NDSurvey *item = [[NDSurvey alloc] initWithDic:resulte withSeq:self.item.nSeq];
                if( [item.codeId isEqualToString:@"number"] ) {
                    SurveyNumberViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyNumberViewController"];
                    vc.item = item;
                    vc.order = item.nextIdx;
                    [self.navigationController pushViewController:vc animated:true];
                } else if( [item.codeId isEqualToString:@"check"] ) {
                    SurveyCheckViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyCheckViewController"];
                    vc.item = item;
                    vc.order = item.nextIdx;
                    [self.navigationController pushViewController:vc animated:true];
                } else if( [item.codeId isEqualToString:@"radio"] ) {
                    SurveyRadioViewController *vc = [[UIStoryboard storyboardWithName:@"Survey" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyRadioViewController"];
                    vc.item = item;
                    vc.order = item.nextIdx;
                    [self.navigationController pushViewController:vc animated:true];
                }
            }
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//    [self setNextEnable:false];

@end
