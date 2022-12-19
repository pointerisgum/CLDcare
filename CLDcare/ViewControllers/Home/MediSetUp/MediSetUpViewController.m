//
//  MediSetUpViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/11/28.
//

#import "MediSetUpViewController.h"
#import "ActionSheetPicker.h"
#import "MDMediSetUpData.h"
#import "MediAlarmViewController.h"

@interface MediSetUpViewController () //<ActionSheetCustomPickerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;

@end

@implementation MediSetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if( _step == STEP1 ) {
        _btn_Back.hidden = true;
    } else {
        _btn_Back.hidden = false;
    }
    
    [self goChooise:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    switch(_step) {
        case STEP1: {
            [MDMediSetUpData sharedData].isNew = nil;
        } break;
        case STEP2: {
            [MDMediSetUpData sharedData].totalCount = nil;
        } break;
        case STEP3: {
            [MDMediSetUpData sharedData].isEveryDay = nil;
        } break;
        case STEP4: {
            [MDMediSetUpData sharedData].dayTakeCount = nil;
        } break;
        case STEP5: {
            [MDMediSetUpData sharedData].take1Count = nil;
        } break;
    }
}

- (void)showPicker:(NSArray *)rows withBlock:(void(^)(NSString * resulte))completion {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSLog(@"Picker: %@", picker);
        NSLog(@"Selected Index: %@", @(selectedIndex));
        NSLog(@"Selected Value: %@", selectedValue);
        completion(selectedValue);
        [self goNext:nil];
    };
    
    NSInteger initIdx = 0;
    if( _step == STEP2 ) {
        initIdx = 29;
    }
    ActionSheetStringPicker *p = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"Selection", nil) rows:rows initialSelection:initIdx doneBlock:done cancelBlock:nil origin:_btn_Next];
    p.hideCancel = true;
    [p showActionSheetPicker];
}

- (IBAction)goChooise:(id)sender {
    switch(_step) {
        case STEP1: {
            _lb_Contents.text = NSLocalizedString(@"Did you attach a new medicine bottle?", nil);
            [self showPicker:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]withBlock:^(NSString *resulte) {
                [MDMediSetUpData sharedData].isNew = resulte;
            }];
        } break;
        case STEP2: {
            _lb_Contents.text = NSLocalizedString(@"How many pills in the medicine bottle?", nil);
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            for(NSInteger i = 1; i <= 100; i++ ) {
                [rows addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            [self showPicker:rows withBlock:^(NSString *resulte) {
                [MDMediSetUpData sharedData].totalCount = resulte;
            }];
        } break;
        case STEP3: {
            _lb_Contents.text = NSLocalizedString(@"Do you need to take this medication every day?", nil);
            [self showPicker:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]withBlock:^(NSString *resulte) {
                [MDMediSetUpData sharedData].isEveryDay = resulte;
            }];
        } break;
        case STEP4: {
            _lb_Contents.text = NSLocalizedString(@"How often do you take it?", nil);
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            [rows addObject:NSLocalizedString(@"Once daily", nil)];
            [rows addObject:NSLocalizedString(@"Twice daily", nil)];
            [rows addObject:NSLocalizedString(@"3 times a day", nil)];
            [rows addObject:NSLocalizedString(@"4 times a day", nil)];
            [self showPicker:rows withBlock:^(NSString *resulte) {
                [MDMediSetUpData sharedData].dayTakeCount = resulte;
            }];
        } break;
        case STEP5: {
            _lb_Contents.text = NSLocalizedString(@"How many pills do you take each dose?", nil);
            NSMutableArray *rows = [[NSMutableArray alloc] init];
            for(NSInteger i = 1; i <= 3; i++ ) {
                [rows addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            [self showPicker:rows withBlock:^(NSString *resulte) {
                [MDMediSetUpData sharedData].take1Count = resulte;
            }];
        } break;
    }
}

- (void)showSelectAlert {
    [Util showConfirmAlret:self withMsg:NSLocalizedString(@"Please select an item", nil) completion:^(id result) {

    }];
}

- (IBAction)goNext:(id)sender {
    switch(_step) {
        case STEP1: {
            if( [MDMediSetUpData sharedData].isNew == nil ) {
                [self showSelectAlert];
                return;
            }
            if( [[MDMediSetUpData sharedData].isNew isEqualToString:NSLocalizedString(@"No", nil)] ) {
                [self dismissViewControllerAnimated:true completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"MediSetUpFinish" object:@{@"isNew":@(false)}];
                }];
                return;
            }
            MediSetUpViewController *vc = (MediSetUpViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpViewController"];
            vc.step = STEP2;
            [self.navigationController pushViewController:vc animated:true];
        } break;
        case STEP2: {
            if( [MDMediSetUpData sharedData].totalCount == nil ) {
                [self showSelectAlert];
                return;
            }
            MediSetUpViewController *vc = (MediSetUpViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpViewController"];
            vc.step = STEP3;
            [self.navigationController pushViewController:vc animated:true];
        } break;
        case STEP3: {
            if( [MDMediSetUpData sharedData].isEveryDay == nil ) {
                [self showSelectAlert];
                return;
            }
            MediSetUpViewController *vc = (MediSetUpViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpViewController"];
            vc.step = STEP4;
            [self.navigationController pushViewController:vc animated:true];
        } break;
        case STEP4: {
            if( [MDMediSetUpData sharedData].dayTakeCount == nil ) {
                [self showSelectAlert];
                return;
            }
            MediSetUpViewController *vc = (MediSetUpViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediSetUpViewController"];
            vc.step = STEP5;
            [self.navigationController pushViewController:vc animated:true];
        } break;
        case STEP5: {
            if( [MDMediSetUpData sharedData].take1Count == nil ) {
                [self showSelectAlert];
                return;
            }
            MediAlarmViewController *vc = (MediAlarmViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediAlarmViewController"];
            vc.alarmSetUp = ALARM1;
            [self.navigationController pushViewController:vc animated:true];
        } break;
    }
}

@end
