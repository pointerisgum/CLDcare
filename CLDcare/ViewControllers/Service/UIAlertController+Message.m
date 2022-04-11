//
//  UIAlertController+Message.m
//  BLEToy
//
//  Created by YongHee Nam on 2017. 3. 16..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#import "UIAlertController+Message.h"

@implementation UIAlertController(Message)

+ (UIAlertController*) mesageBoxWithTitle:(nullable NSString*) title message:(nullable NSString*) message style:(MessageBoxStyle)style handler:(void (^__nullable)(MessageBoxButton selectedButton)) handler viewController:(UIViewController*)viewController
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (style == MBS_OK || style == MBS_OKCancel)
    {
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(MB_OK);
        }];
        
        [controller addAction:action];
    }
    if (style == MBS_OKCancel)
    {
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(MB_Cancel);
        }];
        
        [controller addAction:action];
    }
    if (style == MBS_Yes || style == MBS_YesNo)
    {
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"예" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(MB_Yes);
        }];
        
        [controller addAction:action];
    }
    if (style == MBS_YesNo)
    {
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"아니요" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(MB_No);
        }];
        
        [controller addAction:action];
    }
    
    [viewController presentViewController:controller animated:YES completion:nil];
    
    return controller;
}

+ (UIAlertController*)mesageBoxGetTextWithTitle:(NSString *)title message:(NSString *)message placeHolder:(NSString *)placeHolder handler:(void (^)(MessageBoxButton, UIAlertController *))handler viewController:(UIViewController *)viewController
{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeHolder;
    }];
    
    UIAlertAction* action;
    
    // 확인
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"확인") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler)
            handler(MB_OK, controller);
        
    }];
    
    [controller addAction:action];
    
    // 취소
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"취소") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler)
            handler(MB_Cancel, controller);
    }];
    
    [controller addAction:action];
    
    [viewController presentViewController:controller animated:YES completion:nil];
    
    return controller;
}

@end
