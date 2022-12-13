//
//  MediRecordCell.h
//  CLDcare
//
//  Created by 김영민 on 2022/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *v_Circle;
@property (weak, nonatomic) IBOutlet UILabel *lb_Time;
@property (weak, nonatomic) IBOutlet UILabel *lb_Status;
@property (weak, nonatomic) IBOutlet UIView *v_TopLine;
@property (weak, nonatomic) IBOutlet UIView *v_BottomLine;
@end

NS_ASSUME_NONNULL_END
