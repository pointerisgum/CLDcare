//
//  Join2ViewController.h
//  CLDcare
//
//  Created by 김영민 on 2021/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Join2ViewController : BaseViewController
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *pw;
@property (nonatomic, assign) BOOL isGoogle;
@property (nonatomic, assign) BOOL isApple;
@property (nonatomic, strong) NSString *UID;
@end

NS_ASSUME_NONNULL_END
