//
//  PrescripDetailViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/08/29.
//

#import <UIKit/UIKit.h>
#import "NDPrescrip.h"

NS_ASSUME_NONNULL_BEGIN

@interface PrescripDetailViewController : UIViewController
@property (strong, nonatomic) NDPrescripHistory *item;
@property (strong, nonatomic) NSMutableDictionary *params;
@end

NS_ASSUME_NONNULL_END
