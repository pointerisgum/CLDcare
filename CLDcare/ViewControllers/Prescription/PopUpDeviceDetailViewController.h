//
//  PopUpDeviceDetailViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import <UIKit/UIKit.h>
#import "NDDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface PopUpDeviceDetailViewController : UIViewController
@property (strong, nonatomic) NDDevice *device;
@end

NS_ASSUME_NONNULL_END
