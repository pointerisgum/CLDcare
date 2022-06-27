//
//  ClauseViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClauseViewController : BaseViewController
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) BOOL isGoogle;
@property (nonatomic, assign) BOOL isApple;
@property (nonatomic, strong) NSString *UID;
@end

NS_ASSUME_NONNULL_END
