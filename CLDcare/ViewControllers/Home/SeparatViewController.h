//
//  SeparatViewController.h
//  CLDcare
//
//  Created by 김영민 on 2022/11/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SendMsgBlock)(NSInteger, NSInteger);
typedef void (^ShowSetUpBlock)(void);

@interface SeparatViewController : UIViewController
@property (nonatomic, copy) SendMsgBlock sendMsgBlock;
@property (nonatomic, copy) ShowSetUpBlock showSetUpBlock;
- (void)setSendMsgBlock:(SendMsgBlock)sendMsgBlock;
- (void)setShowSetUpBlock:(ShowSetUpBlock)showSetUpBlock;

@end

NS_ASSUME_NONNULL_END




