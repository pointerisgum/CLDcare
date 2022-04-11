//
//  PopUpCalendarViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/08/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionBlock)(NSDate *);

@interface PopUpCalendarViewController : UIViewController
@property (nonatomic, copy) CompletionBlock completionBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
