//
//  InphrLoginViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionBlock)(BOOL isShowClause);

@interface InphrLoginViewController : UIViewController
@property (nonatomic, copy) CompletionBlock completionBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
@end

NS_ASSUME_NONNULL_END
