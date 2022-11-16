//
//  CountryCodeViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/10/28.
//

#import "CountryCodeViewController.h"

@interface CountryCodeViewController ()

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UITextField * textfield;
@property(nonatomic,strong) NSMutableArray * dataArray;
@property(nonatomic,strong) NSArray * searchArray;
@property(nonatomic,assign) BOOL isSearch;

@end

@implementation CountryCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Select Country/Region";
    self.textfield.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    [self getCountryCodeList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldTextChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textfieldTextChange{
    self.isSearch = self.textfield.text.length > 0;
    self.searchArray = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countryName contains [cd] %@ || countryCode contains %@",self.textfield.text,self.textfield.text]];
    NSLog(@"filter=%@",self.searchArray);
    [self.tableView reloadData];
}

- (void)getCountryCodeList{
    [Request.shareInstance getUrl:CountryCode params:@{} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = result[@"data"];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CountryCell"];
    }
    NSDictionary * item = self.isSearch ?self.searchArray[indexPath.row] : self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@  +%@",item[@"countryName"],item[@"countryCode"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.contentView.backgroundColor = tableView.backgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectCountryCode) {
        self.selectCountryCode(self.isSearch ? self.searchArray[indexPath.row] : self.dataArray[indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.isSearch ? self.searchArray.count : self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
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
