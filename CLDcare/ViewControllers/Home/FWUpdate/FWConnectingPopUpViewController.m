//
//  FWConnectingPopUpViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/09/22.
//

#import "FWConnectingPopUpViewController.h"

@interface FWConnectingPopUpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_Descrip;

@end

@implementation FWConnectingPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    _lb_Title.text = NSLocalizedString(@"Firmware Update", nil);
    _lb_Descrip.text = NSLocalizedString(@"Entering the Firmware Update Mode.\nPlace Your Device Next to Coledy App and Wait.\n\n\nPreparing Update...", nil);
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
