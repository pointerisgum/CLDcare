//
//  AlarmCell.h
//  Coledy
//
//  Created by 김영민 on 2021/07/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlarmCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lb_Type;
@property (weak, nonatomic) IBOutlet UILabel *lb_AmPm;
@property (weak, nonatomic) IBOutlet UILabel *lb_Time;
@property (weak, nonatomic) IBOutlet UISwitch *sw;
@property (weak, nonatomic) IBOutlet UIButton *btn_Modify;
@end

NS_ASSUME_NONNULL_END
