//
//  DeviceInfoViewController.h
//  CLDcare
//
//  Created by 김영민 on 2022/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UpdateFw)(void);

@interface DeviceInfoViewController : UIViewController

@property (nonatomic, copy) UpdateFw updateFw;

- (void)setUpdateFw:(UpdateFw)updateFw;

@end

NS_ASSUME_NONNULL_END
