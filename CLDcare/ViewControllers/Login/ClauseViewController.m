//
//  ClauseViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import "ClauseViewController.h"
#import "ClauseDetailViewController.h"

@interface ClauseViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_All;
@property (weak, nonatomic) IBOutlet UIButton *btn_Clause1;
@property (weak, nonatomic) IBOutlet UIButton *btn_Clause2;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_DiscripFix;
@end

@implementation ClauseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_TitleFix.text = NSLocalizedString(@"Accept Terms of Service", nil);
    _lb_DiscripFix.text = NSLocalizedString(@"Please agree to the terms of service and conditions", nil);
    [_btn_All setTitle:NSLocalizedString(@"Accept all", nil) forState:UIControlStateNormal];
    [_btn_Clause1 setTitle:NSLocalizedString(@"Terms of Use", nil) forState:UIControlStateNormal];
    [_btn_Clause2 setTitle:NSLocalizedString(@"Privacy policy", nil) forState:UIControlStateNormal];
    [_btn_Next setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];

    [self updateButtonStatus];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    if( [identifier isEqualToString:@"JoinSegue"] ) {
        if( _btn_All.selected == NO ) {
            return false;
        }
    }
    return true;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"clause1Segue"] ) {
        ClauseDetailViewController *vc = segue.destinationViewController;
        vc.str_Title = NSLocalizedString(@"terms of use", nil);
        vc.str_Url = @"https://coledycred.com/terms/service";
    } else if( [segue.identifier isEqualToString:@"clause2Segue"] ) {
        ClauseDetailViewController *vc = segue.destinationViewController;
        vc.str_Title = NSLocalizedString(@"terms of use", nil);
        vc.str_Url = @"https://coledycred.com/terms/privacy";
    }
}

- (void)updateButtonStatus {
    if( _btn_Clause1.selected && _btn_Clause2.selected ) {
        _btn_All.selected = true;
        [self enableBtn:_btn_Next];
    } else {
        _btn_All.selected = false;
        [self disableBtn:_btn_Next];
    }
}

- (IBAction)goToggle:(UIButton *)sender {
    if( sender == _btn_All ) {
        _btn_All.selected = !_btn_All.selected;
        if( _btn_All.selected ) {
            _btn_Clause1.selected = true;
            _btn_Clause2.selected = true;
        } else {
            _btn_Clause1.selected = false;
            _btn_Clause2.selected = false;
        }
    } else if( sender == _btn_Clause1 ) {
        _btn_Clause1.selected = !_btn_Clause1.selected;
    } else if( sender == _btn_Clause2 ) {
        _btn_Clause2.selected = !_btn_Clause2.selected;
    }
    
    [self updateButtonStatus];
}

@end
