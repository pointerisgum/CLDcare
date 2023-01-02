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

@interface MediSetUpViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btn_Back;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_Contents;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) NSMutableArray *arM;
@end

@implementation MediSetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arM = [NSMutableArray array];
    
    if( _step == STEP1 ) {
        _btn_Back.hidden = true;
    } else {
        _btn_Back.hidden = false;
    }
    
    switch(_step) {
        case STEP1: {
            _lb_Contents.text = NSLocalizedString(@"Did you attach a new medicine bottle?", nil);
            [self.arM addObject:NSLocalizedString(@"Yes", nil)];
            [self.arM addObject:NSLocalizedString(@"No", nil)];
            [MDMediSetUpData sharedData].isNew = [self.arM firstObject];
        } break;
        case STEP2: {
            _lb_Contents.text = NSLocalizedString(@"How many pills in the medicine bottle?", nil);
            for(NSInteger i = 1; i <= 100; i++ ) {
                [self.arM addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            [MDMediSetUpData sharedData].totalCount = self.arM[29];
            [_picker selectRow:29 inComponent:0 animated:false];
        } break;
        case STEP3: {
            _lb_Contents.text = NSLocalizedString(@"Do you need to take this medication every day?", nil);
            [self.arM addObject:NSLocalizedString(@"Yes", nil)];
            [self.arM addObject:NSLocalizedString(@"No", nil)];
            [MDMediSetUpData sharedData].isEveryDay = [self.arM firstObject];
        } break;
        case STEP4: {
            _lb_Contents.text = NSLocalizedString(@"How often do you take it?", nil);
            [self.arM addObject:NSLocalizedString(@"Once daily", nil)];
            [self.arM addObject:NSLocalizedString(@"Twice daily", nil)];
            [self.arM addObject:NSLocalizedString(@"3 times a day", nil)];
            [self.arM addObject:NSLocalizedString(@"4 times a day", nil)];
            [MDMediSetUpData sharedData].dayTakeCount = [self.arM firstObject];
        } break;
        case STEP5: {
            _lb_Contents.text = NSLocalizedString(@"How many pills do you take each dose?", nil);
            for(NSInteger i = 1; i <= 3; i++ ) {
                [self.arM addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            [MDMediSetUpData sharedData].take1Count = [self.arM firstObject];
        } break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    switch(_step) {
//        case STEP1: {
//            [MDMediSetUpData sharedData].isNew = nil;
//        } break;
//        case STEP2: {
//            [MDMediSetUpData sharedData].totalCount = nil;
//        } break;
//        case STEP3: {
//            [MDMediSetUpData sharedData].isEveryDay = nil;
//        } break;
//        case STEP4: {
//            [MDMediSetUpData sharedData].dayTakeCount = nil;
//        } break;
//        case STEP5: {
//            [MDMediSetUpData sharedData].take1Count = nil;
//        } break;
//    }
}

//- (void)showPicker:(NSArray *)rows withBlock:(void(^)(NSString * resulte))completion {
//    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//        NSLog(@"Picker: %@", picker);
//        NSLog(@"Selected Index: %@", @(selectedIndex));
//        NSLog(@"Selected Value: %@", selectedValue);
//        completion(selectedValue);
//        [self goNext:nil];
//    };
//
//    NSInteger initIdx = 0;
//    if( _step == STEP2 ) {
//        initIdx = 29;
//    }
//    ActionSheetStringPicker *p = [[ActionSheetStringPicker alloc] initWithTitle:NSLocalizedString(@"Selection", nil) rows:rows initialSelection:initIdx doneBlock:done cancelBlock:nil origin:_btn_Next];
//    p.hideCancel = true;
//    [p showActionSheetPicker];
//}

//- (IBAction)goChooise:(id)sender {
//    switch(_step) {
//        case STEP1: {
//            _lb_Contents.text = NSLocalizedString(@"Did you attach a new medicine bottle?", nil);
//            [self showPicker:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]withBlock:^(NSString *resulte) {
//                [MDMediSetUpData sharedData].isNew = resulte;
//            }];
//        } break;
//        case STEP2: {
//            _lb_Contents.text = NSLocalizedString(@"How many pills in the medicine bottle?", nil);
//            NSMutableArray *rows = [[NSMutableArray alloc] init];
//            for(NSInteger i = 1; i <= 100; i++ ) {
//                [rows addObject:[NSString stringWithFormat:@"%ld", i]];
//            }
//            [self showPicker:rows withBlock:^(NSString *resulte) {
//                [MDMediSetUpData sharedData].totalCount = resulte;
//            }];
//        } break;
//        case STEP3: {
//            _lb_Contents.text = NSLocalizedString(@"Do you need to take this medication every day?", nil);
//            [self showPicker:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]withBlock:^(NSString *resulte) {
//                [MDMediSetUpData sharedData].isEveryDay = resulte;
//            }];
//        } break;
//        case STEP4: {
//            _lb_Contents.text = NSLocalizedString(@"How often do you take it?", nil);
//            NSMutableArray *rows = [[NSMutableArray alloc] init];
//            [rows addObject:NSLocalizedString(@"Once daily", nil)];
//            [rows addObject:NSLocalizedString(@"Twice daily", nil)];
//            [rows addObject:NSLocalizedString(@"3 times a day", nil)];
//            [rows addObject:NSLocalizedString(@"4 times a day", nil)];
//            [self showPicker:rows withBlock:^(NSString *resulte) {
//                [MDMediSetUpData sharedData].dayTakeCount = resulte;
//            }];
//        } break;
//        case STEP5: {
//            _lb_Contents.text = NSLocalizedString(@"How many pills do you take each dose?", nil);
//            NSMutableArray *rows = [[NSMutableArray alloc] init];
//            for(NSInteger i = 1; i <= 3; i++ ) {
//                [rows addObject:[NSString stringWithFormat:@"%ld", i]];
//            }
//            [self showPicker:rows withBlock:^(NSString *resulte) {
//                [MDMediSetUpData sharedData].take1Count = resulte;
//            }];
//        } break;
//    }
//}

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

#pragma mark -- UIPicker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.arM.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.arM[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch(_step) {
        case STEP1: {
            [MDMediSetUpData sharedData].isNew = self.arM[row];
        } break;
        case STEP2: {
            [MDMediSetUpData sharedData].totalCount = self.arM[row];
        } break;
        case STEP3: {
            [MDMediSetUpData sharedData].isEveryDay = self.arM[row];
        } break;
        case STEP4: {
            [MDMediSetUpData sharedData].dayTakeCount = self.arM[row];
        } break;
        case STEP5: {
            [MDMediSetUpData sharedData].take1Count = self.arM[row];
        } break;
    }}

@end
