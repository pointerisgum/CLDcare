//
//  SurveryAccView.m
//  Coledy
//
//  Created by 김영민 on 2021/09/13.
//

#import "SurveryAccView.h"

@implementation SurveryAccView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_btn_Cancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_btn_Confirm setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    
    _btn_Cancel.clipsToBounds = true;
    _btn_Cancel.layer.borderWidth = 1;
    _btn_Cancel.layer.borderColor = [UIColor colorWithHexString:@"ECECEC"].CGColor;
    _btn_Cancel.layer.cornerRadius = 2;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
