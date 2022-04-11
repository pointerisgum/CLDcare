//
//  SurveyBaseViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import <UIKit/UIKit.h>
#import "NDSurvey.h"

NS_ASSUME_NONNULL_BEGIN

@interface SurveyBaseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btn_Prev;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
- (void)setBorder:(UIView *)view;
- (void)setNextEnable:(BOOL)isEnable;
@end

NS_ASSUME_NONNULL_END
