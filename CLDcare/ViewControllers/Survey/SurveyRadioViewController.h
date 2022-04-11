//
//  SurveyRadioViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import <UIKit/UIKit.h>
#import "SurveyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SurveyRadioViewController : SurveyBaseViewController
@property (strong, nonatomic) NDSurvey *item;
@property (assign, nonatomic) NSInteger order;
@end

NS_ASSUME_NONNULL_END
