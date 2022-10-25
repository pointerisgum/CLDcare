//
//  FrimwareCheckPopupViewController.h
//  CLDcare
//
//  Created by 김영민 on 2022/09/03.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FirmwareUpdate)(void);

@interface FrimwareCheckPopupViewController : UIViewController

@property (nonatomic, copy) FirmwareUpdate firmwareUpdate;
- (void)setFirmwareUpdate:(FirmwareUpdate)firmwareUpdate;

@end

NS_ASSUME_NONNULL_END
