//
//  MediAlarmViewController.h
//  CLDcare
//
//  Created by 김영민 on 2022/11/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ALARM1,
    ALARM2,
    ALARM3,
    ALARM4,
} AlarmStep;

@interface MediAlarmViewController : UIViewController
@property (nonatomic, assign) AlarmStep alarmSetUp;
@end

NS_ASSUME_NONNULL_END
