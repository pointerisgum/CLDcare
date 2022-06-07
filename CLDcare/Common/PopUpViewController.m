//
//  PopUpViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "PopUpViewController.h"

@interface PopUpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_DescripFix;
@property (weak, nonatomic) IBOutlet UIButton *btn_Cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_Ok;
@end

@implementation PopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if( _isUpdateMode ) {
        if( _updateStatus == Require ) {
            _lb_TitleFix.text = NSLocalizedString(@"Update", nil);
            _lb_DescripFix.text = NSLocalizedString(@"Update is required", nil);
            _btn_Cancel.hidden = true;
            [_btn_Ok setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
        } else if( _updateStatus == Optional ) {
            _lb_TitleFix.text = NSLocalizedString(@"Update", nil);
            _lb_DescripFix.text = NSLocalizedString(@"There is a new update.\nDo you want to update?", nil);
            [_btn_Cancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
            [_btn_Ok setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
        }
    } else if (_isReport) {
            _lb_TitleFix.text = NSLocalizedString(@"Detecting drug problems", nil);
            _lb_DescripFix.text = NSLocalizedString(@"An error has been detected in the medicine bottle sensor.\nDo you want to report?", nil);
            [_btn_Cancel setTitle:NSLocalizedString(@"close", nil) forState:UIControlStateNormal];
            [_btn_Ok setTitle:NSLocalizedString(@"report", nil) forState:UIControlStateNormal];
    } else {
        _lb_TitleFix.text = NSLocalizedString(@"Device Disconnect", nil);
        _lb_DescripFix.text = NSLocalizedString(@"Do you want to disconnect the device?\nYou can reconnect the device at any time.", nil);
        [_btn_Cancel setTitle:NSLocalizedString(@"Cancel", nil) forState:0];
        [_btn_Ok setTitle:NSLocalizedString(@"Disconnect", nil) forState:0];
    }
}

- (IBAction)goDisConnect:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{
        if( self.popUpDismissBlock ) {
            self.popUpDismissBlock();
        }
    }];
}

- (IBAction)goCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{
        if( self.cancelDismissBlock ) {
            self.cancelDismissBlock();
        }
    }];
}

@end
