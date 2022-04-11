//
//  DeviceCell.h
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceName;
@property (weak, nonatomic) IBOutlet UILabel *lb_MacAddr;
@property (weak, nonatomic) IBOutlet UIButton *btn_Connect;

@end

NS_ASSUME_NONNULL_END
