//
//  MainTabBarViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/14.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.layer.shadowOffset = CGSizeMake(0, -5);
    self.tabBar.layer.cornerRadius = 2;
    self.tabBar.layer.shadowColor = [UIColor grayColor].CGColor;
    self.tabBar.layer.shadowOpacity = 0.1;
    self.tabBar.translucent = false;
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    
    if (@available(iOS 15, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance;
    }

    self.tabBar.tintColor = MAIN_COLOR;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
