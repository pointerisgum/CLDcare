//
//  ListCVCell.m
//  CLDcare
//
//  Created by 김영민 on 2021/10/17.
//

#import "ListCVCell.h"

@implementation ListCVCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _v_Bg.layer.borderColor = [UIColor colorWithRed:220.0f/255.f green:220.0f/255.f blue:220.0f/255.f alpha:1].CGColor;
    _v_Bg.layer.borderWidth = 1;
    _v_Bg.layer.cornerRadius = 4;
    _v_Bg.clipsToBounds = true;
    
    _v_Dot.layer.borderColor = [UIColor linkColor].CGColor;
    _v_Dot.layer.borderWidth = 1;
    _v_Dot.layer.cornerRadius = 6;
    _v_Dot.clipsToBounds = true;
    
    [self setDot:_v_LeftDot];
    [self setDot:_v_RightDot];
}

- (void)setDot:(UIView *)view {
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor linkColor].CGColor;
    border.fillColor = nil;
    border.lineDashPattern = @[@4, @1];
    border.frame = view.bounds;
    border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    [view.layer addSublayer:border];
}

- (void)setFill:(BOOL)isFill {
    if( isFill ) {
        _v_Dot.backgroundColor = [UIColor linkColor];
    } else {
        _v_Dot.backgroundColor = [UIColor clearColor];
    }
}

@end
