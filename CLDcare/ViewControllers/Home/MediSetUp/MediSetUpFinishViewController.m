//
//  MediSetUpFinishViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/11/29.
//

#import "MediSetUpFinishViewController.h"
#import "MDMediSetUpData.h"

@interface MediSetUpFinishViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents1;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents2;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents3;
@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_TbvHeight;
@end

@implementation MediSetUpFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_Contents1.text = [NSString stringWithFormat:@"%@ %@", [MDMediSetUpData sharedData].totalCount,
    NSLocalizedString(@"Pills in a Bottle", nil)];
    _lb_Contents2.text = NSLocalizedString([MDMediSetUpData sharedData].dayTakeCount, nil);
    if( [[MDMediSetUpData sharedData].take1Count integerValue] > 1 ) {
        _lb_Contents3.text = [NSString stringWithFormat:@"%@ %@", [MDMediSetUpData sharedData].take1Count,
                              NSLocalizedString(@"pills for a Dose", nil)];
    } else {
        _lb_Contents3.text = [NSString stringWithFormat:@"%@ %@", [MDMediSetUpData sharedData].take1Count,
                              NSLocalizedString(@"pill for a Dose", nil)];
    }
    
    _lc_TbvHeight.constant  = 50 * [MDMediSetUpData sharedData].alarms.count;
}

- (IBAction)goNext:(id)sender {
    NSMutableArray *arM_Alarms = [NSMutableArray array];
    for( NSString *key in [MDMediSetUpData sharedData].alarms.allKeys ) {
        NSDictionary *dic = [MDMediSetUpData sharedData].alarms[key];
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicM setObject:[MDMediSetUpData sharedData].take1Count forKey:@"take1Count"];
        if( dic.allKeys.count > 0 ) {
            [arM_Alarms addObject:dicM];
        }
    }
    [Util saveAlarm:arM_Alarms];

    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"initDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissViewControllerAnimated:true completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MediSetUpFinish" object:@{@"isNew":@(true)}];
    }];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MDMediSetUpData sharedData].alarms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *lb_Title = [cell viewWithTag:1];
    
    
    UILabel *lb_Time = [cell viewWithTag:2];

    NSDictionary *dic = nil;
    if( indexPath.row == 0 ) {
        dic = [[MDMediSetUpData sharedData].alarms objectForKey:@"1"];
        lb_Title.text = NSLocalizedString(@"1st dose", nil);
    } else if( indexPath.row == 1 ) {
        dic = [[MDMediSetUpData sharedData].alarms objectForKey:@"2"];
        lb_Title.text = NSLocalizedString(@"2nd dose", nil);
    } else if( indexPath.row == 2 ) {
        dic = [[MDMediSetUpData sharedData].alarms objectForKey:@"3"];
        lb_Title.text = NSLocalizedString(@"3rd dose", nil);
    } else if( indexPath.row == 3 ) {
        dic = [[MDMediSetUpData sharedData].alarms objectForKey:@"4"];
        lb_Title.text = NSLocalizedString(@"4th dose", nil);
    }
        
    if( dic.allKeys.count == 0 ) {
        lb_Time.text = @"-";
    } else {
        NSInteger nHour = [dic[@"hour"] integerValue];
        NSInteger nMin = [dic[@"min"] integerValue];

        NSString *ampm = @"AM";
        if( nHour >= 12 ) {
            ampm = @"PM";
        }
        
        if( nHour > 12 ) {
            nHour -= 12;
        }
        lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld %@", nHour, nMin, ampm];
    }

    return cell;
}


@end
