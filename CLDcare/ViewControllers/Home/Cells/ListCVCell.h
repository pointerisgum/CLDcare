//
//  ListCVCell.h
//  CLDcare
//
//  Created by 김영민 on 2021/10/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListCVCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *v_Bg;
@property (weak, nonatomic) IBOutlet UIView *v_Dot;
@property (weak, nonatomic) IBOutlet UIView *v_LeftDot;
@property (weak, nonatomic) IBOutlet UIView *v_RightDot;
@property (weak, nonatomic) IBOutlet UILabel *lb_Time;
@property (weak, nonatomic) IBOutlet UILabel *lb_Msg;
- (void)setFill:(BOOL)isFill;
@end

NS_ASSUME_NONNULL_END
