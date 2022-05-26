//
//  HelpDetailViewController.m
//  ReservoirMonitoring
//
//  Created by maiyou on 2022/5/26.
//

#import "HelpDetailViewController.h"

@interface HelpDetailViewController ()

@property(nonatomic,weak) IBOutlet UILabel *titleLabel;
@property(nonatomic,weak) IBOutlet UITextView *textView;
@end

@implementation HelpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getHelpDetail];
}

- (void)getHelpDetail{
    [Request.shareInstance getUrl:HelpDetail params:@{@"id":self.helpId} progress:^(float progress) {
            
    } success:^(NSDictionary * _Nonnull result) {
        self.titleLabel.text = result[@"data"][@"title"];
        NSString * content = result[@"data"][@"contentZh"];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        NSMutableAttributedString * att = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
        [att addAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor} range:NSMakeRange(0, att.length)];
        self.textView.attributedText = att;
    } failure:^(NSString * _Nonnull errorMsg) {
        
    }];
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
