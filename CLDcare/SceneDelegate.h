//
//  SceneDelegate.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <UIKit/UIKit.h>

typedef void (^SurveyCheckComplete)(NSDictionary *);

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow * window;
@property (nonatomic, copy) SurveyCheckComplete surveyCheckComplete;
- (void)setSurveyCheckComplete:(SurveyCheckComplete)surveyCheckComplete;
- (void)showMainView;
- (void)showLoginView;
- (void)skipTodayAlarm;
- (void)setTodayDose;
- (BOOL)getTodayDose;
- (void)createSurvey;
- (void)surveyCheck;
@end

