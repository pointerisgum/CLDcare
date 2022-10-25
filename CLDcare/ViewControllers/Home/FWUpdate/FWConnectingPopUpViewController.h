//
//  FWConnectingPopUpViewController.h
//  CLDcare
//
//  Created by 김영민 on 2022/09/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Completion)(void);

@interface FWConnectingPopUpViewController : UIViewController
@property (nonatomic, copy) Completion completion;
- (void)setCompletion:(Completion)completion;
@end

NS_ASSUME_NONNULL_END
