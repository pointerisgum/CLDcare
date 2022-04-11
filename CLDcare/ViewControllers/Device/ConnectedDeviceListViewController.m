//
//  ConnectedDeviceListViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "ConnectedDeviceListViewController.h"
#import "PopUpViewController.h"
#import "DeviceCell.h"

@interface ConnectedDeviceListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (strong, nonatomic) NSString *str_DeviceName;
@property (strong, nonatomic) NSString *str_MacAddr;
@end

@implementation ConnectedDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _str_DeviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    _str_MacAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"];
    [_tbv_List reloadData];
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
    if( _str_DeviceName != nil && _str_MacAddr != nil ) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceCell* cell = (DeviceCell*)[tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    cell.btn_Connect.layer.borderColor = [UIColor colorWithHexString:@"DCDCDC"].CGColor;
    cell.lb_DeviceName.text = _str_DeviceName;
    cell.lb_MacAddr.text = _str_MacAddr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    PopUpViewController *vc = [[UIStoryboard storyboardWithName:@"PopUp" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpViewController"];
    [vc setPopUpDismissBlock:^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mac"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"battery"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.navigationController popViewControllerAnimated:true];
    }];
    [self presentViewController:vc animated:true completion:^{
        
    }];
}

@end
