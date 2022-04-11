//
//  ScheduleCell.h
//  Coledy
//
//  Created by 김영민 on 2021/07/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btn_Status;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_Time;
@end

NS_ASSUME_NONNULL_END
