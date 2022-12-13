//
//  DeviceInfoViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/12/13.
//

#import "DeviceInfoViewController.h"
#import "PopUpViewController.h"
#import "FrimwareCheckPopupViewController.h"

@interface DeviceInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_SerialNo;
@property (weak, nonatomic) IBOutlet UILabel *lb_LastSync;
@property (weak, nonatomic) IBOutlet UILabel *lb_FwVersion;

@end

@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *str_NewFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewFWVersion"];
    NSString *str_MyFWVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWVersion"];
    NSString *str_FWUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWUpdateDate"];
    NSString *str_SerialNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialChar"];
    
    _lb_SerialNo.text = str_SerialNo;
    _lb_LastSync.text = str_FWUpdateDate;
    _lb_FwVersion.text = str_MyFWVersion;
}

- (IBAction)goFwUpdate:(id)sender {
    FrimwareCheckPopupViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FrimwareCheckPopupViewController"];
    [vc setFirmwareUpdate:^{
        [self.navigationController popToRootViewControllerAnimated:true];
        if( self.updateFw ) {
            self.updateFw();
        }
    }];
    [self presentViewController:vc animated:true completion:nil];
}

- (IBAction)goUnpair:(id)sender {
    if( IS_CONNECTED ) {
        PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
        [vc setPopUpDismissBlock:^{
            [Util deleteData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DisConnect" object:nil];
            [self.navigationController popToRootViewControllerAnimated:true];
        }];
        [self presentViewController:vc animated:true completion:^{
            
        }];
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
