//
//  SurveyPopUpViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SurveyPopUpViewController : UIViewController
@property (assign, nonatomic) NSInteger nSeq;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *medicine;
@property (strong, nonatomic) NSString *contents;
@end

NS_ASSUME_NONNULL_END
