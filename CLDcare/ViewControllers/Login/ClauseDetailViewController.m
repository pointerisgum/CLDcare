//
//  ClauseDetailViewController.m
//  Coledy
//
//  Created by 김영민 on 2021/07/19.
//

#import "ClauseDetailViewController.h"
@import WebKit;

@interface ClauseDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *btn_Next;
@end

@implementation ClauseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lb_Title.text = _str_Title;
    [_btn_Next setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];

    _webView.scrollView.showsHorizontalScrollIndicator = false;
    _webView.scrollView.showsVerticalScrollIndicator = false;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.str_Url]];
    [_webView loadRequest:request];
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
