//
//  AlarmDetailViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/25.
//

#import "AlarmDetailViewController.h"
#import "AlarmCell.h"
#import "ActionSheetPicker.h"
@import UserNotifications;

@interface AlarmDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_DeleteAll;
@property (weak, nonatomic) IBOutlet UIButton *btn_EditDone;
@property (weak, nonatomic) IBOutlet UIButton *btn_Edit;
@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (weak, nonatomic) IBOutlet UIView *v_AddBg;
@property (strong, nonatomic) NSMutableArray *arM_Alarms;
@property (weak, nonatomic) IBOutlet UILabel *lb_TitleFix;
@end

@implementation AlarmDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _lb_TitleFix.text = NSLocalizedString(@"Reminder Times", nil);
    
    _v_AddBg.layer.shadowOpacity = 0.8f;
    _v_AddBg.layer.shadowOffset = CGSizeMake(0, 0);
    _v_AddBg.layer.shadowRadius = 20;
    _v_AddBg.layer.shadowColor = MAIN_COLOR.CGColor;
    _v_AddBg.layer.masksToBounds = false;

    _btn_DeleteAll.hidden = true;
    _btn_EditDone.hidden = true;
    _btn_Edit.hidden = false;
    
    NSArray *ar = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alarms"];
    _arM_Alarms = [NSMutableArray arrayWithArray:ar];
//    if( ar == nil ) {
////    if( 1 ) {
//        _arM_Alarms = [NSMutableArray array];
//        [_arM_Alarms addObject:@{@"hour":@(8), @"min":@(30), @"on":@(false)}];
//        [_arM_Alarms addObject:@{@"hour":@(13), @"min":@(30), @"on":@(false)}];
//        [_arM_Alarms addObject:@{@"hour":@(19), @"min":@(30), @"on":@(false)}];
//
//        [Util saveAlarm:_arM_Alarms];
//    } else {
//        _arM_Alarms = [NSMutableArray arrayWithArray:ar];
//    }
    
    [_tbv_List reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    BOOL isAlarm = [[NSUserDefaults standardUserDefaults] boolForKey:@"Alarm"];
    if( isAlarm ) {
        [Util saveAlarm:_arM_Alarms];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

//- (void)addAlarm {
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    [center removeAllPendingNotificationRequests];
//
//    for( NSDictionary *dic in _arM_Alarms ) {
//        BOOL isOn = [dic[@"on"] boolValue];
//        if( isOn ) {
//            NSInteger nHour = [dic[@"hour"] integerValue];
//            NSInteger nMin = [dic[@"min"] integerValue];
//            
//            UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
//            content.body = [NSString localizedUserNotificationStringForKey:@"약 먹을 시간이예요."
//                    arguments:nil];
//            content.sound = [UNNotificationSound defaultSound];
//
//            NSDateComponents* date = [[NSDateComponents alloc] init];
//            date.hour = nHour;
//            date.minute = nMin;
//            UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
//                   triggerWithDateMatchingComponents:date repeats:true];
//
//            NSString *str_Ident = [NSString stringWithFormat:@"%02ld%02ld", nHour, nMin];
//            UNNotificationRequest* request = [UNNotificationRequest
//                   requestWithIdentifier:str_Ident content:content trigger:trigger];
//            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
//        }
//    }
//}

- (void)alarmStatusChange:(UISwitch *)sender {
    NSDictionary *dic_Tmp = _arM_Alarms[sender.tag];
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
    [dicM setObject:@(sender.on) forKey:@"on"];
    [_arM_Alarms replaceObjectAtIndex:sender.tag withObject:dicM];
    [_tbv_List reloadData];
    
//    //알람 켜진게 하나라도 있는데 복얄알림이 껴진 경우 강제로 on
//    BOOL isHaveAlarm = false;
//    for( NSDictionary *dic in _arM_Alarms ) {
//        BOOL isAlarmOn = [dic[@"on"] integerValue];
//        if( isAlarmOn ) {
//            isHaveAlarm = true;
//        }
//    }
//
//    //알람이 모두 꺼져 있을 경우 어차피 로컬 알람을 지우기 때문에 푸시를 해제 할 필요는 없음
//    BOOL isAlarmOnOff = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
//    if( isAlarmOnOff == false) {
//        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
//        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
//
//        }];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
}


#pragma mark - Noti
- (void)applicationWillTerminate:(NSNotification *)notification {
    BOOL isAlarm = [[NSUserDefaults standardUserDefaults] boolForKey:@"Alarm"];
    if( isAlarm ) {
        [Util saveAlarm:_arM_Alarms];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    BOOL isAlarm = [[NSUserDefaults standardUserDefaults] boolForKey:@"Alarm"];
    if( isAlarm ) {
        [Util saveAlarm:_arM_Alarms];
    }
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arM_Alarms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlarmCell* cell = (AlarmCell*)[tableView dequeueReusableCellWithIdentifier:@"AlarmCell"];
    NSDictionary *dic = _arM_Alarms[indexPath.row];
    
    NSInteger nHour = [dic[@"hour"] integerValue];
    NSInteger nMin = [dic[@"min"] integerValue];
    BOOL isOn = [dic[@"on"] boolValue];

    if( nHour > 12 ) {
        cell.lb_AmPm.text = NSLocalizedString(@"PM", nil);
        nHour -= 12;
    } else if( nHour == 12 ) {
        cell.lb_AmPm.text = NSLocalizedString(@"PM", nil);
    } else {
        cell.lb_AmPm.text = NSLocalizedString(@"AM", nil);
    }
    
    cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", nHour, nMin];
    cell.sw.on = isOn;
    cell.sw.tag = indexPath.row;
    [cell.sw addTarget:self action:@selector(alarmStatusChange:) forControlEvents:UIControlEventValueChanged];

    cell.btn_Modify.tag = indexPath.row;
    cell.btn_Modify.userInteractionEnabled = cell.sw.on;
    [cell.btn_Modify addTarget:self action:@selector(onAlarmModify:) forControlEvents:UIControlEventTouchUpInside];
    
    if( cell.sw.on ) {
        cell.lb_Type.alpha = cell.lb_Time.alpha = cell.lb_AmPm.alpha = 1;
    } else {
        cell.lb_Type.alpha = cell.lb_Time.alpha = cell.lb_AmPm.alpha = 0.3f;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.lb_Type.text = NSLocalizedString(@"morning", nil);
            break;
        case 1:
            cell.lb_Type.text = NSLocalizedString(@"afternoon", nil);
            break;
        case 2:
            cell.lb_Type.text = NSLocalizedString(@"evening", nil);
            break;
        default:
            cell.lb_Type.text = @"";
            break;
    }
    return cell;
}

- (void)onAlarmModify:(UIButton *)sender {
    NSDictionary *dic = _arM_Alarms[sender.tag];
    NSInteger nHour = [dic[@"hour"] integerValue];
    NSInteger nMin = [dic[@"min"] integerValue];

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    NSString *str_Date = [NSString stringWithFormat:@"%02ld-%02ld", nHour, nMin];
    NSDate *date = [format dateFromString:str_Date];

    [ActionSheetDatePicker showPickerWithTitle:@"알람 수정"
                                datePickerMode:UIDatePickerModeTime
                                  selectedDate:date
                                     doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:selectedDate];
        NSDictionary *dic_Tmp = self.arM_Alarms[sender.tag];
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
        [dicM setObject:@(comp.hour) forKey:@"hour"];
        [dicM setObject:@(comp.minute) forKey:@"min"];
        [self.arM_Alarms replaceObjectAtIndex:sender.tag withObject:dicM];
        
//        NSSortDescriptor* sortDes1 = [[NSSortDescriptor alloc] initWithKey:@"hour" ascending:YES];
//        NSSortDescriptor* sortDes2 = [[NSSortDescriptor alloc] initWithKey:@"min" ascending:YES];
//        [self.arM_Alarms sortUsingDescriptors:[NSArray arrayWithObjects:sortDes1, sortDes2, nil]];

        BOOL isAlarm = [[NSUserDefaults standardUserDefaults] boolForKey:@"Alarm"];
        if( isAlarm ) {
            [Util saveAlarm:self.arM_Alarms];
        }

        [self.tbv_List reloadData];
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:sender];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return true;
    return false;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_arM_Alarms removeObjectAtIndex:indexPath.row];
        BOOL isAlarm = [[NSUserDefaults standardUserDefaults] boolForKey:@"Alarm"];
        if( isAlarm ) {
            [Util saveAlarm:_arM_Alarms];
        }
        [_tbv_List reloadData];
    }
}


#pragma mark - Action
- (IBAction)goEdit:(UIButton *)sender {
    if( _arM_Alarms == nil || _arM_Alarms.count == 0 ) { return; }
    
    _btn_DeleteAll.hidden = false;
    _btn_EditDone.hidden = false;
    _btn_Edit.hidden = true;
    
    [_tbv_List setEditing:true animated:true];
}

- (IBAction)goEditDone:(UIButton *)sender {
    _btn_DeleteAll.hidden = true;
    _btn_EditDone.hidden = true;
    _btn_Edit.hidden = false;
    
    [_tbv_List setEditing:false animated:true];
}

- (IBAction)goDeleteAll:(id)sender {
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"모든 알람을 삭제 하시겠습니까?"
                                         message:@""
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
        if( action.style == UIAlertActionStyleDefault ) {
            
            [self.arM_Alarms removeAllObjects];
            [Util saveAlarm:self.arM_Alarms];
            [self goEditDone:self.btn_EditDone];
            [self.tbv_List reloadData];
        }
    }];
}

- (IBAction)goAdd:(id)sender {
    [ActionSheetDatePicker showPickerWithTitle:@"알람 등록"
                                datePickerMode:UIDatePickerModeTime
                                  selectedDate:[NSDate date]
                                     doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:selectedDate];
        
        BOOL isAdd = false;
        NSString *str_AddTime = [NSString stringWithFormat:@"%02ld%02ld", comp.hour, comp.minute];
        NSInteger nAddTime = [str_AddTime integerValue];
        for( NSInteger i = 0; i < self.arM_Alarms.count; i++ ) {
            NSDictionary *dic = self.arM_Alarms[i];
            NSString *str_TargetTime = [NSString stringWithFormat:@"%02ld%02ld", [dic[@"hour"] integerValue], [dic[@"min"] integerValue]];
            NSInteger nTargetTime = [str_TargetTime integerValue];
            if( nAddTime < nTargetTime ) {
                isAdd = true;
                [self.arM_Alarms insertObject:@{@"hour":@(comp.hour), @"min":@(comp.minute), @"on":@(true)} atIndex:i];
                break;
            }
        }
        
        if( isAdd == false ) {
            [self.arM_Alarms addObject:@{@"hour":@(comp.hour), @"min":@(comp.minute), @"on":@(true)}];
        }

        BOOL isAlarm = [[NSUserDefaults standardUserDefaults] boolForKey:@"Alarm"];
        if( isAlarm ) {
            [Util saveAlarm:self.arM_Alarms];
        }

        [self.tbv_List reloadData];
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:sender];
}

@end


/*
 {
     [[NSUserDefaults standardUserDefaults] setObject:_arM_Alarms forKey:@"Alarms"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     
 //    [self addAlarm];
     
 //    NSDateFormatter *format = [[NSDateFormatter alloc] init];
 //    [format setDateFormat:@"HH:mm"];
 //    NSString *str_Date = [NSString stringWithFormat:@"%02d-%02d", 21, 58];
 //    NSDate *date = [format dateFromString:str_Date];
 //
 //    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
 //    localNotification.fireDate = date;
 //    localNotification.alertBody = [NSString stringWithFormat:@"Alert Fired at %@", date];
 //    localNotification.soundName = UILocalNotificationDefaultSoundName;
 //    localNotification.applicationIconBadgeNumber = 1;
 //    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

     //2. I prefer removing any and all previously pending notif
     UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

     [center removeAllPendingNotificationRequests];

     //then check whether user has granted notif permission
     [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
         if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
             // Notifications not allowed, ask permission again
             [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                                   completionHandler:^(BOOL granted, NSError * _Nullable error) {
                 if (!error) {
                     //request authorization succeeded!

                 }
             }];
         }
     }];


     UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
 //    content.title = [NSString localizedUserNotificationStringForKey:nil arguments:nil];
     content.body = [NSString localizedUserNotificationStringForKey:@"약 먹을 시간이예요."
             arguments:nil];
     content.sound = [UNNotificationSound defaultSound];


     // Configure the trigger for a 7am wakeup.
     NSDateComponents* date = [[NSDateComponents alloc] init];
     date.hour = 22;
     date.minute = 12;
     UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
            triggerWithDateMatchingComponents:date repeats:true];

     // Create the request object.
     UNNotificationRequest* request = [UNNotificationRequest
            requestWithIdentifier:@"Alarm" content:content trigger:trigger];
     [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];

     
     
     
     
     
     
     
     
     
     
     
     
 //    NSDateFormatter *format = [[NSDateFormatter alloc] init];
 //    [format setDateFormat:@"HH:mm"];
 //    NSString *str_Date = [NSString stringWithFormat:@"%02d-%02d", 21, 42];
 //    NSDate *date = [format dateFromString:str_Date];
 //    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
 //
 //    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:comp repeats:YES];
 //    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
 //    content.title = @"Daily alarm";
 //    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"dailyalarm" content:content trigger:trigger];
 //    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];

     
     
     
     
     
     
 //    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
 //    content.title = @"Helloooooo...";
 //    content.body = @"Time to wake up!";
 //    content.sound = [UNNotificationSound defaultSound];
 //    //create trigger
 //
 //    NSDateFormatter *format = [[NSDateFormatter alloc] init];
 //    [format setDateFormat:@"HH:mm"];
 //    NSString *str_Date = [NSString stringWithFormat:@"%02d-%02d", 21, 40];
 //    NSDate *date = [format dateFromString:str_Date];
 //
 //    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
 //
 //    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:comp repeats:YES];
 //    NSString *identifier = @"test";
 //    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
 //                                                                          content:content trigger:trigger];
 //    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
 //    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
 //        if (error != nil) {
 //            NSLog(@"Something went wrong: %@",error);
 //        }
 //    }];
 }
 */
