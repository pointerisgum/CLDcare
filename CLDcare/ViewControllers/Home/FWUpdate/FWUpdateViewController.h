//
//  FWUpdateViewController.h
//  CLDcare
//
//  Created by 김영민 on 2022/09/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FinishFirmwareUpdate)(void);
typedef void (^StartFirmwareUpdate)(void);
typedef void (^PauseFirmwareUpdate)(void);
typedef void (^ResumeFirmwareUpdate)(void);
typedef void (^CancelFirmwareUpdate)(void);
typedef void (^CloseFirmwareUpdate)(void);

@interface FWUpdateViewController : UIViewController
@property (nonatomic, assign) BOOL isInitMode;
@property (nonatomic, copy) FinishFirmwareUpdate finishFirmwareUpdate;
@property (nonatomic, copy) StartFirmwareUpdate startFirmwareUpdate;
@property (nonatomic, copy) PauseFirmwareUpdate pauseFirmwareUpdate;
@property (nonatomic, copy) ResumeFirmwareUpdate resumeFirmwareUpdate;
@property (nonatomic, copy) CancelFirmwareUpdate cancelFirmwareUpdate;
@property (nonatomic, copy) CloseFirmwareUpdate closeFirmwareUpdate;
- (void)setFinishFirmwareUpdate:(FinishFirmwareUpdate)finishFirmwareUpdate;
- (void)setStartFirmwareUpdate:(StartFirmwareUpdate)startFirmwareUpdate;
- (void)setPauseFirmwareUpdate:(PauseFirmwareUpdate)pauseFirmwareUpdate;
- (void)setResumeFirmwareUpdate:(ResumeFirmwareUpdate)resumeFirmwareUpdate;
- (void)setCancelFirmwareUpdate:(CancelFirmwareUpdate)cancelFirmwareUpdate;
- (void)setCloseFirmwareUpdate:(CloseFirmwareUpdate)closeFirmwareUpdate;
- (void)updatePer:(NSInteger)per;
- (void)updateFinish;
@end

NS_ASSUME_NONNULL_END


