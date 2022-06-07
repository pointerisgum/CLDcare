//
//  FeedBackMainViewController.m
//  CLDcare
//
//  Created by 김영민 on 2021/12/29.
//

#import "FeedBackMainViewController.h"
#import "FeedBackViewController.h"

@interface FeedBackMainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Date;
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_DescripFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_Start;
@property (weak, nonatomic) IBOutlet UIButton *btn_Report;
@end

@implementation FeedBackMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Util checkReqUpdate:self];

    _lb_TitleFix.text = NSLocalizedString(@"Feedback after taking medication", nil);
    
    _lb_SubTitleFix.text = NSLocalizedString(@"Start survey after\ntaking medication ✍️", nil);
    
    _lb_DescripFix.text = NSLocalizedString(@"This is a survey and medication report to check the basic status after taking medication and to guide the medication use.", nil);
    
    [_btn_Start setTitle:NSLocalizedString(@"Start survey after taking medication", nil) forState:0];
    [_btn_Report setTitle:NSLocalizedString(@"Write a report after taking medication", nil) forState:0];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yy.MM.dd a hh:mm"];
    _lb_Date.text = [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"Writing time", nil), [format stringFromDate:[NSDate date]]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goShowReport:(id)sender {
    FeedBackViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedBackViewController"];
    vc.isReport = true;
    [self.navigationController pushViewController:vc animated:true];
}

@end
