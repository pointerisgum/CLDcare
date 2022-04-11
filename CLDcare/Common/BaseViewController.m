//
//  BaseViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)updateViewLine:(ViewLineMode)mode withView:(UIView *)view {
    view.clipsToBounds = false;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 4;

    switch (mode) {
        case kEnable:
            view.layer.borderColor = MAIN_COLOR.CGColor;
            break;
        case kError:
            view.layer.borderColor = [UIColor colorWithHexString:@"eb6f6f"].CGColor;
            break;
        default:
            view.layer.borderColor = [UIColor colorWithHexString:@"ececec"].CGColor;
            break;
    }
}

- (void)enableBtn:(UIButton *)btn {
    btn.userInteractionEnabled = true;
    [btn setBackgroundColor:[UIColor linkColor]];
//    [btn setBackgroundColor:[UIColor colorWithRed:0 green:170.0f/255.0f blue:193.0f/255.0f alpha:1]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)disableBtn:(UIButton *)btn {
    btn.userInteractionEnabled = false;
    [btn setBackgroundColor:[UIColor colorWithRed:226.0f/255.0f green:230.0f/255.0f blue:233.0f/255.0f alpha:1]];
    [btn setTitleColor:[UIColor colorWithRed:175.0f/255.0f green:177.0f/255.0f blue:178.0f/255.0f alpha:1] forState:UIControlStateNormal];
}

- (void)enableBtnLayer:(UIButton *)btn {
    btn.layer.cornerRadius = 4;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = MAIN_COLOR.CGColor;
    [btn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
}

- (void)disableBtnLayer:(UIButton *)btn {
    btn.layer.cornerRadius = 4;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor colorWithHexString:@"e5e5e5"].CGColor;
    [btn setTitleColor:[UIColor colorWithHexString:@"afafaf"] forState:UIControlStateNormal];
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
