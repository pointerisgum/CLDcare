//
//  FrimwareCheckPopupViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/09/03.
//

#import "FrimwareCheckPopupViewController.h"

@interface FrimwareCheckPopupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceName;
@property (weak, nonatomic) IBOutlet UILabel *lb_FirmwareVersion;
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceInfoTitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_FirmwareInfoTitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_RecentVersionFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_RecentVersionBottomFix;
@property (weak, nonatomic) IBOutlet UIView *v_UpdateBg;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@property (weak, nonatomic) IBOutlet UILabel *lb_FirmwareUpdateDateFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_FirmwareUpdateDate;
@property (weak, nonatomic) IBOutlet UIView *v_RecentTextBG;
@property (weak, nonatomic) IBOutlet UIView *v_RecentTostBG;
@property (weak, nonatomic) IBOutlet UIView *v_NewFirmwareBG;
@property (weak, nonatomic) IBOutlet UILabel *lb_NewFirmwareVerFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_NewFirmwareVer;
@property (weak, nonatomic) IBOutlet UIView *v_NeedUpdateBG;
@property (weak, nonatomic) IBOutlet UILabel *lb_NeedUpdate;
@property (weak, nonatomic) IBOutlet UIView *v_UpdateDateBG;
@end

@implementation FrimwareCheckPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _lb_TitleFix.text = NSLocalizedString(@"Device Information", nil);
    
    _lb_DeviceInfoTitleFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Device ID", nil)];
    _lb_FirmwareInfoTitleFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Current Firmware Version", nil)];
    _lb_NewFirmwareVerFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"New Firmware Version Available", nil)];
    _lb_FirmwareUpdateDateFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Firmware Update Date", nil)];

    _lb_NeedUpdate.text = NSLocalizedString(@"Firmware needs to be updated", nil);
    
    _lb_RecentVersionBottomFix.text = NSLocalizedString(@"Latest version", nil);

    NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//    str_NewFWVersion = @"0403";
    NSString *str_MyFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"];
    NSString *str_FWUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWUpdateDate"];
    
    _lb_DeviceName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    _lb_FirmwareVersion.text = str_MyFWVersion;
    _lb_FirmwareUpdateDate.text = str_FWUpdateDate;
    _lb_NewFirmwareVer.text = str_NewFWVersion;
    
    if( (str_MyFWVersion != nil && str_NewFWVersion != nil) && ([str_NewFWVersion integerValue] > [str_MyFWVersion integerValue]) ) {
        _v_UpdateDateBG.hidden = true;
        _v_NeedUpdateBG.hidden = false;
        _v_NewFirmwareBG.hidden = false;
        _v_RecentTextBG.hidden = true;
        _v_RecentTostBG.hidden = true;
        _v_UpdateBg.hidden = false;
        
        [_btn_Next setTitle:NSLocalizedString(@"Download and Install", nil) forState:UIControlStateNormal];
    } else {
        _v_UpdateDateBG.hidden = false;
        _v_NeedUpdateBG.hidden = true;
        _v_NewFirmwareBG.hidden = true;
        _v_RecentTextBG.hidden = false;
        _v_RecentTostBG.hidden = false;
        _v_UpdateBg.hidden = true;
        _lb_RecentVersionFix.text = NSLocalizedString(@"Your Firmware is Up To Date", nil);
//        [_btn_Next setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    }
}


- (IBAction)goUpdate:(id)sender {
    NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
//    str_NewFWVersion = @"0403";
    NSString *str_MyFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"];
    if( (str_MyFWVersion != nil && str_NewFWVersion != nil) && ([str_NewFWVersion integerValue] > [str_MyFWVersion integerValue]) ) {
        if( _firmwareUpdate ) {
            [self dismissViewControllerAnimated:true completion:^{
                self.firmwareUpdate();
            }];
        } else {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

@end
