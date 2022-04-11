//
//  ClausePopUpViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClauseComplete)(void);

@interface ClausePopUpViewController : BaseViewController
@property (nonatomic, copy) ClauseComplete clauseComplete;
- (void)setClauseComplete:(ClauseComplete)clauseComplete;
@end

NS_ASSUME_NONNULL_END

