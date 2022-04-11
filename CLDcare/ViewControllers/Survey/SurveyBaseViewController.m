//
//  SurveyBaseViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import "SurveyBaseViewController.h"

@interface SurveyBaseViewController ()

@end

@implementation SurveyBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBorder: _btn_Prev];
    [self setBorder: _btn_Next];
}

- (void)setBorder:(UIView *)view {
    view.clipsToBounds = true;
    view.layer.cornerRadius = 2;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;
}

- (void)setNextEnable:(BOOL)isEnable {
    if( isEnable ) {
        [_btn_Next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn_Next.backgroundColor = [UIColor colorWithHexString:@"00aac1"];
        _btn_Next.enabled = true;
    } else {
        [_btn_Next setTitleColor:[UIColor colorWithHexString:@"bec5c9"] forState:UIControlStateNormal];
        _btn_Next.backgroundColor = [UIColor colorWithHexString:@"eff2f4"];
        _btn_Next.enabled = false;
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

@end
