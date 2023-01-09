//
//  MediAlarmViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/11/29.
//

#import "MediAlarmViewController.h"
#import "MDMediSetUpData.h"
#import "ActionSheetPicker.h"

@interface MediAlarmViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents;
@property (weak, nonatomic) IBOutlet UILabel *lb_RemindFix;
@property (weak, nonatomic) IBOutlet UISwitch *sw;
@property (weak, nonatomic) IBOutlet UIButton *btn_Select;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, strong) NSDate *selectedDate;
//@property (strong, nonatomic) NSMutableArray *arM;
@end

@implementation MediAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isLast = false;
    
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if( [language isEqualToString:@"ko"] ) {
        [_picker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"]];
    } else {
        [_picker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:00"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *str_Today = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *date = [dateFormatter dateFromString:str_Today];
    _picker.date = date;
    _selectedDate = _picker.date;
    
    switch(_alarmSetUp) {
        case ALARM1: {
            [MDMediSetUpData sharedData].alarms = [NSMutableDictionary dictionary];
            if( [[MDMediSetUpData sharedData].dayTakeCount isEqualToString:NSLocalizedString(@"Once daily", nil)] ) {
                _isLast = true;
//                [_btn_Next setTitle:NSLocalizedString(@"Complete", nil) forState:UIControlStateNormal];
            }
            _lb_Title.text = NSLocalizedString(@"1st dose", nil);
            _lb_Contents.text = NSLocalizedString(@"What time do you need to take the 1st Dose?", nil);
        } break;
            
        case ALARM2: {
            if( [[MDMediSetUpData sharedData].dayTakeCount isEqualToString:NSLocalizedString(@"Twice daily", nil)] ) {
                _isLast = true;
//                [_btn_Next setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            }
            _lb_Title.text = NSLocalizedString(@"2nd dose", nil);
            _lb_Contents.text = NSLocalizedString(@"What time do you need to take the 2nd Dose?", nil);
        } break;
            
        case ALARM3: {
            if( [[MDMediSetUpData sharedData].dayTakeCount isEqualToString:NSLocalizedString(@"3 times a day", nil)] ) {
                _isLast = true;
//                [_btn_Next setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            }
            _lb_Title.text = NSLocalizedString(@"3rd dose", nil);
            _lb_Contents.text = NSLocalizedString(@"What time do you need to take the 3rd Dose?", nil);
        } break;
            
        case ALARM4: {
            if( [[MDMediSetUpData sharedData].dayTakeCount isEqualToString:NSLocalizedString(@"4 times a day", nil)] ) {
                _isLast = true;
//                [_btn_Next setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            }
            _lb_Title.text = NSLocalizedString(@"4th dose", nil);
            _lb_Contents.text = NSLocalizedString(@"What time do you need to take the 4th Dose?", nil);
        } break;
    }
    
//    [self goChooise:nil];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//
//    _selectedDate = nil;
//
//    switch(_alarmSetUp) {
//        case ALARM1: {
//            [[MDMediSetUpData sharedData].alarms removeObjectForKey:@"1"];
//        } break;
//
//        case ALARM2: {
//            [[MDMediSetUpData sharedData].alarms removeObjectForKey:@"2"];
//        } break;
//
//        case ALARM3: {
//            [[MDMediSetUpData sharedData].alarms removeObjectForKey:@"3"];
//        } break;
//
//        case ALARM4: {
//            [[MDMediSetUpData sharedData].alarms removeObjectForKey:@"4"];
//        } break;
//    }
//}

- (void)showPicker:(id)selectedDate withBlock:(void(^)(NSString * resulte))completion {
}

- (void)finish {
    //설정완료
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpFinishViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)goSwich:(id)sender {
    
}

//- (IBAction)goChooise:(id)sender {
//    [ActionSheetDatePicker showPickerWithTitle:NSLocalizedString(@"Set Alarm", nil)
//                                datePickerMode:UIDatePickerModeTime
//                                  selectedDate:[NSDate date]
//                                     doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
//        self.selectedDate = selectedDate;
//        //        [self goNext:nil];
//    } cancelBlock:^(ActionSheetDatePicker *picker) {
//    } origin:_btn_Select];
//}

- (IBAction)goNext:(id)sender {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    if( _selectedDate == nil ) {
        _selectedDate = _picker.date;
    }
    
    if( _selectedDate ) {
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:_selectedDate];
        [dicM setObject:@(comp.hour) forKey:@"hour"];
        [dicM setObject:@(comp.minute) forKey:@"min"];
        [dicM setObject:@(self.sw.on) forKey:@"on"];
    }
    
    AlarmStep nextStep = ALARM2;
    
    switch(_alarmSetUp) {
        case ALARM1: {
            [[MDMediSetUpData sharedData].alarms setObject:dicM forKey:@"1"];
            nextStep = ALARM2;
        } break;
            
        case ALARM2: {
            [[MDMediSetUpData sharedData].alarms setObject:dicM forKey:@"2"];
            nextStep = ALARM3;
        } break;
            
        case ALARM3: {
            [[MDMediSetUpData sharedData].alarms setObject:dicM forKey:@"3"];
            nextStep = ALARM4;
        } break;
            
        case ALARM4: {
            [[MDMediSetUpData sharedData].alarms setObject:dicM forKey:@"4"];
            //            [self finish];
        } break;
    }
    
    if( _isLast == true ) {
        //설정완료
        [self finish];
        return;
    }
    
    MediAlarmViewController *vc = (MediAlarmViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediAlarmViewController"];
    vc.alarmSetUp = nextStep;
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)goDateChange:(id)sender {
    _selectedDate = _picker.date;
    NSLog(@"%@", _picker.date);
}

@end

