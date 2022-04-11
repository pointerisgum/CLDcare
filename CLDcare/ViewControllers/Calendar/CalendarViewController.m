//
//  CalendarViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/24.
//

#import "CalendarViewController.h"
#import "FSCalendar.h"
#import "ActionSheetPicker.h"

@interface CalendarViewController () <FSCalendarDelegate, FSCalendarDataSource, ActionSheetCustomPickerDelegate>
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIButton *btn_Month;
@property (weak, nonatomic) IBOutlet UIImageView *iv_MonthArrow;
@property (weak, nonatomic) IBOutlet UILabel *lb_DeviceName;
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_TakenFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_UnTakenFix;
@property (weak, nonatomic) IBOutlet UILabel *lb_OverdoseFix;
@property (assign, nonatomic) NSInteger nCurrentMonth;
@property (strong, nonatomic) NSDictionary *dic_Doses;
@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_TitleFix.text = NSLocalizedString(@"Medication Calendar", nil);
    _lb_TakenFix.text = NSLocalizedString(@"Taken", nil);
    _lb_UnTakenFix.text = NSLocalizedString(@"Un-taken", nil);
    _lb_OverdoseFix.text = NSLocalizedString(@"Overdose", nil);

    _calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
 
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [_btn_Month setTitle:[NSString stringWithFormat:@"%04ld. %02ld", comp.year, comp.month] forState:UIControlStateNormal];
    _nCurrentMonth = comp.month;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateList)
                                                 name:@"DoseNoti"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *str_DeviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    if( str_DeviceName.length > 0 ) {
        _lb_DeviceName.text = str_DeviceName;
    } else {
        _lb_DeviceName.text = @"";
    }
    
    [self updateList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_calendar.currentPage];
    [_btn_Month setTitle:[NSString stringWithFormat:@"%04ld. %02ld", comp.year, comp.month] forState:UIControlStateNormal];
    _nCurrentMonth = comp.month;
}

- (void)updateList {
    if( _nCurrentMonth == 0 ) {
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        _nCurrentMonth = comp.month;
    }

    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];

    if( deviceName == nil || deviceName.length <= 0 ) { return; }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:email forKey:@"mem_email"];
    [dicM_Params setObject:deviceName forKey:@"device_id"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", _nCurrentMonth] forKey:@"current_month"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/select/dosewhether" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
        if( error != nil ) {
            return;
        }
        
        self.dic_Doses = resulte[@"days_dic"];
        [self.calendar reloadData];
    }];
}

#pragma mark - FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    NSLog(@"%@", date);
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:calendar.currentPage];
    [_btn_Month setTitle:[NSString stringWithFormat:@"%04ld. %02ld", comp.year, comp.month] forState:UIControlStateNormal];
    _nCurrentMonth = comp.month;
    _dic_Doses = nil;
    [self updateList];
}

#pragma mark - FSCalendarDataSource
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *toDayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger nDate = [[NSString stringWithFormat:@"%04ld%02ld%02ld", comp.year, comp.month, comp.day] integerValue];
    NSInteger nTodayDate = [[NSString stringWithFormat:@"%04ld%02ld%02ld", toDayComp.year, toDayComp.month, toDayComp.day] integerValue];
    
    if( nDate > nTodayDate ) {
        return 0;
    }
    return 1;
}

- (nullable NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    if( _nCurrentMonth != comp.month ) {
        return @[[UIColor clearColor]];
    }

    NSString *str_Day = [NSString stringWithFormat:@"%ld", comp.day];
    NSInteger nDoseCnt = [self.dic_Doses[str_Day] integerValue];
    if( nDoseCnt > 1 ) {
        //초과복용
        return @[[UIColor colorWithHexString:@"eb6f6f"]];
    } else if( nDoseCnt == 1 ) {
        //정상복용
        return @[MAIN_COLOR];
    }
    //미복용
    return @[[UIColor colorWithHexString:@"e5e5e5"]];
}


#pragma mark - Action
- (IBAction)goExChange:(id)sender {
    
    
}

- (IBAction)goChangeMonth:(id)sender {
    NSMutableArray *arM = [NSMutableArray array];
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if( [language isEqualToString:@"ko"] ) {
        for( NSInteger i = 1; i <= 12; i++ ) {
            [arM addObject:[NSString stringWithFormat:@"%ld월", i]];
        }
    } else {
        [arM addObject:@"Jan"];
        [arM addObject:@"Feb"];
        [arM addObject:@"Mar"];
        [arM addObject:@"Apr"];
        [arM addObject:@"May"];
        [arM addObject:@"Jun"];
        [arM addObject:@"Jul"];
        [arM addObject:@"Aug"];
        [arM addObject:@"Sep"];
        [arM addObject:@"Oct"];
        [arM addObject:@"Nov"];
        [arM addObject:@"Dec"];
    }

//    [UIView animateWithDuration:0.15 animations:^{
//        self.iv_MonthArrow.transform = CGAffineTransformMakeRotation(M_PI);
//    }];
    

    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSLog(@"Picker: %@", picker);
        NSLog(@"Selected Index: %@", @(selectedIndex));
        NSLog(@"Selected Value: %@", selectedValue);
        
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.calendar.currentPage];

        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *str_Date = [NSString stringWithFormat:@"%04ld-%02ld-01", comp.year, selectedIndex + 1];
        NSDate *date = [format dateFromString:str_Date];
        self.nCurrentMonth = comp.month;
        [self.calendar setCurrentPage:date animated:true];
        
        [self updateList];

//        [UIView animateWithDuration:0.15 animations:^{
//            self.iv_MonthArrow.transform = CGAffineTransformIdentity;
//        }];
    };
    
    
//    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
//        [UIView animateWithDuration:0.15 animations:^{
//            self.iv_MonthArrow.transform = CGAffineTransformIdentity;
//        }];
//    };
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Selection Month", nil) rows:arM initialSelection:_nCurrentMonth - 1 doneBlock:done cancelBlock:nil origin:sender];

//    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"월 선택"
//                                                                                rows:arM
//                                                                    initialSelection:_nCurrentMonth - 1
//                                                                           doneBlock:done
//                                                                         cancelBlock:cancel
//                                                                              origin:sender];
//    [picker showActionSheetPicker];
}

@end
