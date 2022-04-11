//
//  PrescripViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/08/26.
//

#import "PrescripViewController.h"
#import "PopUpCalendarViewController.h"
#import "NDPrescrip.h"
#import "PrescripCell.h"
#import "PrescripDetailViewController.h"

@interface PrescripViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (weak, nonatomic) IBOutlet UILabel *lb_Cnt;
@property (weak, nonatomic) IBOutlet UILabel *lb_Start;
@property (weak, nonatomic) IBOutlet UILabel *lb_End;
//@property (strong, nonatomic) NSMutableArray<NDPrescrip *> *items;
//@property (strong, nonatomic) NDVisitHistory *visitHistory;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSMutableDictionary *dicM_Params;
@end

@implementation PrescripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"PrescripDetailSegue"] ) {
        PrescripDetailViewController *vc = (PrescripDetailViewController *)segue.destinationViewController;
        vc.item = sender;
        vc.params = self.dicM_Params;
    }
}

- (void)reload {
    if( _startDate == nil || _endDate == nil ) { return; }
    
    if( _startDate.timeIntervalSince1970 > _endDate.timeIntervalSince1970 ) {
        [Util showConfirmAlret:self withMsg:@"시작일이 종료일 보다 큽니다.\n종료일을 다시 선택해 주세요." completion:^(id result) {
            [self goEnd:nil];
        }];
        return;
    }
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    self.dicM_Params = [NSMutableDictionary dictionary];
    [self.dicM_Params setObject:email forKey:@"mem_email"];
    [self.dicM_Params setObject:_lb_Start.text forKey:@"start_date"];
    [self.dicM_Params setObject:_lb_End.text forKey:@"end_date"];
    [self.dicM_Params setObject:@(-1) forKey:@"seq"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"prescription/request" param:self.dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        
        NSLog(@"%@", resulte);
        [[NDPrescrip sharedData].prescripHistory removeAllObjects];
        
        if( msgCode == NO_MATCHING_DATA ) {
            //등록된 정보가 없음
            
        } else {
            NSArray *ar = resulte;
            if( ar.count > 0 ) {
                NSDictionary *dic = ar.firstObject;
                [[NDPrescrip sharedData] setItem:dic];
            }
        }
        self.lb_Cnt.text = [NSString stringWithFormat:@"%ld", [NDPrescrip sharedData].prescripHistory.count];
        [self.tbv_List reloadData];
    }];
}

- (IBAction)goStart:(id)sender {
    PopUpCalendarViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpCalendarViewController"];
    [vc setCompletionBlock:^(NSDate *selectDate) {
        self.startDate = selectDate;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [format stringFromDate:selectDate];
        self.lb_Start.text = dateString;
        [self reload];
    }];
    [self presentViewController:vc animated:true completion:^{
        
    }];
}

- (IBAction)goEnd:(id)sender {
    PopUpCalendarViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpCalendarViewController"];
    [vc setCompletionBlock:^(NSDate *selectDate) {
        self.endDate = selectDate;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [format stringFromDate:selectDate];
        self.lb_End.text = dateString;
        [self reload];
    }];
    [self presentViewController:vc animated:true completion:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [NDPrescrip sharedData].prescripHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [NDPrescrip sharedData].prescripHistory.count <= indexPath.row ) {
        return [[UITableViewCell alloc] init];
    }
    
    NDPrescripHistory *item = [NDPrescrip sharedData].prescripHistory[indexPath.row];

    PrescripCell* cell = (PrescripCell*)[tableView dequeueReusableCellWithIdentifier:@"PrescripCell"];
    cell.lb_Title.text = item.diseNm;
    cell.lb_Date.text = item.startDate;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NDPrescripHistory *item = [NDPrescrip sharedData].prescripHistory[indexPath.row];
    [self performSegueWithIdentifier:@"PrescripDetailSegue" sender:item];
}

@end
