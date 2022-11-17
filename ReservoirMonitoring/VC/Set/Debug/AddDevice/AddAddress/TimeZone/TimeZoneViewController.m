//
//  TimeZoneViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/6/8.
//

#import "TimeZoneViewController.h"

@interface TimeZoneViewController ()<UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView * tableView;
@property(nonatomic,weak)IBOutlet UITextField * textfield;
@property(nonatomic,strong) NSMutableArray * dataArray;
@property(nonatomic,strong) NSArray * searchArray;
@property(nonatomic,assign) BOOL isSearch;

@end

@implementation TimeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textfield.placeholderColor = [UIColor colorWithHexString:COLOR_PLACEHOLDER_COLOR];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldTextChange) name:UITextFieldTextDidChangeNotification object:nil];
    if (!self.listArray) {
        [self getTimeZoneData];
    }else{
        if (self.countryId) {
            NSArray * listArray = @[];
            for (NSDictionary * item in self.listArray) {
                int value = [item[@"value"] intValue];
                if (value == [[self.countryId componentsSeparatedByString:@","].firstObject intValue]) {
                    listArray = item[@"children"];
                }
            }
            self.listArray = listArray;
        }
        [self.tableView reloadData];
    }
}

- (void)textfieldTextChange{
    self.isSearch = self.textfield.text.length > 0;
    if (self.listArray) {
        self.searchArray = [self.listArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"label contains [cd] %@",self.textfield.text]];
    }else{
        self.searchArray = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains [cd] %@",self.textfield.text]];
    }
    NSLog(@"filter=%@",self.searchArray);
    [self.tableView reloadData];
}

- (void)getTimeZoneData{
    [Request.shareInstance getUrl:TimeZoneList params:@{@"countryId":self.countryId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.dataArray = result[@"data"];
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (self.isSearch) {
        if (self.listArray) {
            cell.textLabel.text = self.searchArray[indexPath.row][@"label"];
        }else{
            cell.textLabel.text = self.searchArray[indexPath.row][@"name"];
        }
    }else{
        if (self.listArray) {
            cell.textLabel.text = self.listArray[indexPath.row][@"label"];
        }else{
            cell.textLabel.text = self.dataArray[indexPath.row][@"name"];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.contentView.backgroundColor = tableView.backgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:true];
    if (self.isSearch) {
        if (self.selectTimeZone) {
            self.selectTimeZone(self.searchArray[indexPath.row]);
        }
    }else{
        if (self.listArray) {
            if (self.selectTimeZone) {
                self.selectTimeZone(self.listArray[indexPath.row]);
            }
        }else{
            if (self.selectTimeZone) {
                self.selectTimeZone(self.dataArray[indexPath.row]);
            }
        }
    }
    [self.navigationController popViewControllerAnimated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearch) {
        return self.searchArray.count;
    }else{
        return self.listArray.count > 0 ? self.listArray.count : self.dataArray.count;
    }
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
