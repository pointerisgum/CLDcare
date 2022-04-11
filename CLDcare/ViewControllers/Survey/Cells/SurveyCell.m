//
//  SurveyCell.m
//  Coledy
//
//  Created by 김영민 on 2021/09/02.
//

#import "SurveyCell.h"

@implementation SurveyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _v_Bg.clipsToBounds = true;
    _v_Bg.layer.cornerRadius = 2;
    _v_Bg.layer.borderWidth = 1;
    _v_Bg.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)selectItem:(BOOL)selected {
    if( selected ) {
        _v_Bg.backgroundColor = [UIColor colorWithHexString:@"E8F7F9"];
        _lb_Title.textColor = [UIColor colorWithHexString:@"007181"];
    } else {
        _v_Bg.backgroundColor = [UIColor whiteColor];
        _lb_Title.textColor = [UIColor colorWithHexString:@"8b8b8b"];
    }
}

@end
