//
//  SeparatViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/11/28.
//

#import "SeparatViewController.h"

@interface SeparatViewController ()

@end

@implementation SeparatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)goShowSetUp:(id)sender {
    if( _showSetUpBlock ) {
        _showSetUpBlock();
    }
}

- (IBAction)goSendMsg:(UIButton *)sender {
    if( _sendMsgBlock ) {
        _sendMsgBlock(sender.tag);
    }
}

@end
