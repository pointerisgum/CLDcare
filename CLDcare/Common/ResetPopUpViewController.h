//
//  ResetPopUpViewController.h
//  CLDcare
//
//  Created by 김영민 on 2023/01/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ResetDoneBlock)(void);

@interface ResetPopUpViewController : UIViewController
@property (nonatomic, copy) ResetDoneBlock resetDoneBlock;
- (void)setResetDoneBlock:(ResetDoneBlock)resetDoneBlock;
@end

NS_ASSUME_NONNULL_END
