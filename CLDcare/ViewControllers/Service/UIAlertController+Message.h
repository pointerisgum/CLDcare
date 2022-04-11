//
//  UIAlertController+Message.h
//  BLEToy
//
//  Created by YongHee Nam on 2017. 3. 16..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    MBS_OK,
    MBS_OKCancel,
    MBS_Yes,
    MBS_YesNo,
} MessageBoxStyle;

typedef enum
{
    MB_OK,
    MB_Cancel,
    MB_Yes,
    MB_No,
} MessageBoxButton;
@interface UIAlertController(Message)
+ (nonnull UIAlertController*) mesageBoxWithTitle:(nullable NSString*) title message:(nullable NSString*) mesage style:(MessageBoxStyle)style handler:(void (^__nullable)(MessageBoxButton selectedButton)) handler viewController:(nonnull UIViewController*)viewController;
+ (nonnull UIAlertController*) mesageBoxGetTextWithTitle:(nullable NSString*) title message:(nullable NSString*) mesage placeHolder:(nullable NSString*) placeHolder handler:(void (^__nullable)(MessageBoxButton selectedButton,  UIAlertController* _Nonnull  alertView)) handler viewController:(nonnull UIViewController*)viewController;

@end
