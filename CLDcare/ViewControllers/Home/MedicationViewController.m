//
//  MedicationViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/14.
//

#import "MedicationViewController.h"
#import "ScheduleCell.h"
#import "NDMedication.h"
#import "NDHistory.h"

@interface MedicationViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (weak, nonatomic) IBOutlet UIView *v_ListEmpty;
@property (weak, nonatomic) IBOutlet UIView *v_ListBg;
@property (weak, nonatomic) IBOutlet UIView *v_ScheduleBg;
@property (weak, nonatomic) IBOutlet UIView *v_BottomShadow;
@property (weak, nonatomic) IBOutlet UILabel *lb_Today;
@property (weak, nonatomic) IBOutlet UILabel *lb_StandardTime;
@property (weak, nonatomic) IBOutlet UILabel *lb_MedicationStatus;  //복양여부: 복용함 | -
@property (weak, nonatomic) IBOutlet UILabel *lb_MedicationTime;    //오전 11:30
@property (weak, nonatomic) IBOutlet UILabel *lb_RemainDay;         //남은시간: 1
@property (weak, nonatomic) IBOutlet UILabel *lb_RemainDayFix;      //일전
@property (weak, nonatomic) IBOutlet UILabel *lb_MyMedication;      //나의 복약 정보
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSString *str_ToDayMedication;
@end

@implementation MedicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _items = [NSMutableArray array];
    
    _v_ScheduleBg.clipsToBounds = true;
    _v_ScheduleBg.layer.cornerRadius = 18;
    _v_ScheduleBg.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;

    _v_BottomShadow.layer.shadowOpacity = 0.2;
    _v_BottomShadow.layer.shadowOffset = CGSizeMake(0, 0);
    _v_BottomShadow.layer.shadowRadius = 10;
    _v_BottomShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    _v_BottomShadow.layer.masksToBounds = false;

    _lb_MedicationTime.hidden = true;
    _lb_RemainDayFix.hidden = true;
    _lb_MedicationStatus.text = @"-";
    _lb_RemainDay.text = @"-";
    _lb_StandardTime.text = @"-";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateData];
}

- (void)applicationDidEnterForeground:(NSNotification *)notification {
    [self updateData];
}

- (void)updateData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    _lb_Today.text = [dateFormatter stringFromDate:[NSDate date]];
    
    [self updateMedicationList];
}

- (void)reloadList {
    [self updateMedicationList];
}

- (void)updateMedicationList {
    [self.items removeAllObjects];

    NSString *deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( deviceName.length > 0 && email.length > 0 ) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [format stringFromDate:[NSDate date]];

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:email forKey:@"mem_email"];
        [dicM_Params setObject:dateString forKey:@"pairing_datetime"];
        [dicM_Params setObject:deviceName forKey:@"device_id"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"members/select/caregiverinfo" param:dicM_Params withMethod:@"POST" withBlock:^(id resulte, NSError *error, AFMsgCode msgCode) {
            if( error != nil ) {
//                [Util showAlert:NSLocalizedString(@"Invalid ID or password", nil) withVc:self];
                return;
            }
            
            if( msgCode == NO_INFORMATION ) {
                //해당정보 없을 시
                [self.tbv_List reloadData];
                return;
            }
            
            //약 연동 정보 가져오기
            NSArray *ar_Device = resulte[@"device_list"];
            for( NSInteger i = 0; i < ar_Device.count; i++ ) {
                NSDictionary *dic = ar_Device[i];
                if( [dic[@"device_id"] isEqualToString:deviceName] ) {
                    if( [dic[@"mapping_pill_info"] isEqualToString:@"Y"] ) {
                        self.lb_MyMedication.text = dic[@"mapping_pill_name"];
                    }
                    break;
                }
            }
            
            NSArray *ar_Alarm = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];

            NSLog(@"%@", resulte);
            NSDate *lastDate = nil;
            NSArray *ar_List = resulte[@"timeline_list"];
            if( ar_List.count > 0 ) {
                for( NSArray *sub in ar_List ) {
                    if( sub[0] != nil && sub[1] != nil ) {
                        NSString *dateString = sub[0];
                        NSDateFormatter *format = [[NSDateFormatter alloc] init];
                        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                        NSDate *date = [format dateFromString:dateString];
                        
                        MedicationStatusCode code = UNKNOW;
                        NSString *msg = @"";
                        NSString *type = sub[1];
                        if( [type isEqualToString:@"timeset"] ) {
                            msg = @"복약 시간 입니다.";
                        } else if( [type isEqualToString:@"timeset1"] ) {
//                            code = TIMESET1;
                            msg = @"아침 복약 시간 입니다.";
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[0];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                            }
                        } else if( [type isEqualToString:@"timeset2"] ) {
                            msg = @"점심 복약 시간 입니다.";
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[1];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                            }
                        } else if( [type isEqualToString:@"timeset3"] ) {
                            msg = @"저녁 복약 시간 입니다.";
                            if( ar_Alarm.count == 3 ) {
                                NSDictionary *dic = ar_Alarm[2];
                                if( [dic boolForKey:@"on"] != true ) {
                                    continue;
                                }
                            }
                        } else if( [type isEqualToString:@"dose"] ) {
                            msg = @"약을 복용 했습니다.";
                            lastDate = date;
                        } else if( [type isEqualToString:@"survey"] ) {
                            msg = @"설문을 완료 했습니다.";
                        } else if( [type isEqualToString:@"confirm"] ) {
                            msg = @"알람을 확인 했습니다.";
                        } else if( [type isEqualToString:@"snooze"] ) {
                            msg = @"알람을 미루었습니다.";
                        }
                        
                        self.str_ToDayMedication = resulte[@"today_medication"];
                        NDMedication *item = [[NDMedication alloc] initWithTime:[date timeIntervalSince1970] withType:code withMsg:msg];
                        [self.items addObject:item];
                    }
                }
            }

            if( [self.str_ToDayMedication isEqualToString:@"Y"] ) {
                if( lastDate != nil ) {
                    self.lb_MedicationTime.hidden = false;

                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
                    if( [language isEqualToString:@"ko"] ) {
                        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
                    } else {
                        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    }
                    [dateFormatter setDateFormat:@"a hh:mm"];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    self.lb_MedicationTime.text = [dateFormatter stringFromDate:lastDate];
                    self.lb_MedicationStatus.text = @"복용함";
                }
            }
            
            //남은시간
            NSInteger nWatingHour = -1;
            NSInteger nWatingMin = -1;
            NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *str_NowDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld",
                                     comp.year, comp.month, comp.day, comp.hour, comp.minute];
            NSDate *nowDate = [format dateFromString:str_NowDate];

            NSArray *arM_Alarms = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];
            if( arM_Alarms.count > 0 ) {
                for( NSDictionary *dic in arM_Alarms ) {
                    NSInteger nHour = [dic[@"hour"] integerValue];
                    NSInteger nMin = [dic[@"min"] integerValue];

                    NSString *str_AlarmDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld",
                                               comp.year, comp.month, comp.day, nHour, nMin];
                    NSDate *alarmDate = [format dateFromString:str_AlarmDate];
                    
                    NSDateComponents *compareComp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:alarmDate toDate:nowDate options:0];
                    NSLog(@"%ld", compareComp.hour);
                    NSLog(@"%ld", compareComp.minute);
                    if( compareComp.hour == 0 && compareComp.minute == 0 ) {
                        nWatingMin = 0;
                        break;
                    } else if( compareComp.hour < 0 || compareComp.minute < 0 ) {
                        nWatingHour = compareComp.hour * -1;
                        nWatingMin = compareComp.minute * -1;
                        break;
                    }
                }
                
                self.lb_RemainDayFix.hidden = false;

                if( nWatingHour > 0 ) {
                    self.lb_RemainDay.text = [NSString stringWithFormat:@"%ld", nWatingHour];
                    self.lb_RemainDayFix.text = @"시간 전";
                } else if( nWatingMin >= 0 ) {
                    self.lb_RemainDay.text = [NSString stringWithFormat:@"%ld", nWatingMin];
                    self.lb_RemainDayFix.text = @"분 전";
                } else if( nWatingHour < 0 && nWatingHour < 0 ) {
                    self.lb_RemainDay.text = @"1";
                    self.lb_RemainDayFix.text = @"일 전";
                }
            } else {
                self.lb_RemainDayFix.hidden = true;
                self.lb_RemainDay.text = @"-";
            }
            
            //나의 복약 정보 날짜
            self.lb_StandardTime.text = [NSString stringWithFormat:@"%@ 기준", [format stringFromDate:[NSDate date]]];

            [self.tbv_List reloadData];
            
            if( self.items.count > 0 ) {
//                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tbv_List numberOfRowsInSection:0] - 1) inSection:0];
//                [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
            }
        }];
    } else {
        [self.tbv_List reloadData];
        if( self.items.count > 0 ) {
//            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tbv_List numberOfRowsInSection:0] - 1) inSection:0];
//            [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
        }
    }
}

- (void)updateInfo:(dispenser_manuf_data_t *)md {
    if( md == nil ) {
        _lb_MedicationTime.hidden = true;
        _lb_RemainDayFix.hidden = true;
        _lb_MedicationStatus.text = @"-";
        _lb_RemainDay.text = @"-";
        _lb_StandardTime.text = @"-";
    } else {
        _lb_MedicationTime.hidden = false;
        _lb_RemainDayFix.hidden = false;
        
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if( [language isEqualToString:@"ko"] ) {
            dateFormatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
        } else {
            dateFormatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        }
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
//        [dateFormatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        _lb_StandardTime.text = [NSString stringWithFormat:@"%@ 기준", [dateFormatter1 stringFromDate:[NSDate date]]];

        if( md->count == 0 ) {
            _lb_MedicationTime.text = @"-";
            _lb_MedicationStatus.text = @"-";
        } else {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:(md->epochtime1 - (60 * 60 * 9))];
//            NSDate *date = [NSDate dateWithTimeIntervalSince1970:(md->epochtime1)];
            NSDateComponents *targetComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];

            NSDateComponents *toDayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];

            if( targetComp.year == toDayComp.year && targetComp.month == toDayComp.month && targetComp.day == toDayComp.day ) {
                //오늘 복용 했을 경우
                NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
                NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
                if( [language isEqualToString:@"ko"] ) {
                    dateFormatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
                } else {
                    dateFormatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                }
                [dateFormatter2 setDateFormat:@"a hh:mm"];
                [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                _lb_MedicationTime.text = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:date.timeIntervalSince1970 + (60 * 60 * 9)]];
                _lb_MedicationStatus.text = @"복용함";
            } else {
                _lb_MedicationTime.text = @"-";
                _lb_MedicationStatus.text = @"-";
            }
        }
    }
}

- (void)addList:(NSTimeInterval)time {
    BOOL isHave = false;
    NDMedication *item = [[NDMedication alloc] initWithTime:time withType:DOSE withMsg:@"약을 복용했습니다."];
    for( NDMedication *obj in _items ) {
        if( item.time == obj.time ) {
            isHave = true;
            break;
        }
    }
    
    if( isHave == false ) {
        [_items addObject:item];
        [_tbv_List reloadData];
//        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([_tbv_List numberOfRowsInSection:0] - 1) inSection:0];
//        [_tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_tbv_List scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( _items.count > 0 ) {
        _v_ListEmpty.hidden = true;
        _v_ListBg.hidden = false;
    } else {
        _v_ListEmpty.hidden = false;
        _v_ListBg.hidden = true;
    }
    
    NSSortDescriptor* sortDes = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    [_items sortUsingDescriptors:[NSArray arrayWithObject:sortDes]];

    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleCell* cell = (ScheduleCell*)[tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];

    if( _items.count <= indexPath.row ) {
        return cell;
    }
    
    NDMedication *item = _items[indexPath.row];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(item.time)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if( [language isEqualToString:@"ko"] ) {
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    } else {
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
//    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setDateFormat:@"a hh:mm"];

    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    cell.lb_Time.text = [dateFormatter stringFromDate:date];
    cell.lb_Title.text = item.msg;
    cell.btn_Status.selected = false;
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] + (60 * 60 * 9);
    nowTime += 60;
    if( item.time < nowTime ) {
        cell.btn_Status.selected = true;
    } else {
//        if( item.code == DOSE ) {
//            cell.btn_Status.selected = true;
//        } else {
//            cell.btn_Status.selected = false;
//        }
        cell.btn_Status.selected = false;
    }
    
//    switch (item.code) {
//        case DOSE:
//            cell.lb_Title.text = @"약을 복용했습니다.";
//            break;
//
//        default:
//            cell.lb_Title.text = @"";
//            break;
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}

@end
