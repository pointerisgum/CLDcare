//
//  MedicationViewController.h
//  Coledy
//
//  Created by 김영민 on 2021/07/14.
//

#import <UIKit/UIKit.h>
#import "adv_data.h"

NS_ASSUME_NONNULL_BEGIN

@interface MedicationViewController : UIViewController
- (void)updateInfo:(nullable dispenser_manuf_data_t *)md;
- (void)addList:(NSTimeInterval)time;
- (void)reloadList;
@end

NS_ASSUME_NONNULL_END
