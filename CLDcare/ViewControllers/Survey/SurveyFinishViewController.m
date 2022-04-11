//
//  SurveyFinishViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/09/03.
//

#import "SurveyFinishViewController.h"
#import "SurveyNumberViewController.h"
#import "SurveyCheckViewController.h"
#import "SurveyRadioViewController.h"

@interface SurveyFinishViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Name;
@property (weak, nonatomic) IBOutlet UIButton *btn_Retry;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents;
@end

@implementation SurveyFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBorder:_btn_Retry];
    
    NSString *firstName = [[NSUserDefaults standardUserDefaults] objectForKey:@"mem_first_name"];
    NSString *lastName = [[NSUserDefaults standardUserDefaults] objectForKey:@"mem_last_name"];
    _lb_Name.text = [NSString stringWithFormat:@"%@%@", firstName, lastName];
    
    _lb_Contents.text = _str_Contents;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goReTry:(id)sender {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@(self.nSeq) forKey:@"survey_seq"];
    [dicM_Params setObject:@"none" forKey:@"answer_value"];
    [dicM_Params setObject:@"retry" forKey:@"request_type"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"survey/answer" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        NSLog(@"%@", resulte);
        
        if( msgCode == SUCCESS ) {
            [self.navigationController popToRootViewControllerAnimated:false];

            NDSurvey *item = [[NDSurvey alloc] initWithDic:resulte withSeq:self.nSeq];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RePlayNoti" object:item];
        }
    }];
}


- (IBAction)goFinish:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
