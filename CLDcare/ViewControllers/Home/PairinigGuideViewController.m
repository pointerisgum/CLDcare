//
//  PairinigGuideViewController.m
//  CLDcare
//
//  Created by 김영민 on 2022/12/13.
//

#import "PairinigGuideViewController.h"

@interface PairinigGuideViewController ()

@end

@implementation PairinigGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)goNext:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchDeviceViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

@end
