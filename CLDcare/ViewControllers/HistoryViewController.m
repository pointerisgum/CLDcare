//
//  HistoryViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/13.
//

#import "HistoryViewController.h"
#import "UIAlertController+Message.h"
#import "ble_packet.h"
#import "ScanPeripheralDelegate.h"
#import <MBProgressHUD.h>
#import "ComTimer.h"
#import "NDHistory.h"
//#import "HistoryViewController.h"

#define def_command_timeout 5

@interface HistoryViewController () <ScanPeripheralDelegate> {
    dispatch_block_t  connectBlock;
    ComTimer*         commandTimer;
    uint8_t           send_cmd;
    uint32_t          history_count;
    uint32_t          history_index;
}
@property (weak, nonatomic) IBOutlet UITableView *tbv_List;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) MBProgressHUD* hud;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    commandTimer = [ComTimer timerWithTimeout:def_command_timeout];

}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        self.device.delegate = nil;
    }
}


#pragma mark - HUD management
- (void) showHUD:(NSString*) title mode:(MBProgressHUDMode)mode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud == nil)
        {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        self.hud.mode = mode;
        self.hud.label.text = title;
    });
}

- (void) setHUDTitle:(NSString*) title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.label.text = title;
    });
    
}

- (void) setHUDProgress:(float) progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.progress = progress;
    });
}

- (void) hideHUD
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud != nil)
            [self.hud hideAnimated:YES];
        self.hud = nil;
    });
}

#pragma mark - Button event handler
- (void)setDevice:(ScanPeripheral *)device {
    _device = device;
    _device.delegate = self;
}

- (void) sendPacket:(uint8_t)cmd data:(void*)data length:(NSUInteger)length
{
    NSUInteger len = length + ble_nus_header_length;
    uint8_t buf[len];
    ble_nus_data_t* base = (ble_nus_data_t*)buf;
    base->cmd = cmd;
    base->header = ble_nus_prefix;
    
    if (length != 0)
        memcpy((uint8_t*)buf + ble_nus_header_length, data, length);
    
    [_device writeBuffer:buf withLength:len];
    
    // save command & start timer
    send_cmd = cmd;
    [commandTimer start];
}

- (IBAction)on_reset_count:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
//    SettingsViewController* controller = self;
    
    [UIAlertController mesageBoxWithTitle:@"리셋" message:nil style:MBS_YesNo handler:^(MessageBoxButton selectedButton){
        if (selectedButton == MB_Yes)
        {
            self->connectBlock = ^(){
                NSDate* date = [NSDate date];
                NSDateComponents *cur_components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond| NSCalendarUnitWeekday fromDate:date];
                
                ble_date_time_t dt;
                dt.year = cur_components.year;
                dt.month = cur_components.month;
                dt.day = cur_components.day;
                dt.hour = cur_components.hour;
                dt.min = cur_components.minute;
                dt.sec = cur_components.second;
                dt.weekdays = cur_components.weekday;
                [weakSelf sendPacket:ncmd_reset data:&dt length:sizeof(dt)];
            };
            
            [weakSelf showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
            [weakSelf.centralManager connectPeripheral:weakSelf.device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
        }
        
    } viewController:self];
}

- (IBAction)on_history:(id)sender
{
    __weak typeof(self) weakSelf = self;

//    HistoryViewController* controller = self;

    history_count = 0;
    history_index = 0;
    
    connectBlock = ^(){
        [weakSelf sendPacket:ncmd_count data:NULL length:0];
    };
    
    [self showHUD:@"Connecting" mode:MBProgressHUDModeDeterminate];
    [_centralManager connectPeripheral:_device.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

#pragma mark - ScanPeripheral delegate
-(void) scanPeripheral:(id)peripheral serviceDiscovered:(BOOL)success
{
    NSLog(@"service : %d", success);
    [self setHUDTitle:@"Discovering services"];
    [self setHUDProgress:0.4f];
}

-(void) scanPeripheral:(id)peripheral characteristicsDiscovered:(BOOL)success
{
    NSLog(@"characteristics : %d", success);

    [self runConnectBlock];
}

- (void) runConnectBlock
{
    [self setHUDTitle:@"Send command"];
    [self setHUDProgress:0.8f];
    
    connectBlock();
    connectBlock = nil;
    
    //[UIAlertController mesageBoxWithTitle:@"Setting has been successfully transferred!" message:nil style:MBS_OK handler:nil];
}

- (void) requestHistoryData
{
    ble_req_data_t req;
    req.index = history_index;
    [self sendPacket:ncmd_get_data data:&req length:sizeof(req)];
}

- (void)showHistory
{
//    [self performSegueWithIdentifier:@"historySegue" sender:self];
    [_tbv_List reloadData];
    if( _historyBlock ) {
        NSMutableArray *arM = [NSMutableArray arrayWithCapacity:_items.count];
        for( NSInteger i = 0; i < _items.count; i++ ) {
            NDHistory *history = [[NDHistory alloc] initWithData:_items[i] withIdx:history_index];
            [arM addObject:history];
        }
        _historyBlock(arM);
    }
}

- (void)scanPeripheral:(id)peripheral didReceiveData:(NSData *)data
{
//    NSLog(@"Did receive data\n");

    ble_nus_data_t* rcv = (ble_nus_data_t*)data.bytes;
    if(data.length < ble_nus_header_length)
    {
        NSLog(@"data length error");
        return;
    }
    
    BOOL success = NO, fail=NO;
    
    if (send_cmd == rcv->cmd)
    {
        switch (send_cmd)
        {
            case ncmd_take_time:
            case ncmd_reset:
                success = YES;
                break;
            case ncmd_count :
                {
                    ble_res_count_t* res = (ble_res_count_t*)rcv->buffer;
                    history_count = res->stored_count;
                    history_index = 13;
                    _items = [NSMutableArray array];
                    
                    [self setHUDProgress:0.5f];
                    [self requestHistoryData];
                }
                break;
            case ncmd_get_data:
                {
                    ble_res_data_t* res = (ble_res_data_t*)rcv->buffer;
                    NSLog(@"(v:%d) %d-%d-%d %d:%d:%d",
                          res->valid, res->ttime[0], res->ttime[1], res->ttime[2], res->ttime[3],
                          res->ttime[4], res->ttime[5]);
                    
                    history_index++;
                    if (res->valid) {
                        [_items addObject:[NSData dataWithBytes:res length:sizeof(ble_res_data_t)]];
                    }

                    if( history_index == history_count || res->valid == 0 ) {
                        [_centralManager cancelPeripheralConnection:self.device.peripheral];
                        
                        [self setHUDProgress:1.0f];
                        [self hideHUD];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showHistory];
                        });
                    } else {
                        [self requestHistoryData];
                    }
                }
                break;
        }
    }
    
    if (success)
    {
        // disconnect
        [_centralManager cancelPeripheralConnection:self.device.peripheral];
        
        [self setHUDProgress:1.0f];
        [self hideHUD];

        [UIAlertController mesageBoxWithTitle:@"Setting has been successfully saved" message:nil style:MBS_OK handler:nil viewController:self];
    }
    if (fail)
    {
        // disconnect
        [_centralManager cancelPeripheralConnection:self.device.peripheral];
        [UIAlertController mesageBoxWithTitle:@"Sorry, Request failed!" message:nil style:MBS_OK handler:nil viewController:self];
    }
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    UILabel *lable = [cell viewWithTag:1];
    
    NSData* data = [_items objectAtIndex:_items.count - indexPath.row - 1];
    ble_res_data_t* res = (ble_res_data_t*)data.bytes;
    
    lable.text = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
                  res->ttime[0]+2000,
                  res->ttime[1],
                  res->ttime[2],
                  res->ttime[3],
                  res->ttime[4],
                  res->ttime[5]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];


}

@end
