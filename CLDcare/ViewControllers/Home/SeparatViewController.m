//
//  SeparatViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/11/28.
//

#import "SeparatViewController.h"

@interface SeparatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tf_Count;

@end

@implementation SeparatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)goShowSetUp:(id)sender {
    if( _showSetUpBlock ) {
        _showSetUpBlock();
    }
}

- (IBAction)goSendMsg:(UIButton *)sender {
    if( _sendMsgBlock ) {
        if( sender.tag == 1 ) {
            _sendMsgBlock(sender.tag, [_tf_Count.text integerValue]);
        } else {
            _sendMsgBlock(sender.tag, 0);
        }
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Number of pills", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *str = [NSString stringWithFormat:@"%@", [[alertController textFields][0] text]];
        NSInteger cnt = [str integerValue];
        if( cnt > 0 ) {
            self.tf_Count.text = [NSString stringWithFormat:@"%ld", cnt];
        }
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return false;
}

@end
