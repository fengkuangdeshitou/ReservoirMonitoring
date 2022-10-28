//
//  InstallationCompleteViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/28.
//

#import "InstallationCompleteViewController.h"
#import "CompleteImageTableViewCell.h"

@interface InstallationCompleteViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,assign)CGFloat imageHeight;

@end

@implementation InstallationCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageHeight = SCREEN_WIDTH/3;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CompleteImageTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([CompleteImageTableViewCell class])];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CompleteImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CompleteImageTableViewCell class]) forIndexPath:indexPath];
    cell.updateFrameBlock = ^(CGRect frame){
        [tableView beginUpdates];
        self.imageHeight = frame.size.height;
        [tableView endUpdates];
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.imageHeight;
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
