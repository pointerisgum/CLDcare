//
//  FWUpdateViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/09/22.
//

#import "FWUpdateViewController.h"

@interface FWUpdateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lb_Descrip;
@property (weak, nonatomic) IBOutlet UILabel *lb_FileNameFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_FileName;
@property (weak, nonatomic) IBOutlet UILabel *lb_SizeFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_Size;
@property (weak, nonatomic) IBOutlet UILabel *lb_StatusFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_Status;
@property (weak, nonatomic) IBOutlet UILabel *lb_ContentsFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents;
@property (weak, nonatomic) IBOutlet UIButton *btn_Start;

@property (weak, nonatomic) IBOutlet UIView *v_DescripBG;
@property (weak, nonatomic) IBOutlet UIView *v_ImageBG;
@property (weak, nonatomic) IBOutlet UIImageView *iv_Guide;

@property (weak, nonatomic) IBOutlet UILabel *lb_UploadingFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_Per;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIView *v_UpdateBG;
@property (weak, nonatomic) IBOutlet UIView *v_UpdateDescripBg;
@property (weak, nonatomic) IBOutlet UILabel *lb_UpdatingDescripFix;

@property (nonatomic, assign) BOOL isFinished;
@end

@implementation FWUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_Title.text = NSLocalizedString(@"Install Device Firmware", nil);
    _lb_SubTitle.text = NSLocalizedString(@"Device Firmware Install Process", nil);
    _lb_Descrip.text = NSLocalizedString(@"Please Install Device Firmware to Your Device.\nPlease Follow Installation Steps.", nil);
    
    _lb_FileNameFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"File Name", nil)];
    _lb_SizeFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Size", nil)];
    _lb_StatusFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Status", nil)];
    _lb_ContentsFix.text = [NSString stringWithFormat:@"%@ :", NSLocalizedString(@"Contents", nil)];
    
    NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
    _lb_FileName.text = [NSString stringWithFormat:@"%@.zip", str_NewFWVersion];
    
    CGFloat fFileSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"FWSize"];
    _lb_Size.text = [NSString stringWithFormat:@"%.0f bytes", fFileSize];
    
    _lb_Contents.text = NSLocalizedString(@"Place Coledy App Next to Sensor\nDevice with Cap Open", nil);
    
    _lb_UpdatingDescripFix.text = NSLocalizedString(@"Keep Coledy App Open\nwith Device Cap Open While Installing", nil);
    
    _lb_UploadingFix.text = NSLocalizedString(@"Installing...", nil);
    
    [_btn_Start setTitle:NSLocalizedString(@"Start", nil) forState:0];
    
    _lb_Per.text = @"0%";
    
    [self updateUI];
}

- (void)updateUI {
    if( _isFinished ) {
        _v_ImageBG.hidden = true;
        _v_UpdateBG.hidden = true;
        _btn_Start.hidden = false;
        _lb_UpdatingDescripFix.text = NSLocalizedString(@"Installation is Complete.", nil);
        [_btn_Start setTitle:NSLocalizedString(@"Close", nil) forState:0];
    } else {
        if( _isInitMode ) {
            _v_UpdateBG.hidden = true;
            _v_UpdateDescripBg.hidden = true;
            _v_DescripBG.hidden = false;
            
            [_btn_Start setTitle:NSLocalizedString(@"Start", nil) forState:0];
        } else {
            _v_UpdateBG.hidden = false;
            _v_UpdateDescripBg.hidden = false;
            _v_DescripBG.hidden = true;
            
            [_btn_Start setTitle:NSLocalizedString(@"Cancel", nil) forState:0];
        }
    }
}

- (void)updatePer:(NSInteger)per {
    _lb_Per.text = [NSString stringWithFormat:@"%ld%%", per];
    _progress.progress = (CGFloat)((CGFloat)per / 100.0);
}

- (void)updateFinish {
    _isFinished = true;
    [self updateUI];
}

- (IBAction)goStartAndCancel:(id)sender {
    if( _isFinished ) {
        [self dismissViewControllerAnimated:true completion:^{
        }];
    } else {
        if( _isInitMode ) {
            _isInitMode = false;
            _btn_Start.hidden = true;
            //시작
            if( _startFirmwareUpdate ) {
                _startFirmwareUpdate();
            }
        } else {
            //취소
            if( _pauseFirmwareUpdate ) {
                _pauseFirmwareUpdate();
            }
            
            [UIAlertController showAlertInViewController:self
                                               withTitle:NSLocalizedString(@"Cancel The Firmware Update?", nil)
                                                 message:@""
                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@[NSLocalizedString(@"Confirm", nil)]
                                                tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                if( action.style == UIAlertActionStyleDefault ) {
                    if( self.cancelFirmwareUpdate ) {
                        self.cancelFirmwareUpdate();
                    }
                    [self dismissViewControllerAnimated:true completion:nil];
                } else {
                    if( self.resumeFirmwareUpdate ) {
                        self.resumeFirmwareUpdate();
                    }
                }
            }];
        }
        [self updateUI];
    }
}

- (IBAction)goDismiss:(id)sender {
    if( _isFinished ) {
        if( _closeFirmwareUpdate ) {
            _closeFirmwareUpdate();
        }
        [self dismissViewControllerAnimated:true completion:^{
        }];
    } else {
        if( _isInitMode ) {
            if( _closeFirmwareUpdate ) {
                _closeFirmwareUpdate();
            }
            [self dismissViewControllerAnimated:true completion:^{
            }];
        } else {
            //취소
            if( _pauseFirmwareUpdate ) {
                _pauseFirmwareUpdate();
            }
            
            [UIAlertController showAlertInViewController:self
                                               withTitle:NSLocalizedString(@"Cancel The Firmware Update?", nil)
                                                 message:@""
                                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@[NSLocalizedString(@"Confirm", nil)]
                                                tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                if( action.style == UIAlertActionStyleDefault ) {
                    if( self.cancelFirmwareUpdate ) {
                        self.cancelFirmwareUpdate();
                    }
                    [self dismissViewControllerAnimated:true completion:nil];
                } else {
                    if( self.resumeFirmwareUpdate ) {
                        self.resumeFirmwareUpdate();
                    }
                }
            }];
        }
    }
}

@end
