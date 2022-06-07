//
//  PopUpViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <UIKit/UIKit.h>
#import "Util.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^PopUpDismissBlock)(void);
typedef void (^CancelDismissBlock)(void);

@interface PopUpViewController : UIViewController
@property (nonatomic, assign) BOOL isReport;
@property (nonatomic, assign) BOOL isUpdateMode;
@property (nonatomic, assign) UpdateStatus updateStatus;
@property (nonatomic, copy) PopUpDismissBlock popUpDismissBlock;
@property (nonatomic, copy) CancelDismissBlock cancelDismissBlock;
- (void)setPopUpDismissBlock:(PopUpDismissBlock)popUpDismissBlock;
- (void)setCancelDismissBlock:(CancelDismissBlock)cancelDismissBlock;
@end

NS_ASSUME_NONNULL_END
