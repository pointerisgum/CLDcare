//
//  SurveyCheckViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import "SurveyCheckViewController.h"
#import "SurveyCell.h"
#import "SurveyNumberViewController.h"
#import "SurveyCheckViewController.h"
#import "SurveyRadioViewController.h"
#import "SurveyFinishViewController.h"

@interface SurveyCheckViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitle;
@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *selectItems;
@end

@implementation SurveyCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectItems = [NSMutableArray array];
    
//    NDSurvey *temp = [[NDSurvey alloc] init];
//    temp.hints = @[[[NDHint alloc] initWithDic:@{@"exampleContentKo":@"aaa"}],
//                   [[NDHint alloc] initWithDic:@{@"exampleContentKo":@"bbb"}],
//                   [[NDHint alloc] initWithDic:@{@"exampleContentKo":@"ccc"}],
//                   [[NDHint alloc] initWithDic:@{@"exampleContentKo":@"ddd"}],
//                   [[NDHint alloc] initWithDic:@{@"exampleContentKo":@"eee"}]];
//    _item = temp;
    
    
    _items = _item.hints;
    
    _lb_Title.text = _item.title;
    if( [_item.subTitle isEqualToString:@"none"] ) {
        _lb_SubTitle.text = @"";
    } else {
        _lb_SubTitle.text = _item.subTitle;
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
- (IBAction)goNext:(id)sender {
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:@(_item.nSeq) forKey:@"survey_seq"];
    [dicM_Params setObject:@"submit" forKey:@"request_type"];
    
    NSMutableArray *arM_Hints = [NSMutableArray array];
    for( NSInteger i = 0; i < _selectItems.count; i++ ) {
        NDHint *hint = _selectItems[i];
        NSDictionary *dic = @{@"inputOrder":@(i + 1),
                              @"displayOrder":@(hint.displayOrder)};
        [arM_Hints addObject:dic];
    }
//    for( NDHint *hint in _selectItems ) {
//        NSDictionary *dic = @{@"inputOrder":@(_order),
//                              @"displayOrder":@(hint.displayOrder)};
//        [arM_Hints addObject:dic];
//    }
//    NSArray *ar = @[@{@"inputOrder":@(_order),
//                      @"displayOrder":@(1)},
//                    @{@"inputOrder":@(_order),
//                                      @"displayOrder":@(5)}];
    
    NSData* json = [NSJSONSerialization dataWithJSONObject:arM_Hints options:NSJSONWritingPrettyPrinted error:nil];
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

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SurveyCell* cell = (SurveyCell*)[tableView dequeueReusableCellWithIdentifier:@"SurveyCell"];

    NDHint *hintItem = _items[indexPath.row];
    if( [_selectItems containsObject:hintItem] ) {
        [cell selectItem:true];
    } else {
        [cell selectItem:false];
    }
    
    cell.lb_Title.text = hintItem.exampleContentKo;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    NDHint *hintItem = _items[indexPath.row];
    if( [_selectItems containsObject:hintItem] ) {
        [_selectItems removeObject:hintItem];
    } else {
        [_selectItems addObject:hintItem];
    }
    
    [self setNextEnable:_selectItems.count > 0];

    [_tbv_List reloadData];
}


@end
