//
//  UIColor+CALayer.m
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import "UIColor+CALayer.h"

@implementation CALayer(UIColor)

- (void)setBorderUIColor:(UIColor*)color {
    self.borderColor = color.CGColor;
}

- (UIColor*)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
