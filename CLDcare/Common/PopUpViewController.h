//
//  PopUpViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PopUpDismissBlock)(void);

@interface PopUpViewController : UIViewController
@property (nonatomic, copy) PopUpDismissBlock popUpDismissBlock;
- (void)setPopUpDismissBlock:(PopUpDismissBlock)popUpDismissBlock;
@end

NS_ASSUME_NONNULL_END
