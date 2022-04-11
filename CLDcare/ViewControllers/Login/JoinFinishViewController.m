//
//  JoinFinishViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/24.
//

#import "JoinFinishViewController.h"
#import "NDJoin.h"

@interface JoinFinishViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Name;
@property (weak, nonatomic) IBOutlet UILabel *lb_Email;
@end

@implementation JoinFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_Name.text = [NSString stringWithFormat:@"%@%@", [NDJoin sharedData].firstName, [NDJoin sharedData].lastName];
    _lb_Email.text = [NDJoin sharedData].email;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
