//
//  SurveyFinishViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/09/03.
//

#import <UIKit/UIKit.h>
#import "SurveyBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SurveyFinishViewController : SurveyBaseViewController
@property (assign ,nonatomic) NSInteger nSeq;
@property (strong, nonatomic) NSString *str_Contents;
@end

NS_ASSUME_NONNULL_END
