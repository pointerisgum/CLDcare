//
//  FWDownloadPopUpViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/09/22.
//

#import "FWDownloadPopUpViewController.h"
#import <Lottie/Lottie.h>

@interface FWDownloadPopUpViewController ()
@property (weak, nonatomic) IBOutlet LOTAnimationView *v_Ani;
@property (weak, nonatomic) IBOutlet UILabel *lb_DownloadDescrip;
@end

@implementation FWDownloadPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_v_Ani setLoopAnimation:true];
    [_v_Ani play];
    
    _lb_DownloadDescrip.text = NSLocalizedString(@"Downloading Firmware...", nil);
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
