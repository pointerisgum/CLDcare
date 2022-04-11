//
//  BaseViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    kDefault,
    kEnable,
    kError,
} ViewLineMode;

@interface BaseViewController : UIViewController
- (void)enableBtn:(UIButton *)btn;
- (void)disableBtn:(UIButton *)btn;
- (void)enableBtnLayer:(UIButton *)btn;
- (void)disableBtnLayer:(UIButton *)btn;
- (void)updateViewLine:(ViewLineMode)mode withView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
