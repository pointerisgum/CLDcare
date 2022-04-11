//
//  UIViewController+YM.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "UIViewController+YM.h"

@implementation UIViewController (YM)

- (IBAction)goHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)goDismiss:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
