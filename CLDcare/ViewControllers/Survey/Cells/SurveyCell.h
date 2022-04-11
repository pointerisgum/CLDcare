//
//  SurveyCell.h
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SurveyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *v_Bg;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
- (void)selectItem:(BOOL)selected;
@end

NS_ASSUME_NONNULL_END
