//
//  MediRecordCell.m
//  CLDcare
//
//  Created by 김영민 on 2022/12/12.
//

#import "MediRecordCell.h"

@implementation MediRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.v_Circle.layer.cornerRadius = 4;
    self.v_Circle.clipsToBounds = true;
    
    [self setDot:_v_TopLine];
    [self setDot:_v_BottomLine];
}

- (void)setDot:(UIView *)view {
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor linkColor].CGColor;
    border.fillColor = nil;
    border.lineDashPattern = @[@3, @1];
    border.frame = view.bounds;
    border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    [view.layer addSublayer:border];
}

@end
