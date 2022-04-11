//
//  PopUpCalendarViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/08/26.
//

#import "PopUpCalendarViewController.h"
#import "FSCalendar.h"
#import "ActionSheetPicker.h"

@interface PopUpCalendarViewController ()
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIButton *btn_Month;
@property (assign, nonatomic) NSInteger nCurrentMonth;
@end

@implementation PopUpCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [_btn_Month setTitle:[NSString stringWithFormat:@"%04ld. %02ld", comp.year, comp.month] forState:UIControlStateNormal];
    _nCurrentMonth = comp.month;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_calendar.currentPage];
    [_btn_Month setTitle:[NSString stringWithFormat:@"%04ld. %02ld", comp.year, comp.month] forState:UIControlStateNormal];
    _nCurrentMonth = comp.month;
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

    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSLog(@"Picker: %@", picker);
        NSLog(@"Selected Index: %@", @(selectedIndex));
        NSLog(@"Selected Value: %@", selectedValue);
        
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.calendar.currentPage];

        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *str_Date = [NSString stringWithFormat:@"%04ld-%02ld-01", comp.year, selectedIndex + 1];
        NSDate *date = [format dateFromString:str_Date];
        [self.calendar setCurrentPage:date animated:true];
        self.nCurrentMonth = comp.month;
        [self.calendar reloadData];
    };
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Selection Month", nil) rows:arM initialSelection:_nCurrentMonth - 1 doneBlock:done cancelBlock:nil origin:sender];
}


#pragma mark - FSCalendarDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    NSLog(@"%@", date);
    [self dismissViewControllerAnimated:true completion:^{
        if( self.completionBlock ) {
            self.completionBlock(date);
        }
    }];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:calendar.currentPage];
    [_btn_Month setTitle:[NSString stringWithFormat:@"%04ld. %02ld", comp.year, comp.month] forState:UIControlStateNormal];
    _nCurrentMonth = comp.month;
    [self.calendar reloadData];
}

//#pragma mark - FSCalendarDataSource
//- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
//    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
//    NSDateComponents *toDayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
//    NSInteger nDate = [[NSString stringWithFormat:@"%04ld%02ld%02ld", comp.year, comp.month, comp.day] integerValue];
//    NSInteger nTodayDate = [[NSString stringWithFormat:@"%04ld%02ld%02ld", toDayComp.year, toDayComp.month, toDayComp.day] integerValue];
//
//    if( nDate > nTodayDate ) {
//        return 0;
//    }
//    return 1;
//}
//
//- (nullable NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
//    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
//
//    NSString *str_Day = [NSString stringWithFormat:@"%ld", comp.day];
//    NSInteger nDoseCnt = [self.dic_Doses[str_Day] integerValue];
//    if( nDoseCnt > 1 ) {
//        //초과복용
//        return @[[UIColor colorWithHexString:@"eb6f6f"]];
//    } else if( nDoseCnt == 1 ) {
//        //정상복용
//        return @[MAIN_COLOR];
//    }
//    //미복용
//    return @[[UIColor colorWithHexString:@"e5e5e5"]];
//}


@end
