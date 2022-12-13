//
//  MediSetUpViewController.h
//  CLDcare
//
//  Created by 김영민 on 2022/11/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    STEP1,
    STEP2,
    STEP3,
    STEP4,
    STEP5,
} MediStep;

typedef void (^MediSetUpFinishBlock)(void);

@interface MediSetUpViewController : UIViewController
@property (nonatomic, copy) MediSetUpFinishBlock mediSetUpFinishBlock;
- (void)setMediSetUpFinishBlock:(MediSetUpFinishBlock)mediSetUpFinishBlock;
@property (nonatomic, assign) MediStep step;
@end

NS_ASSUME_NONNULL_END
