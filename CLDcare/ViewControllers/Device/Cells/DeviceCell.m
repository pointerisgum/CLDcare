//
//  DeviceCell.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "DeviceCell.h"

@implementation DeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [_btn_Connect setTitle:NSLocalizedString(@"Pair Now", nil) forState:0];
    
    _lb_DeviceName.text = @"";
    _lb_MacAddr.text = @"";

    _btn_Connect.layer.cornerRadius = 2;
    _btn_Connect.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
