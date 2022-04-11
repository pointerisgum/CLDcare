//
//  PrescripCell.h
//  Coledy
//
//  Created by 김영민 on 2021/08/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrescripCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_Date;
@end

NS_ASSUME_NONNULL_END
