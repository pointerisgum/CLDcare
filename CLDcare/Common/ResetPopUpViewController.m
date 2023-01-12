//
//  ResetPopUpViewController.m
//  CLDcare
//
//  Created by 김영민 on 2023/01/11.
//

#import "ResetPopUpViewController.h"

@interface ResetPopUpViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_Cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_Ok;
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceName;
@end

@implementation ResetPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_DeviceName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
}

- (IBAction)goDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{
        if( self.resetDoneBlock ) {
            self.resetDoneBlock();
        }
    }];
}

@end
