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
    
    _lb_TitleFix.text = NSLocalizedString(@"Device Disconnect", nil);
    _lb_DescripFix.text = NSLocalizedString(@"Do you want to disconnect the device?\nYou can reconnect the device at any time.", nil);
    [_btn_Cancel setTitle:NSLocalizedString(@"Cancel", nil) forState:0];
    [_btn_Ok setTitle:NSLocalizedString(@"Disconnect", nil) forState:0];
}

- (IBAction)goDisConnect:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{
        if( self.popUpDismissBlock ) {
            self.popUpDismissBlock();
        }
    }];
}


@end
