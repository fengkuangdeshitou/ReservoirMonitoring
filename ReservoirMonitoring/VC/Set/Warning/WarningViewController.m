//
//  WarningViewController.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/19.
//

#import "WarningViewController.h"
#import "WarningListView.h"
@import SGPagingView;

@interface WarningViewController ()<SGPageTitleViewDelegate>

@property(nonatomic,weak)IBOutlet UIScrollView * scrollView;
@property(nonatomic,strong) SGPageTitleView * titleView;

@end

@implementation WarningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    SGPageTitleViewConfigure * config = [SGPageTitleViewConfigure pageTitleViewConfigure];
    config.titleSelectedColor = [UIColor colorWithHexString:@"#8CDFA5"];
    config.titleColor = [UIColor colorWithHexString:@"#747474"];
    config.titleFont = [UIFont systemFontOfSize:14];
    config.titleSelectedFont = [UIFont systemFontOfSize:14];
    config.showIndicator = false;
    config.showBottomSeparator = false;
    self.titleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40) delegate:self titleNames:@[@"警告",@"故障"] configure:config];
    self.titleView.backgroundColor = [UIColor colorWithHexString:@"#1E1E1E"];
    [self.view addSubview:self.titleView];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
    for (int i=0; i<2; i++) {
        WarningListView * list = [[WarningListView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavagationHeight-self.titleView.height)];
        [self.scrollView addSubview:list];
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

@end
